import 'dart:async';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import '../Core/general_const.dart';
import '../Widget/offline_widget.dart';

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final InternetConnection _internetConnection = InternetConnection();
  StreamController<bool> connectionStatusController = StreamController<bool>.broadcast();
  StreamSubscription<InternetStatus>? _subscription;

  Stream<bool> get connectionStatus => connectionStatusController.stream;

  // Initialize connectivity monitoring
  Future<void> initialize() async {
    await checkConnectivity();

    // Listen to internet connection changes
    _subscription = _internetConnection.onStatusChange.listen((InternetStatus status) {
      bool isConnected = status == InternetStatus.connected;
      _updateConnectionStatus(isConnected);
    });
  }

  // Check current connectivity
  Future<bool> checkConnectivity() async {
    try {
      bool isConnected = await _internetConnection.hasInternetAccess;
      _updateConnectionStatus(isConnected);
      return isConnected;
    } catch (e) {
      _updateConnectionStatus(false);
      return false;
    }
  }

  void _updateConnectionStatus(bool isConnected) {
    GeneralConstant.isConnected = isConnected;
    connectionStatusController.add(isConnected);
  }

  // Public function to check connectivity and show offline widget
  static Future<bool> checkConnection(BuildContext context) async {
    bool isConnected = await ConnectivityService().checkConnectivity();

    if (!isConnected && context.mounted) {
      showOfflineDialog(context);
    }

    return isConnected;
  }

  // Show offline dialog/overlay
  static void showOfflineDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: OfflineWidget(),
      ),
    );
  }

  void dispose() {
    _subscription?.cancel();
    connectionStatusController.close();
  }
}