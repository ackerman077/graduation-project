import '../../../../core/networking/api_service_interface.dart';
import '../../../../core/models/api_response.dart';
import '../../../../core/models/doctor.dart';
import '../../../../core/models/specialization.dart';
import '../../../../core/models/city.dart';

abstract class DoctorsRepository {
  Future<ApiResponse<List<Doctor>>> getAllDoctors();
  Future<ApiResponse<Doctor>> getDoctorById(int id);
  Future<ApiResponse<List<Doctor>>> filterDoctors({
    int? cityId,
    int? specializationId,
    double? minRating,
    bool? availableToday,
  });
  Future<ApiResponse<List<Doctor>>> searchDoctors(String query);
  Future<ApiResponse<List<Specialization>>> getAllSpecializations();
  Future<ApiResponse<Specialization>> getSpecializationById(int id);
  Future<ApiResponse<List<Doctor>>> getRecommendedDoctors();
  Future<ApiResponse<List<dynamic>>> getHomePage();
  Future<ApiResponse<List<City>>> getAllCities();
  Future<ApiResponse<List<Map<String, dynamic>>>> getAllGovernrates();
  Future<ApiResponse<List<City>>> getCitiesByGovernorate(int governorateId);
}

class DoctorsRepositoryImpl implements DoctorsRepository {
  final ApiServiceInterface _apiService;

  DoctorsRepositoryImpl(this._apiService);

  @override
  Future<ApiResponse<List<Doctor>>> getAllDoctors() async {
    try {
      return await _apiService.getAllDoctors();
    } catch (e) {
      return ApiResponse.error('Failed to get doctors: $e');
    }
  }

  @override
  Future<ApiResponse<Doctor>> getDoctorById(int id) async {
    try {
      return await _apiService.showDoctor(id);
    } catch (e) {
      return ApiResponse.error('Failed to get doctor: $e');
    }
  }

  @override
  Future<ApiResponse<List<Doctor>>> filterDoctors({
    int? cityId,
    int? specializationId,
    double? minRating,
    bool? availableToday,
  }) async {
    try {
      return await _apiService.filterDoctors(
        cityId: cityId,
        specializationId: specializationId,
        minRating: minRating,
        availableToday: availableToday,
      );
    } catch (e) {
      return ApiResponse.error('Failed to filter doctors: $e');
    }
  }

  @override
  Future<ApiResponse<List<Doctor>>> searchDoctors(String query) async {
    try {
      if (query.trim().isEmpty) {
        return ApiResponse.success(const []);
      }
      return await _apiService.searchDoctors(query.trim());
    } catch (e) {
      return ApiResponse.error('Failed to search doctors: $e');
    }
  }

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
  Future<ApiResponse<List<Doctor>>> getRecommendedDoctors() async {
    try {
      final response = await _apiService.filterDoctors(
        minRating: 4,
        availableToday: true,
      );

      if (response.isSuccess && response.data != null) {
        final sortedDoctors = List<Doctor>.from(
          response.data!,
          growable: false,
        );
        sortedDoctors.sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
        return ApiResponse.success(sortedDoctors.take(6).toList());
      }

      return response;
    } catch (e) {
      return ApiResponse.error('Failed to get recommended doctors: $e');
    }
  }

  @override
  Future<ApiResponse<List<dynamic>>> getHomePage() async {
    try {
      return await _apiService.getHomePage();
    } catch (e) {
      return ApiResponse.error('Failed to get home page data: $e');
    }
  }

  @override
  Future<ApiResponse<List<City>>> getAllCities() async {
    try {
      return await _apiService.getAllCities();
    } catch (e) {
      return ApiResponse.error('Failed to get cities: $e');
    }
  }

  @override
  Future<ApiResponse<List<Map<String, dynamic>>>> getAllGovernrates() async {
    try {
      return await _apiService.getAllGovernrates();
    } catch (e) {
      return ApiResponse.error('Failed to get governorates: $e');
    }
  }

  @override
  Future<ApiResponse<List<City>>> getCitiesByGovernorate(
    int governorateId,
  ) async {
    try {
      return await _apiService.getCitiesByGovernrate(governorateId);
    } catch (e) {
      return ApiResponse.error('Failed to get cities by governorate: $e');
    }
  }
}
