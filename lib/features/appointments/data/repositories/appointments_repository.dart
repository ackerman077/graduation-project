import '../../../../core/networking/api_service_interface.dart';
import '../../../../core/models/api_response.dart';
import '../../../../core/models/appointment.dart';

abstract class AppointmentsRepository {
  Future<ApiResponse<List<Appointment>>> getAllAppointments();
  Future<ApiResponse<Map<String, dynamic>>> storeAppointment({
    required int doctorId,
    required DateTime startTime,
    String? notes,
  });
}

class AppointmentsRepositoryImpl implements AppointmentsRepository {
  final ApiServiceInterface _apiService;

  AppointmentsRepositoryImpl(this._apiService);

  @override
  Future<ApiResponse<List<Appointment>>> getAllAppointments() async {
    try {
      return await _apiService.getAllAppointments();
    } catch (e) {
      return ApiResponse.error('Failed to get appointments: $e');
    }
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> storeAppointment({
    required int doctorId,
    required DateTime startTime,
    String? notes,
  }) async {
    try {
      return await _apiService.storeAppointment(
        doctorId: doctorId,
        startTime: startTime,
        notes: notes,
      );
    } catch (e) {
      return ApiResponse.error('Failed to book appointment: $e');
    }
  }
}
