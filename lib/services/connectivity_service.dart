import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Monitors network connectivity and triggers sync on reconnect.
class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  bool _isOnline = false;
  bool get isOnline => _isOnline;

  /// Callback invoked when transitioning from offline → online.
  void Function()? onReconnect;

  /// Initialize the listener. Call once at app startup.
  Future<void> initialize() async {
    final result = await _connectivity.checkConnectivity();
    _isOnline = _hasConnection(result);

    _subscription = _connectivity.onConnectivityChanged.listen((result) {
      final wasOffline = !_isOnline;
      _isOnline = _hasConnection(result);

      if (wasOffline && _isOnline) {
        // Transitioned from offline → online
        onReconnect?.call();
      }
    });
  }

  bool _hasConnection(List<ConnectivityResult> results) {
    return results.any((r) =>
        r == ConnectivityResult.wifi ||
        r == ConnectivityResult.mobile ||
        r == ConnectivityResult.ethernet);
  }

  void dispose() {
    _subscription?.cancel();
  }
}
