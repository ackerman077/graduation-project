import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../data/repositories/specializations_repository.dart';
import '../../../../core/models/specialization.dart';
import '../../../../core/services/logger_service.dart';

abstract class SpecializationsEvent extends Equatable {
  const SpecializationsEvent();

  @override
  List<Object?> get props => [];
}

class LoadSpecializations extends SpecializationsEvent {}

class LoadSpecializationDetails extends SpecializationsEvent {
  final int specializationId;

  const LoadSpecializationDetails(this.specializationId);

  @override
  List<Object?> get props => [specializationId];
}

abstract class SpecializationsState extends Equatable {
  const SpecializationsState();

  @override
  List<Object?> get props => [];
}

class SpecializationsInitial extends SpecializationsState {}

class SpecializationsLoading extends SpecializationsState {}

class SpecializationsLoaded extends SpecializationsState {
  final List<Specialization> specializations;

  const SpecializationsLoaded(this.specializations);

  @override
  List<Object?> get props => [specializations];
}

class SpecializationDetailsLoaded extends SpecializationsState {
  final Specialization specialization;

  const SpecializationDetailsLoaded(this.specialization);

  @override
  List<Object?> get props => [specialization];
}

class SpecializationsError extends SpecializationsState {
  final String message;

  const SpecializationsError(this.message);

  @override
  List<Object?> get props => [message];
}

class SpecializationsCubit extends Cubit<SpecializationsState> {
  final SpecializationsRepository _specializationsRepository;

  SpecializationsCubit(this._specializationsRepository)
    : super(SpecializationsInitial());

  Future<void> loadSpecializations() async {
    if (isClosed) return;
    emit(SpecializationsLoading());

    try {
      final response = await _specializationsRepository.getAllSpecializations();

      if (isClosed) return;
      if (response.isSuccess && response.data != null) {
        emit(SpecializationsLoaded(response.data!));
      } else {
        emit(
          SpecializationsError(
            response.message ??
                'Failed to load specializations. Please try again.',
          ),
        );
      }
    } catch (e) {
      if (isClosed) return;
      emit(SpecializationsError('Failed to load specializations: $e'));
    }
  }

  Future<void> loadSpecializationDetails(int specializationId) async {
    if (isClosed) return;
    emit(SpecializationsLoading());

    try {
      LoggerService.debug('Specialization $specializationId requested');

      if (state is SpecializationsLoaded) {
        final currentState = state as SpecializationsLoaded;

        final specialization = currentState.specializations.firstWhere(
          (s) => s.id == specializationId,
          orElse: () => throw Exception('Specialization not found in list'),
        );
        emit(SpecializationDetailsLoaded(specialization));
        return;
      }

      LoggerService.debug('List not loaded yet, fetching');
      await loadSpecializations();

      if (state is SpecializationsLoaded) {
        final currentState = state as SpecializationsLoaded;
        final specialization = currentState.specializations.firstWhere(
          (s) => s.id == specializationId,
          orElse: () => throw Exception('Specialization not found in list'),
        );

        emit(SpecializationDetailsLoaded(specialization));
        return;
      }
      emit(const SpecializationsError('Failed to load specializations list'));
    } catch (e) {
      LoggerService.error('Specialization $specializationId load failed: $e');
      if (isClosed) return;
      emit(SpecializationsError('Failed to load specialization details: $e'));
    }
  }
}
