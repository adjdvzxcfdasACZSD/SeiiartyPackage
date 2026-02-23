import 'dart:async';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import '../Core/app_theme.dart';


class OfflineWidget extends StatefulWidget {
  const OfflineWidget({super.key});

  @override
  _OfflineWidgetState createState() => _OfflineWidgetState();
}

class _OfflineWidgetState extends State<OfflineWidget> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  bool _isChecking = false;
  StreamSubscription<InternetStatus>? _subscription;

  @override
  void initState() {
    super.initState();

    // Main animation for WiFi icon
    _animationController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    // Pulse animation for background
    _pulseController = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Listen for connectivity changes
    _subscription = InternetConnection().onStatusChange.listen((InternetStatus status) {
      if (status == InternetStatus.connected && mounted) {
        // Add a small delay to ensure connection is stable
        Future.delayed(Duration(milliseconds: 500), () {
          if (mounted) {
            Navigator.of(context).pop();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.darkBackground,
              AppTheme.darkCardColor.withOpacity(0.5),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(size.width * 0.08),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated WiFi Off Icon with pulse effect
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Pulse background
                      AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _pulseAnimation.value,
                            child: Container(
                              width: size.width * 0.35,
                              height: size.width * 0.35,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    Colors.orange.withOpacity(0.05),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      // Main icon
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: Container(
                          width: size.width * 0.35,
                          height: size.width * 0.35,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                Colors.red.withOpacity(0.1),
                                Colors.orange.withOpacity(0.1),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.orange.withOpacity(0.2),
                                blurRadius: 30,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.wifi_off_rounded,
                            size: size.width * 0.2,
                            color: Colors.orange,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: size.height * 0.04),

                  // Title with gradient
                  ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: [Colors.orange, Colors.red],
                    ).createShader(bounds),
                    child: Text(
                      'No Internet Connection',
                      style: TextStyle(
                        fontSize: size.width * 0.06,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: size.height * 0.02),

                  // Description
                  Text(
                    'Please check your internet connection and try again',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: size.width * 0.04,
                      color: AppTheme.grey,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: size.height * 0.06),

                  // Retry Button
                  _buildRetryButton(size),

                  SizedBox(height: size.height * 0.03),

                  // Connection Status Indicator
                  _buildConnectionStatus(size),

                  SizedBox(height: size.height * 0.03),

                  // Tips Section
                  _buildTipsSection(size),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRetryButton(Size size) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      width: _isChecking ? size.width * 0.15 : size.width * 0.5,
      height: size.height * 0.06,
      child: ElevatedButton(
        onPressed: _isChecking ? null : () async {
          setState(() => _isChecking = true);

          // Check internet connection
          bool isConnected = await InternetConnection().hasInternetAccess;

          if (isConnected && mounted) {
            // Show success animation before closing
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Connected! 🎉'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 1),
              ),
            );
            await Future.delayed(Duration(milliseconds: 500));
            Navigator.of(context).pop();
          } else {
            // Show error message
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Still no connection 😔'),
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 2),
                ),
              );
            }
          }

          if (mounted) {
            setState(() => _isChecking = false);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.mainColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_isChecking ? 30 : 12),
          ),
          elevation: 5,
        ),
        child: _isChecking
            ? SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.refresh, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'Try Again',
              style: TextStyle(
                fontSize: size.width * 0.04,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionStatus(Size size) {
    return StreamBuilder<InternetStatus>(
      stream: InternetConnection().onStatusChange,
      builder: (context, snapshot) {
        String statusText = 'Checking connection...';
        Color statusColor = Colors.orange;
        IconData statusIcon = Icons.wifi_find;

        if (snapshot.hasData) {
          switch (snapshot.data!) {
            case InternetStatus.connected:
              statusText = 'Connected';
              statusColor = Colors.green;
              statusIcon = Icons.wifi;
              break;
            case InternetStatus.disconnected:
              statusText = 'Disconnected';
              statusColor = Colors.red;
              statusIcon = Icons.wifi_off;
              break;
          }
        }

        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.04,
            vertical: size.height * 0.01,
          ),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: statusColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                statusIcon,
                color: statusColor,
                size: size.width * 0.04,
              ),
              SizedBox(width: 8),
              Text(
                statusText,
                style: TextStyle(
                  color: statusColor,
                  fontSize: size.width * 0.035,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTipsSection(Size size) {
    return Container(
      padding: EdgeInsets.all(size.width * 0.04),
      decoration: BoxDecoration(
        color: AppTheme.darkCardColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.darkBorderColor,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: AppTheme.mainColor,
                size: size.width * 0.04,
              ),
              SizedBox(width: 8),
              Text(
                'Quick Tips:',
                style: TextStyle(
                  fontSize: size.width * 0.035,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.mainColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          _buildTipItem('Turn off Airplane Mode', Icons.airplanemode_off, size),
          _buildTipItem('Check your WiFi connection', Icons.wifi, size),
          _buildTipItem('Check your mobile data', Icons.signal_cellular_alt, size),
          _buildTipItem('Restart your router', Icons.router, size),
        ],
      ),
    );
  }

  Widget _buildTipItem(String text, IconData icon, Size size) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppTheme.grey.withOpacity(0.6),
            size: size.width * 0.035,
          ),
          SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              fontSize: size.width * 0.03,
              color: AppTheme.grey,
            ),
          ),
        ],
      ),
    );
  }
}