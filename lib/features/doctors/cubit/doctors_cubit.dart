import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../data/repositories/doctors_repository.dart';
import '../../../../core/mixins/error_handling_mixin.dart';
import '../../../../core/models/doctor.dart';
import '../../../../core/models/city.dart';
import '../../../../core/models/governorate.dart';
import '../../../../core/services/logger_service.dart';

abstract class DoctorsEvent extends Equatable {
  const DoctorsEvent();

  @override
  List<Object?> get props => [];
}

class LoadDoctors extends DoctorsEvent {}

class SearchDoctors extends DoctorsEvent {
  final String query;

  const SearchDoctors(this.query);

  @override
  List<Object?> get props => [query];
}

class ClearSearch extends DoctorsEvent {}

class FilterDoctors extends DoctorsEvent {
  final int? cityId;
  final int? specializationId;
  final double? minRating;
  final bool? availableToday;

  const FilterDoctors({
    this.cityId,
    this.specializationId,
    this.minRating,
    this.availableToday,
  });

  @override
  List<Object?> get props => [
    cityId,
    specializationId,
    minRating,
    availableToday,
  ];
}

class LoadDoctorDetails extends DoctorsEvent {
  final int doctorId;

  const LoadDoctorDetails(this.doctorId);

  @override
  List<Object?> get props => [doctorId];
}

class LoadGovernorates extends DoctorsEvent {}

abstract class DoctorsState extends Equatable {
  const DoctorsState();

  @override
  List<Object?> get props => [];
}

class DoctorsInitial extends DoctorsState {}

class DoctorsLoading extends DoctorsState {}

class DoctorsLoaded extends DoctorsState {
  final List<Doctor> doctors;
  final List<City> availableCitiesObjects;
  final List<Governorate> availableGovernorates;
  final String searchQuery;
  final List<Doctor> searchResults;
  final bool isSearching;

  const DoctorsLoaded({
    required this.doctors,
    this.availableCitiesObjects = const [],
    this.availableGovernorates = const [],
    this.searchQuery = '',
    this.searchResults = const [],
    this.isSearching = false,
  });

  @override
  List<Object?> get props => [
    doctors,
    availableCitiesObjects,
    availableGovernorates,
    searchQuery,
    searchResults,
    isSearching,
  ];

  DoctorsLoaded copyWith({
    List<Doctor>? doctors,
    List<City>? availableCitiesObjects,
    List<Governorate>? availableGovernorates,
    String? searchQuery,
    List<Doctor>? searchResults,
    bool? isSearching,
  }) {
    return DoctorsLoaded(
      doctors: doctors ?? this.doctors,
      availableCitiesObjects:
          availableCitiesObjects ?? this.availableCitiesObjects,
      availableGovernorates:
          availableGovernorates ?? this.availableGovernorates,
      searchQuery: searchQuery ?? this.searchQuery,
      searchResults: searchResults ?? this.searchResults,
      isSearching: isSearching ?? this.isSearching,
    );
  }
}

class DoctorDetailsLoaded extends DoctorsState {
  final Doctor doctor;

  const DoctorDetailsLoaded(this.doctor);

  @override
  List<Object?> get props => [doctor];
}

class DoctorsError extends DoctorsState {
  final String message;

  const DoctorsError(this.message);

  @override
  List<Object?> get props => [message];
}

class DoctorsCubit extends Cubit<DoctorsState> with ErrorHandlingMixin {
  final DoctorsRepository _doctorsRepository;

  DoctorsCubit(this._doctorsRepository) : super(DoctorsInitial());

  Future<void> loadDoctors() async {
    if (isClosed) return;
    emit(DoctorsLoading());

    try {
      final response = await _doctorsRepository.getAllDoctors();

      if (isClosed) return;
      if (response.isSuccess && response.data != null) {
        final doctors = response.data!;
        if (state is DoctorsLoaded) {
          final currentState = state as DoctorsLoaded;
          emit(currentState.copyWith(doctors: doctors));
        } else {
          emit(DoctorsLoaded(doctors: doctors));
        }
      } else {
        emit(
          DoctorsError(
            response.message ?? 'Failed to load doctors. Please try again.',
          ),
        );
      }
    } catch (e) {
      if (isClosed) return;
      logError(e, 'loadDoctors');
      final userFriendlyMessage = handleError(e);
      emit(DoctorsError(userFriendlyMessage));
    }
  }

  Future<void> searchDoctors(String query) async {
    if (query.trim().isEmpty) {
      await loadDoctors();
      return;
    }

    if (isClosed) return;
    emit(DoctorsLoading());

    try {
      final response = await _doctorsRepository.searchDoctors(query);

      if (isClosed) return;
      if (response.isSuccess && response.data != null) {
        final searchResults = response.data!;
        if (state is DoctorsLoaded) {
          final currentState = state as DoctorsLoaded;
          emit(
            currentState.copyWith(
              searchResults: searchResults,
              isSearching: true,
              searchQuery: query,
            ),
          );
        } else {
          emit(
            DoctorsLoaded(
              doctors: const [],
              searchResults: searchResults,
              isSearching: true,
              searchQuery: query,
            ),
          );
        }
      } else {
        emit(
          DoctorsError(
            response.message ?? 'Failed to search doctors. Please try again.',
          ),
        );
      }
    } catch (e) {
      if (isClosed) return;
      logError(e, 'searchDoctors');
      final userFriendlyMessage = handleError(e);
      emit(DoctorsError(userFriendlyMessage));
    }
  }

