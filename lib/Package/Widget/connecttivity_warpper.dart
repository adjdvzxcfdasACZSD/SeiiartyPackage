import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import '../service/connectivity_service.dart';

class ConnectivityWrapper extends StatefulWidget {
  final Widget child;
  final bool showOfflineWidget;

  const ConnectivityWrapper({
    super.key,
    required this.child,
    this.showOfflineWidget = true,
  });

  @override
  _ConnectivityWrapperState createState() => _ConnectivityWrapperState();
}

class _ConnectivityWrapperState extends State<ConnectivityWrapper> {
  final InternetConnection _internetConnection = InternetConnection();

  @override
  void initState() {
    super.initState();
    _checkInitialConnection();
  }

  void _checkInitialConnection() async {
    bool isConnected = await _internetConnection.hasInternetAccess;
    if (!isConnected && widget.showOfflineWidget && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ConnectivityService.showOfflineDialog(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<InternetStatus>(
      stream: _internetConnection.onStatusChange,
      builder: (context, snapshot) {
        if (snapshot.hasData &&
            snapshot.data == InternetStatus.disconnected &&
            widget.showOfflineWidget) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              ConnectivityService.showOfflineDialog(context);
            }
          });
        }
        return widget.child;
      },
    );
  }
}