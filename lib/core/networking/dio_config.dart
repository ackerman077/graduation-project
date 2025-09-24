import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/environment_config.dart';
import '../services/logger_service.dart';

class DioConfig {
  static Dio createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: EnvironmentConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {'Accept': 'application/json'},
      ),
    );

    dio.interceptors.addAll([
      _AuthInterceptor(),
      if (EnvironmentConfig.enableLogging) _LoggingInterceptor(),
      _ErrorInterceptor(),
      _RetryInterceptor(),
    ]);

    return dio;
  }
}

class _AuthInterceptor extends Interceptor {
  final _storage = const FlutterSecureStorage();

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.read(key: 'auth_token');
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      await _storage.delete(key: 'auth_token');
    }

    handler.next(err);
  }
}

class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (EnvironmentConfig.enableLogging) {
      LoggerService.logApiRequest(options.method, options.path, options.data);
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (EnvironmentConfig.enableLogging) {
      LoggerService.logApiResponse(
        response.requestOptions.method,
        response.requestOptions.path,
        response.statusCode ?? 0,
        response.data,
      );
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (EnvironmentConfig.enableLogging) {
      LoggerService.logApiResponse(
        err.requestOptions.method,
        err.requestOptions.path,
        err.response?.statusCode ?? 0,
        err.response?.data,
      );
    }
    handler.next(err);
  }
}

class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (EnvironmentConfig.enableLogging) {
      LoggerService.error(
        'ERROR INTERCEPTOR: ${err.message ?? 'Unknown error'}',
        null,
        null,
        {
          'statusCode': err.response?.statusCode,
          'endpoint': err.requestOptions.path,
        },
      );
    }

    handler.next(err);
  }
}

class _RetryInterceptor extends Interceptor {
  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (_shouldRetry(err) && err.requestOptions.extra['retryCount'] == null) {
      err.requestOptions.extra['retryCount'] = 1;

      try {
        final response = await Dio().fetch(err.requestOptions);
        handler.resolve(response);
        return;
      } catch (e) {
        LoggerService.debug('Retry failed: $e');
      }
    }

    handler.next(err);
  }

  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError;
  }
}
