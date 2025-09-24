import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'logger_service.dart';

class ConnectivityService {
  static final _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  bool _isOnline = true;
  final List<Function(bool)> _listeners = [];

  bool get isOnline => _isOnline;

  void addListener(Function(bool) listener) {
    _listeners.add(listener);
  }

  void removeListener(Function(bool) listener) {
    _listeners.remove(listener);
  }

  void _notifyListeners(bool isOnline) {
    try {
      for (final listener in _listeners) {
        listener(isOnline);
      }
    } catch (e) {
      LoggerService.error(
        'Error notifying connectivity listeners',
        e,
        StackTrace.current,
      );
    }
  }

  Future<void> initialize() async {
    await _checkConnectivity();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _updateConnectionStatus,
    );
  }

  Future<void> _checkConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _updateConnectionStatus(results);
    } catch (e) {
      LoggerService.error('Error checking connectivity', e);
    }
  }

  Future<bool> checkConnectivityManually() async {
    try {
      final results = await _connectivity.checkConnectivity();
      return results.any((result) => result != ConnectivityResult.none);
    } catch (e) {
      return false;
    }
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    final isOnline = results.any((result) => result != ConnectivityResult.none);

    if (_isOnline != isOnline) {
      _isOnline = isOnline;
      _notifyListeners(isOnline);
    }
  }

  void dispose() {
    _connectivitySubscription?.cancel();
    _listeners.clear();
  }
}
