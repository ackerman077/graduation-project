import 'dart:developer';
import '../../../../core/networking/api_service_interface.dart';
import '../../../../core/models/api_response.dart';
import '../../../../core/models/doctor.dart';
import '../../../../core/models/specialization.dart';


abstract class HomeRepository {
  Future<ApiResponse<List<dynamic>>> getHomePage();
  Future<ApiResponse<List<Doctor>>> getRecommendedDoctors();
  Future<ApiResponse<List<Specialization>>> getFeaturedSpecializations();
}

class HomeRepositoryImpl implements HomeRepository {
  final ApiServiceInterface _apiService;

  HomeRepositoryImpl(this._apiService);

  @override
  Future<ApiResponse<List<dynamic>>> getHomePage() async {
    try {
      return await _apiService.getHomePage();
    } catch (e) {
      return ApiResponse.error('Failed to get home page data: $e');
    }
  }

  @override
  Future<ApiResponse<List<Doctor>>> getRecommendedDoctors() async {
    try {
      log('HomeRepository: Getting recommended doctors...');

      final response = await _apiService.getAllDoctors();
      log('HomeRepository: API response success: ${response.isSuccess}');
      log(
        'HomeRepository: API response data count: ${response.data?.length ?? 0}',
      );

      if (response.isSuccess && response.data != null) {
        try {
          final sortedDoctors = List<Doctor>.from(
            response.data!,
            growable: false,
          );

          log(
            'HomeRepository: Sorting ${sortedDoctors.length} doctors by rating...',
          );

          sortedDoctors.sort(
            (a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0),
          );
          final recommended = sortedDoctors.take(6).toList();

          log(
            'HomeRepository: Using new Doctor model system for consistent image handling',
          );

          log(
            'HomeRepository: Returning ${recommended.length} recommended doctors with local images',
          );
          return ApiResponse.success(recommended);
        } catch (e) {
          log('HomeRepository: Error processing doctors data: $e');
          return ApiResponse.error('Failed to process doctors data: $e');
        }
      }

      log(
        'HomeRepository: API response not successful, returning: ${response.message}',
      );
      return response;
    } catch (e) {
      log('HomeRepository: Exception occurred: $e');
      return ApiResponse.error('Failed to get recommended doctors: $e');
    }
  }

  @override
  Future<ApiResponse<List<Specialization>>> getFeaturedSpecializations() async {
    try {
      final response = await _apiService.getAllSpecializations();

      if (response.isSuccess && response.data != null) {
        final featured = response.data!.take(6).toList();
        return ApiResponse.success(featured);
      }

      return response;
    } catch (e) {
      return ApiResponse.error('Failed to get featured specializations: $e');
    }
  }
}
