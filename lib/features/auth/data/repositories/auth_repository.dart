import 'package:dio/dio.dart';
import '../../../../core/networking/api_service_interface.dart';
import '../../../../core/models/api_response.dart';
import '../../../../core/services/logger_service.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';
import '../models/register_request.dart';
import '../models/user_profile.dart';

abstract class AuthRepository {
  Future<ApiResponse<LoginResponse>> login(LoginRequest request);
  Future<ApiResponse<LoginResponse>> register(RegisterRequest request);
  Future<ApiResponse<void>> logout();
  Future<ApiResponse<UserProfile>> getUserProfile();
}

class AuthRepositoryImpl implements AuthRepository {
  final ApiServiceInterface _apiService;

  const AuthRepositoryImpl(this._apiService);

  @override
  Future<ApiResponse<LoginResponse>> login(LoginRequest request) async {
    try {
      LoggerService.logAuth('Attempting login for user: ${request.email}');

      final response = await _apiService.login(
        email: request.email,
        password: request.password,
      );

      if (response.isSuccess && response.data != null) {
        final loginData = response.data!;

        String? token;
        String? username;

        final data = loginData['data'];

        if (data != null && data is Map<String, dynamic>) {
          token = data['token']?.toString();
          username = data['username']?.toString();
        }

        final loginResponseData = LoginData(
          username: username ?? '',
          token: token ?? '',
        );

        final loginResponse = LoginResponse(
          status: true,
          message: 'Login successful',
          code: 200,
          data: loginResponseData,
        );

        LoggerService.logAuth('Login succeeded for ${request.email}');

        return ApiResponse.success(loginResponse);
      } else {
        LoggerService.warning('Login failed: ${response.message}');
        return ApiResponse.error(response.message, code: response.code);
      }
    } on DioException catch (e) {
      LoggerService.error('Login DioException', e, StackTrace.current);
      return ApiResponse.error(
        e.response?.data?['message'] ?? 'Login failed',
        code: e.response?.statusCode ?? 500,
      );
    } catch (e) {
      LoggerService.error('Login unexpected error', e, StackTrace.current);
      return ApiResponse.error('Login failed: $e');
    }
  }

  @override
  Future<ApiResponse<LoginResponse>> register(RegisterRequest request) async {
    try {
      LoggerService.logAuth(
        'Attempting registration for user: ${request.email}',
      );

      LoggerService.logAuth('Sending registration data: ${request.toJson()}');

      final response = await _apiService.register(
        name: request.name,
        email: request.email,
        phone: request.phone,
        gender: request.gender,
        password: request.password,
        passwordConfirmation: request.passwordConfirmation,
      );

      LoggerService.logAuth('Registration response: ${response.data}');

      if (response.isSuccess && response.data != null) {
        final registerData = response.data!;

        String? token;
        String? username;

        final data = registerData['data'];

        if (data != null && data is Map<String, dynamic>) {
          token = data['token']?.toString();
          username = data['username']?.toString();
        }

        final loginResponseData = LoginData(
          username: username ?? '',
          token: token ?? '',
        );

        final loginResponse = LoginResponse(
          status: true,
          message: 'Registration successful',
          code: 200,
          data: loginResponseData,
        );

        LoggerService.logAuth('Registration succeeded for ${request.email}');

        return ApiResponse.success(loginResponse);
      } else {
        LoggerService.warning('Registration failed: ${response.message}');
        return ApiResponse.error(response.message, code: response.code);
      }
    } on DioException catch (e) {
      LoggerService.error('Registration DioException', e, StackTrace.current);
      return ApiResponse.error(
        e.response?.data?['message'] ?? 'Registration failed',
        code: e.response?.statusCode ?? 500,
      );
    } catch (e) {
      LoggerService.error(
        'Registration unexpected error',
        e,
        StackTrace.current,
      );
      return ApiResponse.error('Registration failed: $e');
    }
  }

  @override
  Future<ApiResponse<void>> logout() async {
    try {
      LoggerService.logAuth('Attempting logout');

      final response = await _apiService.logout();

      if (response.isSuccess) {
        LoggerService.logAuth('Logout API call successful');
        return ApiResponse.success(null, message: 'Logged out successfully');
      } else {
        LoggerService.warning('Logout API call failed: ${response.message}');
        return ApiResponse.error(
          response.message ?? 'Logout failed',
          code: response.code,
        );
      }
    } on DioException catch (e) {
      LoggerService.error('Logout DioException', e, StackTrace.current);
      return ApiResponse.error(
        e.response?.data?['message'] ?? 'Logout failed',
        code: e.response?.statusCode ?? 500,
      );
    } catch (e) {
      LoggerService.error('Logout unexpected error', e, StackTrace.current);
      return ApiResponse.error('Logout failed: $e');
    }
  }

