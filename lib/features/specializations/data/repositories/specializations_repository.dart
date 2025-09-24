import '../../../../core/networking/api_service_interface.dart';
import '../../../../core/models/api_response.dart';
import '../../../../core/models/specialization.dart';

import '../../../../core/models/doctor.dart';

abstract class SpecializationsRepository {
  Future<ApiResponse<List<Specialization>>> getAllSpecializations();
  Future<ApiResponse<Specialization>> getSpecializationById(int id);
  Future<ApiResponse<List<Doctor>>> getDoctorsBySpecialization(int specializationId);
}

class SpecializationsRepositoryImpl implements SpecializationsRepository {
  final ApiServiceInterface _apiService;

  SpecializationsRepositoryImpl(this._apiService);

  @override
  Future<ApiResponse<List<Specialization>>> getAllSpecializations() async {
    try {
      return await _apiService.getAllSpecializations();
    } catch (e) {
      return ApiResponse.error('Failed to get specializations: $e');
    }
  }

  @override
  Future<ApiResponse<Specialization>> getSpecializationById(int id) async {
    try {
      return await _apiService.showSpecialization(id);
    } catch (e) {
      return ApiResponse.error('Failed to get specialization: $e');
    }
  }

  @override
  Future<ApiResponse<List<Doctor>>> getDoctorsBySpecialization(int specializationId) async {
    try {
      final response = await _apiService.filterDoctors(
        specializationId: specializationId,
      );
      return response;
    } catch (e) {
      return ApiResponse.error('Failed to get doctors by specialization: $e');
    }
  }
}
