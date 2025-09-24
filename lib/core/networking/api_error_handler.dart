import 'package:dio/dio.dart';
import 'api_error_model.dart';

class ErrorHandler {
  static ApiErrorModel handle(dynamic error) {
    if (error is DioException) {
      switch (error.response?.statusCode) {
        case 400:
          return const ApiErrorModel(message: 'Bad request', code: 400);
        case 401:
          return const ApiErrorModel(message: 'Unauthorized', code: 401);
        case 403:
          return const ApiErrorModel(message: 'Forbidden', code: 403);
        case 404:
          return const ApiErrorModel(message: 'Not found', code: 404);
        case 422:
          return const ApiErrorModel(message: 'Invalid data', code: 422);
        case 500:
          return const ApiErrorModel(message: 'Server error', code: 500);
        default:
          return const ApiErrorModel(message: 'Something went wrong', code: 0);
      }
    }
    return const ApiErrorModel(message: 'Network error', code: 0);
  }
}
