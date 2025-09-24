import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../data/repositories/appointments_repository.dart';
import '../../../core/models/appointment.dart';
import '../../../core/services/logger_service.dart';

abstract class AppointmentsEvent extends Equatable {
  const AppointmentsEvent();

  @override
  List<Object?> get props => [];
}

class LoadAppointments extends AppointmentsEvent {}

class BookAppointment extends AppointmentsEvent {
  final int doctorId;
  final DateTime startTime;
  final String? notes;

  const BookAppointment({
    required this.doctorId,
    required this.startTime,
    this.notes,
  });

  @override
  List<Object?> get props => [doctorId, startTime, notes];
}

abstract class AppointmentsState extends Equatable {
  const AppointmentsState();

  @override
  List<Object?> get props => [];
}

class AppointmentsInitial extends AppointmentsState {}

class AppointmentsLoading extends AppointmentsState {}

class AppointmentsLoaded extends AppointmentsState {
  final List<Appointment> appointments;

  const AppointmentsLoaded(this.appointments);

  @override
  List<Object?> get props => [appointments];
}

class AppointmentBooked extends AppointmentsState {
  final Map<String, dynamic> bookingData;

  const AppointmentBooked(this.bookingData);

  @override
  List<Object?> get props => [bookingData];
}

class AppointmentsError extends AppointmentsState {
  final String message;

  const AppointmentsError(this.message);

  @override
  List<Object?> get props => [message];
}

class AppointmentsCubit extends Cubit<AppointmentsState> {
  final AppointmentsRepository _appointmentsRepository;

  AppointmentsCubit(this._appointmentsRepository)
    : super(AppointmentsInitial());

  Future<void> loadAppointments() async {
    if (!isClosed) {
      emit(AppointmentsLoading());
    } else {
      LoggerService.debug('AppointmentsCubit is closed, skipping load');
      return;
    }

    try {
      final response = await _appointmentsRepository.getAllAppointments();

      if (response.isSuccess && response.data != null) {
        try {
          if (!isClosed) {
            emit(AppointmentsLoaded(response.data!));
          }
        } catch (e) {
          LoggerService.error('Error emitting AppointmentsLoaded: $e');
          if (!isClosed) {
            emit(AppointmentsError('Error processing appointments data: $e'));
          }
        }
      } else {
        if (!isClosed) {
          emit(
            AppointmentsError(
              response.message ??
                  'Failed to load appointments. Please try again.',
            ),
          );
        }
      }
    } catch (e) {
      LoggerService.error('Appointments load failed: $e');
      String errorMessage = 'Failed to load appointments. Please try again.';

      if (e.toString().contains('Connection failed') ||
          e.toString().contains('Network is unreachable')) {
        errorMessage = 'No internet connection. Please check your network.';
      } else if (e.toString().contains('timeout')) {
        errorMessage = 'Request timeout. Please try again.';
      }

      if (!isClosed) {
        emit(AppointmentsError(errorMessage));
      }
    }
  }

  Future<void> bookAppointment({
    required int doctorId,
    required DateTime startTime,
    String? notes,
  }) async {
    if (!isClosed) {
      emit(AppointmentsLoading());
    } else {
      LoggerService.debug('AppointmentsCubit is closed, skipping booking');
      return;
    }

    try {
      final response = await _appointmentsRepository.storeAppointment(
        doctorId: doctorId,
        startTime: startTime,
        notes: notes,
      );

      if (response.isSuccess && response.data != null) {
        if (!isClosed) {
          emit(AppointmentBooked(response.data!));
        }
      } else {
        if (!isClosed) {
          emit(
            AppointmentsError(
              response.message ??
                  'Failed to book appointment. Please try again.',
            ),
          );
        }
      }
    } catch (e) {
      String errorMessage = 'Failed to book appointment. Please try again.';

      if (e.toString().contains('Connection failed') ||
          e.toString().contains('Network is unreachable')) {
        errorMessage = 'No internet connection. Please check your network.';
      } else if (e.toString().contains('timeout')) {
        errorMessage = 'Request timeout. Please try again.';
      } else if (e.toString().contains('422')) {
        errorMessage = 'Appointment validation failed. Please check:';
        errorMessage += '\n• Doctor availability';
        errorMessage += '\n• Date and time format';
        errorMessage += '\n• Required fields';
      }

      if (!isClosed) {
        emit(AppointmentsError(errorMessage));
      }
    }
  }
}
