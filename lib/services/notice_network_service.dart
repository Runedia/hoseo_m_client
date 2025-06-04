import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

class NoticeNetworkService {
  static NoticeNetworkService? _instance;
  static NoticeNetworkService get instance => _instance ??= NoticeNetworkService._internal();
  
  NoticeNetworkService._internal();

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _isConnected = true;
  
  final StreamController<bool> _connectionController = StreamController<bool>.broadcast();
  Stream<bool> get connectionStream => _connectionController.stream;

  bool get isConnected => _isConnected;

  /// 네트워크 상태 감지 시작
  void startListening() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      final connected = results.isNotEmpty && !results.contains(ConnectivityResult.none);
      if (_isConnected != connected) {
        _isConnected = connected;
        _connectionController.add(_isConnected);
      }
    });
    
    // 초기 상태 확인
    _checkInitialConnection();
  }

  /// 네트워크 상태 감지 중지
  void stopListening() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
  }

  /// 현재 네트워크 연결 상태 확인
  Future<bool> checkConnection() async {
    final List<ConnectivityResult> connectivityResult = await Connectivity().checkConnectivity();
    final connected = connectivityResult.isNotEmpty && !connectivityResult.contains(ConnectivityResult.none);
    
    if (_isConnected != connected) {
      _isConnected = connected;
      _connectionController.add(_isConnected);
    }
    
    return _isConnected;
  }

  /// 초기 연결 상태 확인
  Future<void> _checkInitialConnection() async {
    await checkConnection();
  }

  /// 리소스 정리
  void dispose() {
    stopListening();
    _connectionController.close();
  }
}
