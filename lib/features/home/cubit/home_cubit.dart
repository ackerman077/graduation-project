import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../data/repositories/home_repository.dart';
import '../../../core/models/doctor.dart';
import '../../../core/services/logger_service.dart';
import '../../../core/services/data_storage_service.dart';
import '../../../core/services/connectivity_service.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<dynamic> homeData;
  final List<Doctor> recommendedDoctors;

  const HomeLoaded({required this.homeData, required this.recommendedDoctors});

  @override
  List<Object?> get props => [homeData, recommendedDoctors];
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}

class HomeOffline extends HomeState {
  final List<dynamic> homeData;
  final List<Doctor> recommendedDoctors;
  const HomeOffline({required this.homeData, required this.recommendedDoctors});

  @override
  List<Object?> get props => [homeData, recommendedDoctors];
}

class HomeCubit extends Cubit<HomeState> {
  final HomeRepository _homeRepository;
  final ConnectivityService _connectivityService = ConnectivityService();

  HomeCubit(this._homeRepository) : super(HomeInitial()) {
    _initializeConnectivity();
  }

  void _initializeConnectivity() {
    _connectivityService.addListener(_onConnectivityChanged);
  }

  void _onConnectivityChanged(bool isOnline) {
    LoggerService.debug(
      'Home connectivity: ${isOnline ? "online" : "offline"}',
    );
    if (!isOnline) {
      LoggerService.debug('Offline mode: loading cached home data');
      _loadCachedData();
    } else {
      LoggerService.debug('Back online');
    }
  }

  Future<void> _loadCachedData() async {
    try {
      final cachedData = await DataStorageService.getHomeData();
      if (cachedData != null) {
        LoggerService.debug('Cached home data found');

        final homeData = cachedData['homeData'] ?? [];
        final recommendedDoctorsRaw = cachedData['recommendedDoctors'] ?? [];

        List<Doctor> recommendedDoctors = [];
        try {
          recommendedDoctors = recommendedDoctorsRaw
              .map((json) {
                if (json is Map<String, dynamic>) {
                  return Doctor.fromJson(json);
                } else {
                  LoggerService.error(
                    'Invalid doctor data format: ${json.runtimeType}',
                  );
                  return null;
                }
              })
              .where((doctor) => doctor != null)
              .cast<Doctor>()
              .toList();
        } catch (e) {
          LoggerService.error('Cached doctors parse error: $e');
          recommendedDoctors = [];
        }

        emit(
          HomeOffline(
            homeData: homeData,
            recommendedDoctors: recommendedDoctors,
          ),
        );
      } else {
        emit(
          const HomeError(
            'No cached data available. Please check your internet connection.',
          ),
        );
      }
    } catch (e) {
      LoggerService.error('Error loading cached data: $e');
      emit(HomeError('Failed to load cached data: $e'));
    }
  }

  Future<void> loadHomeData() async {
    if (isClosed) return;

    final isOnline = await _connectivityService.checkConnectivityManually();
    if (!isOnline) {
      LoggerService.debug('Home load skipped (offline) — using cache');
      await _loadCachedData();
      return;
    }

    emit(HomeLoading());

    try {
      final homeResponse = await _homeRepository.getHomePage();
      final doctorsResponse = await _homeRepository.getRecommendedDoctors();

      if (isClosed) return;
      if (homeResponse.isSuccess && doctorsResponse.isSuccess) {
        final homeData = homeResponse.data ?? [];
        final recommendedDoctors = doctorsResponse.data ?? [];

        final homeDataMap = {
          'homeData': homeData,
          'recommendedDoctors': recommendedDoctors,
        };
        await DataStorageService.storeHomeData(homeDataMap);

        emit(
          HomeLoaded(
            homeData: homeData,
            recommendedDoctors: recommendedDoctors,
          ),
        );
      } else {
        await _loadCachedData();
      }
    } catch (e) {
      if (isClosed) return;
      LoggerService.error('Home data load failed: $e');

      await _loadCachedData();
    }
  }

  @override
  Future<void> close() {
    _connectivityService.removeListener(_onConnectivityChanged);
    return super.close();
  }
}