  Future<void> filterDoctors({
    int? cityId,
    int? specializationId,
    double? minRating,
    bool? availableToday,
  }) async {
    if (isClosed) return;
    emit(DoctorsLoading());

    try {
      final response = await _doctorsRepository.filterDoctors(
        cityId: cityId,
        specializationId: specializationId,
        minRating: minRating,
        availableToday: availableToday,
      );

      if (isClosed) return;
      if (response.isSuccess && response.data != null) {
        final doctors = response.data!;
        if (state is DoctorsLoaded) {
          final currentState = state as DoctorsLoaded;
          emit(currentState.copyWith(doctors: doctors));
        } else {
          emit(DoctorsLoaded(doctors: doctors));
        }
      } else {
        emit(
          DoctorsError(
            response.message ?? 'Failed to filter doctors. Please try again.',
          ),
        );
      }
    } catch (e) {
      if (isClosed) return;
      String errorMessage = 'Failed to filter doctors. Please try again.';

      if (e.toString().contains('Connection failed') ||
          e.toString().contains('Network is unreachable')) {
        errorMessage = 'No internet connection. Please check your network.';
      } else if (e.toString().contains('timeout')) {
        errorMessage = 'Request timeout. Please try again.';
      }

      emit(DoctorsError(errorMessage));
    }
  }

  Future<void> loadDoctorDetails(int doctorId) async {
    emit(DoctorsLoading());

    try {
      final response = await _doctorsRepository.getDoctorById(doctorId);

      if (response.isSuccess && response.data != null) {
        emit(DoctorDetailsLoaded(response.data!));
      } else {
        emit(
          DoctorsError(
            response.message ??
                'Failed to load doctor details. Please try again.',
          ),
        );
      }
    } catch (e) {
      String errorMessage = 'Failed to load doctor details. Please try again.';

      if (e.toString().contains('Connection failed') ||
          e.toString().contains('Network is unreachable')) {
        errorMessage = 'No internet connection. Please check your network.';
      } else if (e.toString().contains('timeout')) {
        errorMessage = 'Request timeout. Please try again.';
      }

      emit(DoctorsError(errorMessage));
    }
  }

  Future<void> loadCities() async {
    if (isClosed) return;

    try {
      final response = await _doctorsRepository.getAllCities();

      if (isClosed) return;

      if (response.isSuccess && response.data != null) {
        final cityObjects = response.data!;

        if (state is DoctorsLoaded) {
          final currentState = state as DoctorsLoaded;
          emit(currentState.copyWith(availableCitiesObjects: cityObjects));
        } else {
          emit(
            DoctorsLoaded(
              doctors: const [],
              availableCitiesObjects: cityObjects,
            ),
          );
        }
      }
    } catch (e) {
      if (!isClosed) {
        LoggerService.error('Failed to load cities: $e');
      }
    }
  }

  Future<void> loadGovernorates() async {
    if (isClosed) return;

    try {
      final response = await _doctorsRepository.getAllGovernrates();

      if (isClosed) return;

      if (response.isSuccess && response.data != null) {
        final governorates = response.data!.map(Governorate.fromJson).toList();

        if (state is DoctorsLoaded) {
          final currentState = state as DoctorsLoaded;
          emit(currentState.copyWith(availableGovernorates: governorates));
        } else {
          emit(
            DoctorsLoaded(
              doctors: const [],
              availableGovernorates: governorates,
            ),
          );
        }
      }
    } catch (e) {
      if (!isClosed) {
        LoggerService.error('Failed to load governorates: $e');
      }
    }
  }

  Future<void> filterDoctorsByGovernorate(int governorateId) async {
    if (isClosed) return;

    try {
      emit(DoctorsLoading());

      final citiesResponse = await _doctorsRepository.getCitiesByGovernorate(
        governorateId,
      );

      if (isClosed) return;

      if (!citiesResponse.isSuccess || citiesResponse.data == null) {
        emit(const DoctorsError('Failed to get cities for this governorate'));
        return;
      }

      final cities = citiesResponse.data!;
      final List<Doctor> allDoctors = [];

      for (final city in cities) {
        if (isClosed) return;

        final doctorsResponse = await _doctorsRepository.filterDoctors(
          cityId: city.id,
        );

        if (doctorsResponse.isSuccess && doctorsResponse.data != null) {
          allDoctors.addAll(doctorsResponse.data!);
        }
      }

      if (isClosed) return;

      final Map<int, Doctor> doctorMap = {};
      for (final doctor in allDoctors) {
        doctorMap[doctor.id] = doctor;
      }
      final uniqueDoctors = doctorMap.values.toList();

      if (state is DoctorsLoaded) {
        final currentState = state as DoctorsLoaded;
        emit(currentState.copyWith(doctors: uniqueDoctors));
      } else {
        emit(
          DoctorsLoaded(
            doctors: uniqueDoctors,
            availableCitiesObjects: const [],
            availableGovernorates: const [],
          ),
        );
      }
    } catch (e) {
      if (isClosed) return;
      logError(e, 'filterDoctorsByGovernorate');
      final userFriendlyMessage = handleError(e);
      emit(DoctorsError(userFriendlyMessage));
    }
  }

  void clearSearch() {
    if (state is DoctorsLoaded) {
      final currentState = state as DoctorsLoaded;
      emit(
        currentState.copyWith(
          searchQuery: '',
          searchResults: const [],
          isSearching: false,
        ),
      );
    }
  }
}
