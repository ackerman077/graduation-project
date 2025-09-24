class NetworkHelper {
  static bool isNetworkError(dynamic error) {
    if (error == null) return false;
    final msg = error.toString().toLowerCase();
    return msg.contains('network') ||
        msg.contains('connection') ||
        msg.contains('timeout') ||
        msg.contains('dio');
  }

  static String getErrorMessage(dynamic error) {
    if (error == null) return 'Something went wrong';

    final msg = error.toString().toLowerCase();
    if (msg.contains('timeout')) return 'Request timeout. Try again.';
    if (msg.contains('connection')) {
      return 'Connection error. Check your internet.';
    }

    return 'Network error. Please try again.';
  }
}

class NetworkService {
  static final _instance = NetworkService._internal();
  factory NetworkService() => _instance;
  NetworkService._internal();

  bool get isConnected => true;

  bool isNetworkError(dynamic error) => NetworkHelper.isNetworkError(error);
  String getNetworkErrorMessage(dynamic error) =>
      NetworkHelper.getErrorMessage(error);
  bool isRetryableError(dynamic error) => NetworkHelper.isNetworkError(error);
  String getRetryMessage(dynamic error) => 'Try again?';
  String getErrorCategory(dynamic error) => 'Error';
  String getErrorIcon(String category) => 'ERROR';
  String getErrorColor(String category) => 'red';

  Map<String, dynamic> formatError(dynamic error) {
    return {
      'category': 'Error',
      'icon': 'ERROR',
      'color': 'red',
      'isRetryable': isRetryableError(error),
      'retryMessage': getRetryMessage(error),
      'networkError': isNetworkError(error),
    };
  }
}

final networkService = NetworkService();
