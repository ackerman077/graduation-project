import '../../../../core/networking/api_service_interface.dart';
import '../../../../core/models/api_response.dart';
import '../../../../core/services/logger_service.dart';
import '../../../auth/data/models/profile_update_request.dart';

abstract class ProfileRepository {
  Future<ApiResponse<dynamic>> getUserProfile();
  Future<ApiResponse<dynamic>> updateProfile(ProfileUpdateRequest request);
  Future<ApiResponse<dynamic>> updateProfilePartial(Map<String, dynamic> changedFields);
}

class ProfileRepositoryImpl implements ProfileRepository {
  final ApiServiceInterface _apiService;

  ProfileRepositoryImpl(this._apiService);

  @override
  Future<ApiResponse<dynamic>> getUserProfile() async {
    try {
      final response = await _apiService.getUserProfile();
      return response;
    } catch (e) {
      return ApiResponse.error('Failed to load profile: $e', code: 500);
    }
  }

  @override
  Future<ApiResponse<dynamic>> updateProfile(
    ProfileUpdateRequest request,
  ) async {
    LoggerService.logAuth(
      'ProfileRepository: updateProfile called with data: $request',
    );
    try {
      LoggerService.logAuth(
        'ProfileRepository: About to call _apiService.updateProfile()',
      );
      LoggerService.logAuth(
        'ProfileRepository: Converting request to JSON: ${request.toJson()}',
      );
      
      final response = await _apiService.updateProfile(request.toJson());
      LoggerService.logAuth(
        'ProfileRepository: API response received: ${response.status} - ${response.message}',
      );
      LoggerService.logAuth(
        'ProfileRepository: API response data: ${response.data}',
      );
      return response;
    } catch (e) {
      LoggerService.logAuth('ProfileRepository: Exception occurred: $e');
      LoggerService.logAuth('ProfileRepository: Exception stack trace: ${StackTrace.current}');
      return ApiResponse.error('Failed to update profile: $e', code: 500);
    }
  }

  @override
  Future<ApiResponse<dynamic>> updateProfilePartial(
    Map<String, dynamic> changedFields,
  ) async {
    LoggerService.logAuth(
      'ProfileRepository: updateProfilePartial called with changed fields: $changedFields',
    );
    try {
      LoggerService.logAuth(
        'ProfileRepository: About to call _apiService.updateProfile() with partial data',
      );
      
      final response = await _apiService.updateProfile(changedFields);
      LoggerService.logAuth(
        'ProfileRepository: Partial update API response: ${response.status} - ${response.message}',
      );
      LoggerService.logAuth(
        'ProfileRepository: Partial update API response data: ${response.data}',
      );
      return response;
    } catch (e) {
      LoggerService.logAuth('ProfileRepository: Partial update exception: $e');
      return ApiResponse.error('Failed to update profile partially: $e', code: 500);
    }
  }
}
