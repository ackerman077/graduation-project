import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_endpoints.dart';
import 'api_service_interface.dart';
import '../models/api_response.dart';
import '../models/specialization.dart';
import '../models/doctor.dart';
import '../models/appointment.dart';
import '../models/city.dart';
import '../services/logger_service.dart';
import '../services/data_storage_service.dart';
import '../config/environment_config.dart';

class ApiServiceImpl implements ApiServiceInterface {
  final Dio _dio;
  final _storage = const FlutterSecureStorage();

  ApiServiceImpl(this._dio);

  Future<void> setAuthToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  Future<bool> testApiServer() async {
    try {
      await _dio.get('/');
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> clearAuthToken() async {
    await _storage.delete(key: 'auth_token');
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> register({
    required String name,
    required String email,
    required String phone,
    required int gender,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final jsonData = {
        'name': name,
        'email': email,
        'phone': phone,
        'gender': gender,
        'password': password,
        'password_confirmation': passwordConfirmation,
      };

      final response = await _dio.post(
        ApiEndpoints.register,
        data: jsonData,
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.data == null) {
        return ApiResponse.error(
          'Registration failed: No response data',
          code: 500,
        );
      }

      if (response.data is! Map<String, dynamic>) {
        return ApiResponse.error(
          'Registration failed: Invalid response format',
          code: 500,
        );
      }

      final responseData = response.data as Map<String, dynamic>;

      return ApiResponse<Map<String, dynamic>>(
        message: responseData['message'],
        data: responseData,
        status: responseData['status'] ?? false,
        code: responseData['code'] ?? 200,
      );
    } on DioException {
      try {
        final formData = FormData.fromMap({
          'name': name,
          'email': email,
          'phone': phone,
          'gender': gender,
          'password': password,
          'password_confirmation': passwordConfirmation,
        });

        final response = await _dio.post(ApiEndpoints.register, data: formData);

        if (response.data == null) {
          return ApiResponse.error(
            'Registration failed: No response data',
            code: 500,
          );
        }

        Map<String, dynamic> responseData;
        if (response.data is Map<String, dynamic>) {
          responseData = response.data as Map<String, dynamic>;
        } else if (response.data is FormData) {
          responseData = {}; // weird response but handle it
        } else {
          return ApiResponse.error(
            'Registration failed: Invalid response format',
            code: 500,
          );
        }

        return ApiResponse<Map<String, dynamic>>(
          message: responseData['message'],
          data: responseData,
          status: responseData['status'] ?? false,
          code: responseData['code'] ?? 200,
        );
      } catch (formDataError) {
        return ApiResponse.error(
          'Registration failed: ${formDataError.toString()}',
          code: 500,
        );
      }
    } catch (e) {
      return ApiResponse.error('Registration failed: $e');
    }
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> login({
    required String email,
    required String password,
  }) async {
    try {
      final jsonData = {'email': email, 'password': password};

      final response = await _dio.post(
        ApiEndpoints.login,
        data: jsonData,
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.data == null) {
        return ApiResponse.error('Login failed: No response data', code: 500);
      }

      if (response.data is! Map<String, dynamic>) {
        return ApiResponse.error(
          'Login failed: Invalid response format',
          code: 500,
        );
      }

      final responseData = response.data as Map<String, dynamic>;

      return ApiResponse<Map<String, dynamic>>(
        message: responseData['message'],
        data: responseData,
        status: responseData['status'] ?? false,
        code: responseData['code'] ?? 200,
      );
    } on DioException catch (e) {
      final String errorMessage = _extractErrorMessage(e);
      final int? statusCode = e.response?.statusCode;

      LoggerService.logAuth('JSON login failed, trying FormData', {
        'error': errorMessage,
        'statusCode': statusCode,
        'errorType': e.type.toString(),
      });

      if (statusCode == 401) {
        LoggerService.logAuth(
          'Authentication failed (401), not trying FormData fallback',
        );
        return ApiResponse.error(errorMessage, code: statusCode ?? 401);
      }

      try {
        final formData = FormData.fromMap({
          'email': email,
          'password': password,
        });

        LoggerService.logAuth('Trying FormData format for login', {
          'email': email,
          'endpoint': ApiEndpoints.login,
        });

        final response = await _dio.post(ApiEndpoints.login, data: formData);

        if (response.data == null) {
          LoggerService.error('Login response data is null');
          return ApiResponse.error('Login failed: No response data', code: 500);
        }

        Map<String, dynamic> responseData;
        if (response.data is Map<String, dynamic>) {
          responseData = response.data as Map<String, dynamic>;
        } else if (response.data is FormData) {
          LoggerService.warning('FormData response; converting to Map');
          responseData = {};
        } else {
          LoggerService.error(
            'Login response data is not a Map or FormData: ${response.data.runtimeType}',
            null,
            StackTrace.current,
          );
          return ApiResponse.error(
            'Login failed: Invalid response format',
            code: 500,
          );
        }

        return ApiResponse<Map<String, dynamic>>(
          message: responseData['message'],
          data: responseData,
          status: responseData['status'] ?? false,
          code: responseData['code'] ?? 200,
        );
      } catch (formDataError) {
        LoggerService.error(
          'Both JSON and FormData login failed',
          formDataError,
          StackTrace.current,
        );

        if (statusCode != null && statusCode >= 400 && statusCode < 500) {
          return ApiResponse.error(errorMessage, code: statusCode);
        }

        return ApiResponse.error(
          'Login failed: ${_extractErrorMessage(formDataError)}',
          code: 500,
        );
      }
    } catch (e) {
      LoggerService.error(
        'Login unexpected error: ${e.toString()}',
        null,
        StackTrace.current,
      );
      return ApiResponse.error('Login failed: ${_extractErrorMessage(e)}');
    }
  }

  @override
  Future<ApiResponse<void>> logout() async {
    try {
      await _dio.post(ApiEndpoints.logout);
      clearAuthToken();
      return ApiResponse.success(null, message: 'Logged out successfully');
    } on DioException catch (e) {
      return ApiResponse.error(
        e.response?.data['message'] ?? 'Logout failed',
        code: e.response?.statusCode ?? 500,
      );
    } catch (e) {
      return ApiResponse.error('Logout failed: $e');
    }
  }

  // Governrate Module
  @override
  Future<ApiResponse<List<Map<String, dynamic>>>> getAllGovernrates() async {
    try {
      final response = await _dio.get(ApiEndpoints.getAllGovernrates);

      if (response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;
        if (responseData.containsKey('data') && responseData['data'] != null) {
          final data = responseData['data'];
          if (data is List) {
            final governorates = data.cast<Map<String, dynamic>>();

            await DataStorageService.storeGovernorates(data);

            return ApiResponse.success(governorates);
          }
        }
      }

      return ApiResponse.fromJson(
        response.data,
        (data) => (data as List).cast<Map<String, dynamic>>(),
      );
    } on DioException catch (e) {
      final cachedData = await DataStorageService.getGovernorates();
      if (cachedData != null) {
        LoggerService.debug('Using cached governorates data');
        final governorates = cachedData.cast<Map<String, dynamic>>();
        return ApiResponse.success(governorates);
      }

      return ApiResponse.error(
        e.response?.data['message'] ?? 'Failed to get governrates',
        code: e.response?.statusCode ?? 500,
      );
    } catch (e) {
      return ApiResponse.error('Failed to get governrates: $e');
    }
  }

  // City Module
  @override
  Future<ApiResponse<List<City>>> getAllCities() async {
    try {
      final response = await _dio.get(ApiEndpoints.getAllCities);

      LoggerService.debug(
        'getAllCities response status: ${response.statusCode}',
      );
      LoggerService.debug('getAllCities response data: ${response.data}');

      if (response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;

        if (responseData.containsKey('data') && responseData['data'] != null) {
          final data = responseData['data'];
          if (data is List) {
            LoggerService.debug('Found data field with ${data.length} items');
            final cities = data.map((json) => City.fromJson(json)).toList();

            await DataStorageService.storeCities(data);

            return ApiResponse.success(cities);
          } else {
            LoggerService.error(
              'Data field is not a list: ${data.runtimeType}',
            );
            return ApiResponse.error('Invalid data format: expected list');
          }
        } else {
          LoggerService.error('No data field found in response');
          return ApiResponse.error('No data field in response');
        }
      } else if (response.data is List) {
        LoggerService.debug('Response is directly a list');
        final cities = (response.data as List)
            .map((json) => City.fromJson(json))
            .toList();
        return ApiResponse.success(cities);
      } else {
        LoggerService.error(
          '❌ Response is not a map or list: ${response.data.runtimeType}',
        );
        return ApiResponse.error('Invalid response format');
      }
    } on DioException catch (e) {
      LoggerService.error('getAllCities DioException: ${e.message}');

      final cachedData = await DataStorageService.getCities();
      if (cachedData != null) {
        LoggerService.debug('Using cached cities data');
        final cities = cachedData.map((json) => City.fromJson(json)).toList();
        return ApiResponse.success(cities);
      }

      return ApiResponse.error(
        e.response?.data['message'] ?? 'Failed to get cities',
        code: e.response?.statusCode ?? 500,
      );
    } catch (e) {
      LoggerService.error('getAllCities general error: ${e.toString()}');
      return ApiResponse.error('Failed to get cities: $e');
    }
  }

  @override
  Future<ApiResponse<List<City>>> getCitiesByGovernrate(
    int governrateId,
  ) async {
    try {
      final url = ApiEndpoints.buildUrl(
        ApiEndpoints.getCitiesByGovernrate,
        pathParams: {'id': governrateId},
      );
      final response = await _dio.get(url);

      LoggerService.debug(
        'getCitiesByGovernrate response status: ${response.statusCode}',
      );
      LoggerService.debug(
        'getCitiesByGovernrate response data: ${response.data}',
      );

      if (response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;

        if (responseData.containsKey('data') && responseData['data'] != null) {
          final data = responseData['data'];
          if (data is List) {
            LoggerService.debug('Found data field with ${data.length} items');
            final cities = data.map((json) => City.fromJson(json)).toList();
            return ApiResponse.success(cities);
          } else {
            LoggerService.error(
              'Data field is not a list: ${data.runtimeType}',
            );
            return ApiResponse.error('Invalid data format: expected list');
          }
        } else {
          LoggerService.error('No data field found in response');
          return ApiResponse.error('No data field in response');
        }
      } else if (response.data is List) {
        LoggerService.debug('Response is directly a list');
        final cities = (response.data as List)
            .map((json) => City.fromJson(json))
            .toList();
        return ApiResponse.success(cities);
      } else {
        LoggerService.error(
          '❌ Response is not a map or list: ${response.data.runtimeType}',
        );
        return ApiResponse.error('Invalid response format');
      }
    } on DioException catch (e) {
      LoggerService.error(
        '❌ [Appointly] getCitiesByGovernrate DioException: ${e.message}',
      );
      return ApiResponse.error(
        e.response?.data['message'] ?? 'Failed to get cities',
        code: e.response?.statusCode ?? 500,
      );
    } catch (e) {
      LoggerService.error(
        '❌ [Appointly] getCitiesByGovernrate general error: $e',
      );
      return ApiResponse.error('Failed to get cities: $e');
    }
  }

  @override
  Future<ApiResponse<List<Specialization>>> getAllSpecializations() async {
    try {
      final response = await _dio.get(ApiEndpoints.getAllSpecializations);

      LoggerService.debug(
        '�� [Appointly] getAllSpecializations response status: ${response.statusCode}',
      );
      LoggerService.debug(
        'getAllSpecializations response data: ${response.data}',
      );

      if (response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;

        if (responseData.containsKey('data') && responseData['data'] != null) {
          final data = responseData['data'];

          if (data is List) {
            LoggerService.debug('✅ Found data field with ${data.length} items');
            final specializations = data
                .map((json) => Specialization.fromJson(json))
                .toList();

            await DataStorageService.storeSpecializations(data);

            return ApiResponse.success(specializations);
          } else {
            LoggerService.debug(
              '❌ Data field is not a list: ${data.runtimeType}',
            );
            return ApiResponse.error('Invalid data format: expected list');
          }
        } else {
          LoggerService.debug('❌ No data field found in response');
          return ApiResponse.error('No data field in response');
        }
      } else {
        LoggerService.debug(
          '❌ Response is not a map: ${response.data.runtimeType}',
        );
        return ApiResponse.error('Invalid response format');
      }
    } on DioException catch (e) {
      LoggerService.debug('getAllSpecializations DioException: ${e.message}');

      final cachedData = await DataStorageService.getSpecializations();
      if (cachedData != null) {
        LoggerService.debug('Using cached specializations data');
        final specializations = cachedData
            .map((json) => Specialization.fromJson(json))
            .toList();
        return ApiResponse.success(specializations);
      }

      return ApiResponse.error(
        e.response?.data['message'] ?? 'Failed to get specializations',
        code: e.response?.statusCode ?? 500,
      );
    } catch (e) {
      LoggerService.debug('getAllSpecializations general error: $e');
      return ApiResponse.error('Failed to get specializations: $e');
    }
  }

  @override
  Future<ApiResponse<Specialization>> showSpecialization(int id) async {
    try {
      final url = ApiEndpoints.buildUrl(
        ApiEndpoints.showSpecialization,
        pathParams: {'id': id},
      );

      LoggerService.debug('Calling specialization endpoint: $url');
      LoggerService.debug('Specialization ID: $id');

      final response = await _dio.get(url);

      LoggerService.debug('Response status: ${response.statusCode}');
      LoggerService.debug('Response data: ${response.data}');

      if (response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;

        if (responseData.containsKey('data') && responseData['data'] != null) {
          final data = responseData['data'];

          if (data is Map<String, dynamic>) {
            LoggerService.debug('✅ Found data field with specialization data');
            final specialization = Specialization.fromJson(data);
            return ApiResponse.success(specialization);
          } else {
            LoggerService.debug(
              '❌ Data field is not a map: ${data.runtimeType}',
            );
            return ApiResponse.error(
              'Invalid data format: expected specialization object',
            );
          }
        } else {
          LoggerService.debug('❌ No data field found in response');
          return ApiResponse.error('No data field in response');
        }
      } else {
        LoggerService.debug(
          '❌ Response is not a map: ${response.data.runtimeType}',
        );
        return ApiResponse.error('Invalid response format');
      }
    } on DioException catch (e) {
      LoggerService.debug('DioException: ${e.message}');
      LoggerService.debug('Response status: ${e.response?.statusCode}');
      LoggerService.debug('Response data: ${e.response?.data}');

      return ApiResponse.error(
        e.response?.data['message'] ?? 'Failed to get specialization',
        code: e.response?.statusCode ?? 500,
      );
    } catch (e) {
      LoggerService.debug('General error: $e');
      return ApiResponse.error('Failed to get specialization: $e');
    }
  }

  @override
  Future<ApiResponse<List<Doctor>>> getAllDoctors() async {
    try {
      LoggerService.debug('API Call: GET ${ApiEndpoints.getAllDoctors}');
      final response = await _dio.get(ApiEndpoints.getAllDoctors);
      LoggerService.debug('✅ API Response Status: ${response.statusCode}');
      LoggerService.debug(
        '✅ API Response Data Type: ${response.data.runtimeType}',
      );
      LoggerService.debug('✅ API Response Data: ${response.data}');

      if (response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;
        LoggerService.debug('✅ Response structure: ${responseData.keys}');

        if (responseData.containsKey('data')) {
          final data = responseData['data'];
          LoggerService.debug('✅ Data field type: ${data.runtimeType}');
          LoggerService.debug('✅ Data field content: $data');

          if (data is List) {
            LoggerService.debug('✅ Data is a list with ${data.length} items');
            if (data.isNotEmpty) {
              LoggerService.debug(
                '✅ First item type: ${data.first.runtimeType}',
              );
              LoggerService.debug('✅ First item: ${data.first}');
            }
          }
        }
      }

      List<Doctor> doctors = [];

      if (response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;

        if (responseData.containsKey('data')) {
          final data = responseData['data'];
          if (data is List) {
            LoggerService.debug('✅ Found data field with ${data.length} items');
            doctors = data.map((json) => Doctor.fromJson(json)).toList();
          }
        } else if (responseData.containsKey('doctors')) {
          final doctorsData = responseData['doctors'];
          if (doctorsData is List) {
            LoggerService.debug(
              '✅ Found doctors field with ${doctorsData.length} items',
            );
            doctors = doctorsData.map((json) => Doctor.fromJson(json)).toList();
          }
        } else {
          LoggerService.debug('✅ Trying to parse entire response as list');
          if (responseData.values.first is List) {
            final listData = responseData.values.first as List;
            doctors = listData.map((json) => Doctor.fromJson(json)).toList();
          }
        }
      } else if (response.data is List) {
        LoggerService.debug('✅ Response is directly a list');
        final listData = response.data as List;
        doctors = listData.map((json) => Doctor.fromJson(json)).toList();
      }

      LoggerService.debug('📊 Parsed doctors count: ${doctors.length}');

      if (doctors.isNotEmpty) {
        return ApiResponse.success(doctors);
      } else {
        return ApiResponse.error('No doctors found in response');
      }
    } on DioException catch (e) {
      LoggerService.debug(
        '❌ DioException: ${e.message} - ${e.response?.statusCode}',
      );
      return ApiResponse.error(
        e.response?.data['message'] ?? 'Failed to get doctors',
        code: e.response?.statusCode ?? 500,
      );
    } catch (e) {
      LoggerService.debug('❌ General Exception: $e');
      LoggerService.debug('❌ Exception details: ${e.toString()}');
      return ApiResponse.error('Failed to get doctors: $e');
    }
  }

  @override
  Future<ApiResponse<Doctor>> showDoctor(int id) async {
    try {
      final url = ApiEndpoints.buildUrl(
        ApiEndpoints.showDoctor,
        pathParams: {'id': id},
      );
      final response = await _dio.get(url);
      return ApiResponse.fromJson(
        response.data,
        (data) => Doctor.fromJson(data),
      );
    } on DioException catch (e) {
      return ApiResponse.error(
        e.response?.data['message'] ?? 'Failed to get doctor',
        code: e.response?.statusCode ?? 500,
      );
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
      LoggerService.debug(
        'Filtering doctors with params: cityId=$cityId, specializationId=$specializationId, minRating=$minRating, availableToday=$availableToday',
      );

      final queryParams = <String, dynamic>{};
      if (cityId != null) queryParams['city'] = cityId;

      final response = await _dio.get(
        ApiEndpoints.filterDoctors,
        queryParameters: queryParams,
      );

      LoggerService.debug('Filter response status: ${response.statusCode}');
      LoggerService.debug('Filter response data: ${response.data}');

      if (response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;

        if (responseData.containsKey('data') && responseData['data'] != null) {
          final data = responseData['data'];
          if (data is List) {
            LoggerService.debug('✅ Found data field with ${data.length} items');
            final doctors = data.map((json) => Doctor.fromJson(json)).toList();
            return ApiResponse.success(doctors);
          } else {
            LoggerService.debug(
              '❌ Data field is not a list: ${data.runtimeType}',
            );
            return ApiResponse.error('Invalid data format: expected list');
          }
        } else {
          LoggerService.debug('❌ No data field found in response');
          return ApiResponse.error('No data field in response');
        }
      } else if (response.data is List) {
        LoggerService.debug('✅ Response is directly a list');
        final doctors = (response.data as List)
            .map((json) => Doctor.fromJson(json))
            .toList();
        return ApiResponse.success(doctors);
      } else {
        LoggerService.debug(
          '❌ Response is not a map or list: ${response.data.runtimeType}',
        );
        return ApiResponse.error('Invalid response format');
      }
    } on DioException catch (e) {
      LoggerService.debug(
        '❌ [Appointly] Filter DioException: ${e.message} - ${e.response?.statusCode}',
      );
      return ApiResponse.error(
        e.response?.data['message'] ?? 'Failed to filter doctors',
        code: e.response?.statusCode ?? 500,
      );
    } catch (e) {
      LoggerService.debug('❌ [Appointly] Filter general error: $e');
      return ApiResponse.error('Failed to filter doctors: $e');
    }
  }

  @override
  Future<ApiResponse<List<Doctor>>> searchDoctors(String query) async {
    try {
      LoggerService.debug('Searching doctors with query: $query');

      final response = await _dio.get(
        ApiEndpoints.searchDoctors,
        queryParameters: {'name': query},
      );

      LoggerService.debug('Search response status: ${response.statusCode}');
      LoggerService.debug('Search response data: ${response.data}');

      if (response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;

        if (responseData.containsKey('data') && responseData['data'] != null) {
          final data = responseData['data'];
          if (data is List) {
            LoggerService.debug('✅ Found data field with ${data.length} items');
            final doctors = data.map((json) => Doctor.fromJson(json)).toList();
            return ApiResponse.success(doctors);
          } else {
            LoggerService.debug(
              '❌ Data field is not a list: ${data.runtimeType}',
            );
            return ApiResponse.error('Invalid data format: expected list');
          }
        } else {
          LoggerService.debug('❌ No data field found in response');
          return ApiResponse.error('No data field in response');
        }
      } else if (response.data is List) {
        LoggerService.debug('✅ Response is directly a list');
        final doctors = (response.data as List)
            .map((json) => Doctor.fromJson(json))
            .toList();
        return ApiResponse.success(doctors);
      } else {
        LoggerService.debug(
          '❌ Response is not a map or list: ${response.data.runtimeType}',
        );
        return ApiResponse.error('Invalid response format');
      }
    } on DioException catch (e) {
      LoggerService.debug(
        '❌ [Appointly] Search DioException: ${e.message} - ${e.response?.statusCode}',
      );
      return ApiResponse.error(
        e.response?.data['message'] ?? 'Failed to search doctors',
        code: e.response?.statusCode ?? 500,
      );
    } catch (e) {
      LoggerService.debug('❌ [Appointly] Search general error: $e');
      return ApiResponse.error('Failed to search doctors: $e');
    }
  }


  @override
  Future<ApiResponse<List<Appointment>>> getAllAppointments() async {
    try {
      final response = await _dio.get(ApiEndpoints.getAllAppointments);

      LoggerService.debug('=== API Response for getAllAppointments ===');
      LoggerService.debug('Status Code: ${response.statusCode}');
      LoggerService.debug('Response Data Type: ${response.data.runtimeType}');
      LoggerService.debug('Response Data: ${response.data}');

      if (response.data is Map) {
        LoggerService.debug(
          'Response Keys: ${(response.data as Map).keys.toList()}',
        );
        if (response.data['data'] != null) {
          LoggerService.debug(
            'Data Field Type: ${response.data['data'].runtimeType}',
          );
          LoggerService.debug('Data Field: ${response.data['data']}');
        }
      }
      LoggerService.debug('==========================================');

      return ApiResponse.fromJson(response.data, (data) {
        if (data is List) {
          LoggerService.debug('Parsing ${data.length} appointments');
          return data.map((json) {
            try {
              LoggerService.debug('=== RAW APPOINTMENT DATA ===');
              LoggerService.debug('Appointment ID: ${json['id']}');
              LoggerService.debug('Available fields: ${json.keys.toList()}');
              LoggerService.debug(
                'Appointment Time Field: ${json['appointment_time']}',
              );
              LoggerService.debug('Start Time Field: ${json['start_time']}');
              LoggerService.debug('DateTime Field: ${json['datetime']}');
              LoggerService.debug(
                'Appointment Date Field: ${json['appointment_date']}',
              );
              LoggerService.debug('Date Field: ${json['date']}');
              LoggerService.debug('Time Field: ${json['time']}');
              LoggerService.debug('Created At: ${json['created_at']}');
              LoggerService.debug('Updated At: ${json['updated_at']}');
              LoggerService.debug('Full JSON: $json');
              LoggerService.debug('=============================');

              return Appointment.fromJson(json);
            } catch (e) {
              LoggerService.error('Error parsing appointment: $e');
              LoggerService.error('Appointment JSON: $json');
              return Appointment(
                id: json['id']?.toInt() ?? 0,
                doctorId: json['doctor_id']?.toInt() ?? 0,
                doctorName: 'Unknown Doctor',
                startTime: DateTime.now(),
                status: 'pending',
              );
            }
          }).toList();
        } else {
          LoggerService.debug('Unexpected data type: ${data.runtimeType}');
          return <Appointment>[];
        }
      });
    } on DioException catch (e) {
      LoggerService.debug('DioException in getAllAppointments: ${e.message}');
      LoggerService.debug('Response data: ${e.response?.data}');
      return ApiResponse.error(
        e.response?.data['message'] ?? 'Failed to get appointments',
        code: e.response?.statusCode ?? 500,
      );
    } catch (e) {
      LoggerService.debug('General error in getAllAppointments: $e');
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
      LoggerService.debug('storeAppointment - Preparing data', 'API', {
        'doctorId': doctorId,
        'startTime': startTime.toIso8601String(),
        'notes': notes,
      });

      final vCareFormat =
          '${startTime.year}-${startTime.month.toString().padLeft(2, '0')}-${startTime.day.toString().padLeft(2, '0')} ${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';

      LoggerService.debug('VCare format created: $vCareFormat', 'API');

      final formDataFields = {
        'doctor_id': doctorId.toString(),
        'start_time': vCareFormat,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      };

      LoggerService.debug('FormData fields to send: $formDataFields', 'API');

      LoggerService.debug(
        'Using FormData format for appointment booking',
        'API',
        {
          'doctorId': doctorId,
          'startTime': vCareFormat,
          'endpoint': ApiEndpoints.storeAppointment,
        },
      );

      try {
        final formData = FormData.fromMap(formDataFields);

        LoggerService.debug(
          'FormData created with fields: ${formData.fields.map((f) => '${f.key}=${f.value}').join(', ')}',
          'API',
        );

        final response = await _dio.post(
          ApiEndpoints.storeAppointment,
          data: formData,
        );

        LoggerService.info('storeAppointment success', 'API', {
          'statusCode': response.statusCode,
          'responseData': response.data,
        });

        return ApiResponse.fromJson(
          response.data,
          (data) => data as Map<String, dynamic>,
        );
      } catch (e) {
        LoggerService.error('storeAppointment error: $e');
        rethrow;
      }
    } on DioException catch (e) {
      LoggerService.error(
        'storeAppointment DioException: ${e.message}',
        e,
        null,
        {
          'statusCode': e.response?.statusCode,
          'responseData': e.response?.data,
          'requestData': e.requestOptions.data,
        },
      );

      String errorMessage = 'Failed to create appointment';
      if (e.response?.statusCode == 422) {
        LoggerService.error('422 Response Details:');
        LoggerService.error('Headers: ${e.response?.headers}');
        LoggerService.error('Request Data: ${e.requestOptions.data}');
        LoggerService.error('Request Headers: ${e.requestOptions.headers}');

        final responseData = e.response?.data;
        LoggerService.error('Full Response Data: $responseData');

        if (responseData is Map) {
          final errors = responseData['errors'];
          final message = responseData['message'];
          if (errors != null) {
            errorMessage = 'Validation errors: $errors';
          } else if (message != null) {
            errorMessage = message;
          } else {
            errorMessage =
                'Invalid appointment data. Please check your information.';
          }
        } else {
          errorMessage =
              'Invalid appointment data. Please check your information.';
        }
      } else {
        errorMessage =
            e.response?.data['message'] ?? 'Failed to create appointment';
      }

      return ApiResponse.error(
        errorMessage,
        code: e.response?.statusCode ?? 500,
      );
    } catch (e) {
      LoggerService.error(
        'storeAppointment general error: ${e.toString()}',
        null,
      );
      return ApiResponse.error('Failed to create appointment: $e');
    }
  }

  @override
  Future<ApiResponse<dynamic>> getUserProfile() async {
    try {
      final response = await _dio.get(ApiEndpoints.getUserProfile);

      if (response.data is List && (response.data as List).isNotEmpty) {
        final userData = (response.data as List).first;
        return ApiResponse.fromJson(
          response.data,
          (data) => userData,
        );
      } else if (response.data is Map) {
        return ApiResponse.fromJson(response.data, (data) => data);
      } else {
        return ApiResponse.error('Invalid profile data format', code: 400);
      }
    } on DioException catch (e) {
      return ApiResponse.error(
        e.response?.data['message'] ?? 'Failed to get user profile',
        code: e.response?.statusCode ?? 500,
      );
    } catch (e) {
      return ApiResponse.error('Failed to get user profile: $e');
    }
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> updateProfile(
    Map<String, dynamic> data,
  ) async {
    LoggerService.logAuth('updateProfile called', {
      'data': data,
      'endpoint': ApiEndpoints.updateProfile,
    });

    try {
      LoggerService.logAuth('Starting data preparation');

      dynamic requestData;
      final Map<String, String> headers = <String, String>{};

      try {
        LoggerService.logAuth('Trying JSON format first');
        requestData = data;
        headers['Content-Type'] = 'application/json';
        LoggerService.logAuth('Using JSON format');
      } catch (e) {
        LoggerService.logAuth('JSON failed, using FormData');
        requestData = FormData.fromMap(data);
        LoggerService.logAuth('FormData created successfully');
        final formData = requestData as FormData;
        LoggerService.logAuth('FormData details', {
          'fields': formData.fields.map((f) => '${f.key}: ${f.value}').toList(),
          'fieldsCount': formData.fields.length,
          'boundary': formData.boundary,
        });
      }

      LoggerService.logAuth('Sending data', {
        'data': data,
        'endpoint': ApiEndpoints.updateProfile,
        'method': 'POST',
        'fullUrl':
            '${EnvironmentConfig.apiBaseUrl}${ApiEndpoints.updateProfile}',
      });

      LoggerService.logAuth('Executing Dio POST request');
      Response response;
      try {
        LoggerService.logAuth('Trying PATCH method first');
        response = await _dio.patch(
          ApiEndpoints.updateProfile,
          data: requestData,
          options: Options(headers: headers),
        );
        LoggerService.logAuth('PATCH request successful');
      } on DioException catch (patchError) {
        if (patchError.response?.statusCode == 405) {
          LoggerService.logAuth('PATCH not supported, trying POST');
          response = await _dio.post(
            ApiEndpoints.updateProfile,
            data: requestData,
            options: Options(headers: headers),
          );
          LoggerService.logAuth('POST request successful');
        } else {
          rethrow;
        }
      }

      LoggerService.logAuth('POST request completed successfully');

      LoggerService.logAuth('Response received', {
        'statusCode': response.statusCode,
        'data': response.data,
        'headers': response.headers.toString(),
      });

      LoggerService.logAuth('Creating ApiResponse from JSON');
      final apiResponse = ApiResponse.fromJson(
        response.data,
        (data) => data as Map<String, dynamic>,
      );
      LoggerService.logAuth('ApiResponse created successfully', {
        'status': apiResponse.status,
      });
      return apiResponse;
    } on DioException catch (e) {
      LoggerService.logAuth('DioException occurred', {
        'message': e.message,
        'statusCode': e.response?.statusCode,
        'data': e.response?.data,
        'type': e.type.toString(),
        'error': e.error,
      });
      return ApiResponse.error(
        e.response?.data['message'] ?? 'Failed to update profile',
        code: e.response?.statusCode ?? 500,
      );
    } catch (e) {
      LoggerService.logAuth('General exception', {
        'error': e.toString(),
        'stackTrace': StackTrace.current.toString(),
      });
      return ApiResponse.error('Failed to update profile: $e');
    }
  }

  @override
  Future<ApiResponse<List<dynamic>>> getHomePage() async {
    try {
      final response = await _dio.get(ApiEndpoints.getHomePage);
      return ApiResponse.fromJson(
        response.data,
        (data) => (data as List).cast<dynamic>(),
      );
    } on DioException catch (e) {
      return ApiResponse.error(
        e.response?.data['message'] ?? 'Failed to get home page data',
        code: e.response?.statusCode ?? 500,
      );
    } catch (e) {
      return ApiResponse.error('Failed to get home page data: $e');
    }
  }

  String _extractErrorMessage(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
          return 'Connection timeout. Please check your internet connection.';
        case DioExceptionType.sendTimeout:
          return 'Request timeout. Please try again.';
        case DioExceptionType.receiveTimeout:
          return 'Server response timeout. Please try again.';
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          final responseData = error.response?.data;

          if (statusCode == 401) {
            if (responseData is Map<String, dynamic>) {
              final message = responseData['message'];
              if (message != null && message.toString().isNotEmpty) {
                return message.toString();
              }
            }
            return 'Invalid email or password. Please check your credentials.';
          } else if (statusCode == 422) {
            if (responseData is Map<String, dynamic>) {
              final message = responseData['message'];
              if (message != null) {
                return message.toString();
              }
              final errors = responseData['errors'];
              if (errors is Map<String, dynamic>) {
                final firstError = errors.values.first;
                if (firstError is List && firstError.isNotEmpty) {
                  return firstError.first.toString();
                }
              }
            }
            return 'Invalid input. Please check your email and password.';
          } else if (statusCode == 404) {
            return 'Service not found. Please try again later.';
          } else if (statusCode == 500) {
            return 'Server error. Please try again later.';
          } else if (responseData is Map<String, dynamic>) {
            final message = responseData['message'];
            if (message != null) {
              return message.toString();
            }
          }
          return 'Login failed. Please check your credentials and try again.';
        case DioExceptionType.cancel:
          return 'Request was cancelled.';
        case DioExceptionType.connectionError:
          return 'Connection error. Please check your internet connection.';
        case DioExceptionType.badCertificate:
          return 'Security certificate error. Please try again.';
        case DioExceptionType.unknown:
          return 'Network error. Please check your internet connection and try again.';
      }
    } else if (error is Exception) {
      return 'An error occurred: ${error.toString()}';
    } else {
      return 'An unexpected error occurred: ${error.toString()}';
    }
  }
}
