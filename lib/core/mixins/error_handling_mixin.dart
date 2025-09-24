import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/network_service.dart';
import '../services/logger_service.dart';
import '../networking/api_error_model.dart';

mixin ErrorHandlingMixin<T> on Cubit<T> {
  String handleError(dynamic error) {
    if (error == null) return 'Something went wrong';

    if (NetworkHelper.isNetworkError(error)) {
      return NetworkHelper.getErrorMessage(error);
    }

    if (error is ApiErrorModel) {
      return error.message ?? 'Something went wrong';
    }

    final errorString = error.toString().toLowerCase();
    if (errorString.contains('unauthorized')) return 'Please log in again';
    if (errorString.contains('timeout')) return 'Request timeout. Try again.';
    if (errorString.contains('server')) return 'Server error. Try again later.';

    return 'Something went wrong';
  }

  bool isRetryableError(dynamic error) {
    if (error == null) return false;
    return NetworkHelper.isNetworkError(error);
  }

  void logError(dynamic error, String operation) {
    LoggerService.error('Error in $operation: $error');
  }
}
