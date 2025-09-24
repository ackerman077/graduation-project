import 'package:flutter/foundation.dart';

class Logger {
  static void info(String message) {
    if (kDebugMode) print('[INFO] $message');
  }

  static void debug(String message) {
    if (kDebugMode) print('[DEBUG] $message');
  }

  static void warning(String message) {
    if (kDebugMode) print('[WARN] $message');
  }

  static void error(String message, [Object? error]) {
    if (kDebugMode) {
      print('[ERROR] $message');
      if (error != null) print('Details: $error');
    }
  }
}

class LoggerService {
  static void info(
    String message, [
    String? tag,
    Map<String, dynamic>? context,
  ]) {
    Logger.info(message);
  }

  static void debug(
    String message, [
    String? tag,
    Map<String, dynamic>? context,
  ]) {
    Logger.debug(message);
  }

  static void warning(
    String message, [
    String? tag,
    Map<String, dynamic>? context,
  ]) {
    Logger.warning(message);
  }

  static void error(
    String message, [
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  ]) {
    Logger.error(message, error);
  }

  static void logAuth(String message, [Map<String, dynamic>? context]) {
    Logger.info('[AUTH] $message');
  }

  static void logApiRequest(
    String method,
    String url, [
    dynamic data,
    Map<String, dynamic>? context,
  ]) {
    Logger.debug('API $method $url');
  }

  static void logApiResponse(
    String method,
    String url,
    int statusCode, [
    dynamic data,
    Map<String, dynamic>? context,
  ]) {
    Logger.debug('API $method $url -> $statusCode');
  }
}
