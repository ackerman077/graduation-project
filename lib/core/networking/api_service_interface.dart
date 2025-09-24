import '../models/api_response.dart';
import '../models/specialization.dart';
import '../models/doctor.dart';
import '../models/appointment.dart';
import '../models/city.dart';

abstract class ApiServiceInterface {
  Future<ApiResponse<Map<String, dynamic>>> register({
    required String name,
    required String email,
    required String phone,
    required int gender,
    required String password,
    required String passwordConfirmation,
  });

  Future<ApiResponse<Map<String, dynamic>>> login({
    required String email,
    required String password,
  });

  Future<ApiResponse<void>> logout();
  Future<ApiResponse<List<Map<String, dynamic>>>> getAllGovernrates();
  Future<ApiResponse<List<City>>> getAllCities();
  Future<ApiResponse<List<City>>> getCitiesByGovernrate(int governrateId);
  Future<ApiResponse<List<Specialization>>> getAllSpecializations();
  Future<ApiResponse<Specialization>> showSpecialization(int id);
  Future<ApiResponse<List<Doctor>>> getAllDoctors();
  Future<ApiResponse<Doctor>> showDoctor(int id);
  Future<ApiResponse<List<Doctor>>> filterDoctors({
    int? cityId,
    int? specializationId,
    double? minRating,
    bool? availableToday,
  });
  Future<ApiResponse<List<Doctor>>> searchDoctors(String query);
  Future<ApiResponse<List<Appointment>>> getAllAppointments();
  Future<ApiResponse<Map<String, dynamic>>> storeAppointment({
    required int doctorId,
    required DateTime startTime,
    String? notes,
  });
  Future<ApiResponse<dynamic>> getUserProfile();
  Future<ApiResponse<Map<String, dynamic>>> updateProfile(
    Map<String, dynamic> data,
  );
  Future<ApiResponse<List<dynamic>>> getHomePage();
}