  @override
  Future<ApiResponse<UserProfile>> getUserProfile() async {
    try {
      LoggerService.logAuth('Fetching user profile');

      final response = await _apiService.getUserProfile();

      if (response.isSuccess && response.data != null) {
        final userData = response.data;

        LoggerService.logAuth('=== USER PROFILE DEBUG ===');
        LoggerService.logAuth('User data type: ${userData.runtimeType}');
        LoggerService.logAuth('User data: $userData');
        LoggerService.logAuth('Response structure analysis:');

        if (userData is Map<String, dynamic>) {
          LoggerService.logAuth('Top-level keys: ${userData.keys.toList()}');
          for (final entry in userData.entries) {
            LoggerService.logAuth(
              '  ${entry.key}: ${entry.value} (${entry.value.runtimeType})',
            );
          }

          if (userData.containsKey('data')) {
            final dataField = userData['data'];
            LoggerService.logAuth('Data field type: ${dataField.runtimeType}');
            if (dataField is Map) {
              LoggerService.logAuth(
                'Data field keys: ${dataField.keys.toList()}',
              );
              for (final entry in dataField.entries) {
                LoggerService.logAuth(
                  '    ${entry.key}: ${entry.value} (${entry.value.runtimeType})',
                );
              }
            }
          }
        }

        if (userData is List) {
          LoggerService.logAuth(
            'Response is a List with ${userData.length} items',
          );
          for (int i = 0; i < userData.length; i++) {
            LoggerService.logAuth('Item $i: ${userData[i]}');
          }
        } else if (userData is Map) {
          LoggerService.logAuth(
            'Response is a Map with keys: ${userData.keys.toList()}',
          );
        }

        Map<String, dynamic> userMap;
        if (userData is Map<String, dynamic>) {
          if (userData.containsKey('data') && userData['data'] != null) {
            final nestedData = userData['data'];
            LoggerService.logAuth('Found nested data field: $nestedData');

            if (nestedData is Map<String, dynamic>) {
              userMap = nestedData;
              LoggerService.logAuth('Using nested user data: $userMap');
            } else if (nestedData is List && nestedData.isNotEmpty) {
              userMap = nestedData.first as Map<String, dynamic>;
              LoggerService.logAuth(
                'Extracted first user from nested list: $userMap',
              );
            } else {
              LoggerService.error(
                'Nested data field is not a valid user object',
              );
              return ApiResponse.error(
                'Invalid user profile data format',
                code: 500,
              );
            }
          } else {
            userMap = userData;
            LoggerService.logAuth('Using direct user data: $userMap');
          }
        } else if (userData is List && userData.isNotEmpty) {
          userMap = userData.first as Map<String, dynamic>;
          LoggerService.logAuth('Extracted first user from list: $userMap');
        } else {
          LoggerService.error(
            'Unexpected user data type: ${userData.runtimeType}',
          );
          return ApiResponse.error(
            'Invalid user profile data format',
            code: 500,
          );
        }

        LoggerService.logAuth('Parsing user data from: $userMap');

        final parsedId = _parseInt(userMap['id']);
        final parsedName = userMap['name']?.toString() ?? '';
        final parsedEmail = userMap['email']?.toString() ?? '';
        final parsedPhone = userMap['phone']?.toString() ?? '';
        final parsedGender = userMap['gender']?.toString();
        final parsedImage = userMap['image']?.toString();

        LoggerService.logAuth('Parsed values:');
        LoggerService.logAuth('  ID: ${userMap['id']} -> $parsedId');
        LoggerService.logAuth('  Name: ${userMap['name']} -> $parsedName');
        LoggerService.logAuth('  Email: ${userMap['email']} -> $parsedEmail');
        LoggerService.logAuth('  Phone: ${userMap['phone']} -> $parsedPhone');
        LoggerService.logAuth(
          '  Gender: ${userMap['gender']} -> $parsedGender',
        );
        LoggerService.logAuth('  Image: ${userMap['image']} -> $parsedImage');

        final user = UserProfile(
          id: parsedId ?? 0,
          name: parsedName,
          email: parsedEmail,
          phone: parsedPhone,
          gender: parsedGender ?? 'male',
          image: parsedImage,
          createdAt: userMap['created_at'] != null
              ? _parseDateTime(userMap['created_at'])
              : DateTime.now(),
          updatedAt: userMap['updated_at'] != null
              ? _parseDateTime(userMap['updated_at'])
              : DateTime.now(),
        );

        LoggerService.logAuth(
          'User profile fetched successfully: ${user.email}',
        );
        LoggerService.logAuth('=== END USER PROFILE DEBUG ===');
        return ApiResponse.success(user);
      } else {
        LoggerService.warning(
          'Failed to get user profile: ${response.message}',
        );
        return ApiResponse.error(
          response.message ?? 'Failed to get user profile',
          code: response.code,
        );
      }
    } on DioException catch (e) {
      LoggerService.error(
        'Get user profile DioException',
        e,
        StackTrace.current,
      );
      return ApiResponse.error(
        e.response?.data?['message'] ?? 'Failed to get user profile',
        code: e.response?.statusCode ?? 500,
      );
    } catch (e) {
      LoggerService.error(
        'Get user profile unexpected error',
        e,
        StackTrace.current,
      );
      return ApiResponse.error('Failed to get user profile: $e');
    }
  }

  DateTime _parseDateTime(dynamic dateValue) {
    try {
      if (dateValue is String) {
        return DateTime.parse(dateValue);
      } else if (dateValue is DateTime) {
        return dateValue;
      } else {
        return DateTime.now();
      }
    } catch (e) {
      LoggerService.warning(
        'Failed to parse date: $dateValue, using current time',
      );
      return DateTime.now();
    }
  }

  int? _parseInt(dynamic value) {
    try {
      if (value is int) {
        return value;
      } else if (value is String) {
        return int.parse(value);
      } else if (value is double) {
        return value.toInt();
      } else {
        return null;
      }
    } catch (e) {
      LoggerService.warning('Failed to parse integer: $value, returning null');
      return null;
    }
  }
}
