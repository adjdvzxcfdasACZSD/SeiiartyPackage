import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../Core/StoredProcedures/setup_table.dart';
import '../Core/asset_routes.dart';
import '../Core/general_function.dart';
import '../Core/shared_preference.dart';
import '../core/app_theme.dart';
import '../core/general_const.dart';

class ScSplash extends StatefulWidget {
  const ScSplash({super.key});

  @override
  State<ScSplash> createState() => _ScSplashState();
}

class _ScSplashState extends State<ScSplash> with SingleTickerProviderStateMixin {
  PackageInfo packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
    buildSignature: 'Unknown',
    installerStore: 'Unknown',
  );

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  // State variables for version checking
  bool _isVersionChecked = false;
  bool _needsUpdate = false;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    if (kDebugMode) {
      print("===================SPLASH SCREEN=======================");
      print(GeneralConstant.firebaseToken);
    }
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(0.0, 0.6, curve: Curves.easeOutBack),
    ));

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(0.3, 1.0, curve: Curves.easeOut),
    ));

    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    setPrivacyPolicy();

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.darkBackground,
              AppTheme.darkCardColor,
              AppTheme.darkBackground,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.06),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated Logo
                  _buildAnimatedLogo(size),

                  SizedBox(height: size.height * 0.04),

                  // App Name with Fade Animation
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: _buildAppNameSection(size),
                    ),
                  ),

                  SizedBox(height: size.height * 0.06),

                  // Content Section
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildContentSection(size),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedLogo(Size size) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          width: size.width * 0.4,
          height: size.width * 0.4,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.gradientStart, AppTheme.gradientEnd],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppTheme.mainColor.withOpacity(0.4),
                blurRadius: 40,
                spreadRadius: 8,
              ),
              BoxShadow(
                color: AppTheme.purpleShadow,
                blurRadius: 60,
                spreadRadius: 15,
              ),
            ],
          ),
          child: Container(
            margin: EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: AppTheme.darkBackground,
              shape: BoxShape.circle,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(size.width * 0.2),
              child: Image.asset(
                AssetRoutes.logo,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppNameSection(Size size) {
    return Column(
      children: [
        Text(
          GeneralConstant.appName,
          style: TextStyle(
            fontSize: size.width * 0.09,
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        SizedBox(height: size.height * 0.01),
        Container(
          height: 3,
          width: size.width * 0.15,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.gradientStart, AppTheme.gradientEnd],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  Widget _buildContentSection(Size size) {
    return FutureBuilder(
      future: initDataAndCheckVersion(context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          // Check if setup table failed to load
          if (GeneralConstant.setupTable == null ||
              GeneralConstant.setupTable.length == 0) {
            return Column(
              children: [
                if (!kIsWeb) _buildVersionCard(size),
                SizedBox(height: size.height * 0.04),
                _buildErrorCard(size),
              ],
            );
          }

          // If update is needed and haven't navigated yet, show update card
          if (_needsUpdate && !_hasNavigated && !kIsWeb) {
            return Column(
              children: [
                _buildVersionCard(size),
                SizedBox(height: size.height * 0.04),
                _buildUpdateCard(size),
              ],
            );
          }

          // If no update needed, navigation already happened or is happening
          // Show minimal loading state
          return Column(
            children: [

              SizedBox(height: size.height * 0.04),
              _buildLoadingIndicator(size),
            ],
          );

        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingIndicator(size);
        } else if (snapshot.hasError) {
          return Column(
            children: [
              if (!kIsWeb) _buildVersionCard(size),
              SizedBox(height: size.height * 0.04),
              _buildErrorText(snapshot.error.toString(), size),
            ],
          );
        } else {
          return SizedBox.shrink();
        }
      },
    );
  }

  Widget _buildVersionCard(Size size) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.06,
        vertical: size.height * 0.02,
      ),
      decoration: BoxDecoration(
        color: AppTheme.darkCardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.darkBorderColor,
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.info_outline,
            color: AppTheme.mainColor,
            size: size.width * 0.05,
          ),
          SizedBox(width: size.width * 0.03),
          Text(
            "الاصدار: ${packageInfo.version}",
            style: TextStyle(
              fontSize: size.width * 0.04,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator(Size size) {
    return Column(
      children: [
        Container(
          width: size.width * 0.15,
          height: size.width * 0.15,
          decoration: BoxDecoration(
            color: AppTheme.darkCardColor,
            shape: BoxShape.circle,
            border: Border.all(
              color: AppTheme.darkBorderColor,
              width: 2,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(size.width * 0.03),
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.mainColor),
            ),
          ),
        ),
        SizedBox(height: size.height * 0.02),
        Text(
          "جار التحميل...",
          style: TextStyle(
            color: AppTheme.textTertiary,
            fontSize: size.width * 0.035,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorCard(Size size) {
    return Container(
      padding: EdgeInsets.all(size.width * 0.05),
      decoration: BoxDecoration(
        color: AppTheme.darkCardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.dangerColor.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            color: AppTheme.dangerColor,
            size: size.width * 0.12,
          ),
          SizedBox(height: size.height * 0.02),
          Text(
            "خطأ في الاتصال",
            style: TextStyle(
              fontSize: size.width * 0.045,
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: size.height * 0.01),
          Text(
            "غير قادر على الاتصال بالخادم",
            style: TextStyle(
              fontSize: size.width * 0.035,
              color: AppTheme.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: size.height * 0.03),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _hasNavigated = false;
                _needsUpdate = false;
                _isVersionChecked = false;
              });
            },
            icon: Icon(Icons.refresh, color: Colors.white),
            label: Text(
              "إعادة المحاولة",
              style: TextStyle(
                color: Colors.white,
                fontSize: size.width * 0.04,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.mainColor,
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.08,
                vertical: size.height * 0.018,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpdateCard(Size size) {
    return Container(
      padding: EdgeInsets.all(size.width * 0.06),
      decoration: BoxDecoration(
        color: AppTheme.darkCardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppTheme.darkBorderColor,
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(size.width * 0.04),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.gradientStart, AppTheme.gradientEnd],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.system_update_alt,
              color: Colors.white,
              size: size.width * 0.12,
            ),
          ),
          SizedBox(height: size.height * 0.03),
          Text(
            "متوفر تحديث",
            style: TextStyle(
              fontSize: size.width * 0.055,
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: size.height * 0.015),
          Text(
            "متوفر إصدار جديد",
            style: TextStyle(
              fontSize: size.width * 0.038,
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: size.height * 0.01),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.04,
              vertical: size.height * 0.01,
            ),
            decoration: BoxDecoration(
              color: AppTheme.darkSurfaceColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              "الاصدار ${GeneralConstant.appValues.version}",
              style: TextStyle(
                fontSize: size.width * 0.035,
                color: AppTheme.mainColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(height: size.height * 0.03),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.gradientStart, AppTheme.gradientEnd],
              ),
              borderRadius: BorderRadius.circular(16),

            ),
            child: ElevatedButton(
              onPressed: () async {
                GeneralFunctions.launchLink(
                  context,
                  GeneralConstant.appValues.appUrl,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: EdgeInsets.symmetric(vertical: size.height * 0.02),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                "تحديث الآن",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: size.width * 0.04,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorText(String error, Size size) {
    return Container(
      padding: EdgeInsets.all(size.width * 0.05),
      decoration: BoxDecoration(
        color: AppTheme.darkCardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.dangerColor.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            color: AppTheme.dangerColor,
            size: size.width * 0.1,
          ),
          SizedBox(height: size.height * 0.02),
          Text(
            error,
            style: TextStyle(
              color: AppTheme.dangerColor,
              fontSize: size.width * 0.035,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void setPrivacyPolicy() {
    GeneralConstant.appName = "Seiiarty";
    GeneralConstant.privacyPolicyUrl =
    "https://www.termsfeed.com/live/a758a194-ac1e-4d6a-a9bb-c12a61f47af8";
  }

  // Combined function: Initialize data AND check version AND navigate
  Future<void> initDataAndCheckVersion(BuildContext context) async {
    try {
      // Load initial data
      await Future.delayed(Duration(seconds: 2));
      dynamic setupTable = await SpSetupTable.get(context);
      GeneralConstant.setupTable = setupTable[0];
      packageInfo = await PackageInfo.fromPlatform();


      dynamic savedUserLogged = await SharedPreference.sharedPreferencesGetDynamic(
          SharedPreference.userLoggedKey);

      if (savedUserLogged != null) {
        GeneralConstant.userLogged = savedUserLogged;
      }

      // Set app values from database
      await setValues();

      // Check version only if not on web
      if (!kIsWeb) {
        int appVersionInt = int.parse(packageInfo.version.replaceAll(".", ""));
        int dbVersionInt = int.parse(
            GeneralConstant.appValues.version.replaceAll(".", ""));

        if (appVersionInt >= dbVersionInt) {
          // Version is OK - navigate immediately
          _isVersionChecked = true;
          _needsUpdate = false;

          if (!_hasNavigated && context.mounted) {
            _hasNavigated = true;
            await Future.delayed(Duration(milliseconds: 300));

            if (!context.mounted) return;

            if (GeneralConstant.userLogged == null) {
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      GeneralConstant.loginScreen!,
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  transitionDuration: Duration(milliseconds: 500),
                ),
              );
            } else {
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      GeneralConstant.homeScreen!,
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  transitionDuration: Duration(milliseconds: 500),
                ),
              );
            }
          }
        } else {
          // Update needed - show update card
          setState(() {
            _isVersionChecked = true;
            _needsUpdate = true;
          });
        }
      } else {
        // Web version - navigate directly
        if (!_hasNavigated && context.mounted) {
          _hasNavigated = true;
          await Future.delayed(Duration(milliseconds: 300));

          if (!context.mounted) return;

          if (GeneralConstant.userLogged == null) {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    GeneralConstant.loginScreen!,
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
                transitionDuration: Duration(milliseconds: 500),
              ),
            );
          } else {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    GeneralConstant.homeScreen!,
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
                transitionDuration: Duration(milliseconds: 500),
              ),
            );
          }
        }
      }

      return;
    } catch (e) {
      if (kDebugMode) print("❌ Error in initDataAndCheckVersion: $e");
      if (context.mounted) GeneralFunctions.cachedError(context, e);
      rethrow;
    }
  }

  Future<void> setValues() async {
    GeneralConstant.appValues = AppValues(
      GeneralConstant.appValues.version = (Platform.isAndroid)
          ? GeneralConstant.setupTable['V_Seiiarty_Android']
          : GeneralConstant.setupTable['V_Seiiarty_IOS'],
      GeneralConstant.appValues.appUrl = (Platform.isAndroid)
          ? (GeneralConstant.setupTable['URL_Seiiarty_Android'] is Map)
          ? ""
          : GeneralConstant.setupTable['URL_Seiiarty_Android']
          : (GeneralConstant.setupTable['URL_Seiiarty_IOS'] is Map)
          ? ""
          : GeneralConstant.setupTable['URL_Seiiarty_IOS'],
    );
    return;
  }
}