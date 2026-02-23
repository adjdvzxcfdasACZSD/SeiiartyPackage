import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../Package/Core/common_Dialogs.dart';
import '../../../Package/Core/app_theme.dart';
import '../Core/general_const.dart';
import '../Core/general_function.dart';
import '../Core/shared_preference.dart';
import '../Screen/DrawerScreen/Profile/sc_profile.dart';

class MyDrawer extends StatefulWidget {
  const MyDrawer({super.key});

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    GeneralFunctions.loadUserData("Drawer");
    _animationController = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeIn));
    _slideAnimation = Tween<Offset>(
      begin: const Offset(-1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    GeneralFunctions.loadUserData("Drawer");
    Size size = MediaQuery.sizeOf(context);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Drawer(
        backgroundColor: AppTheme.darkBackground,
        width: size.width * 0.75,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(0), bottomLeft: Radius.circular(0)),
        ),
        child: SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                _buildDrawerHeader(context, size),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(24, 16, 24, 12),
                        child: Text(
                          'الحساب',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.grey.withOpacity(0.7),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      _buildMenuItem(
                        icon: Icons.person_outline_rounded,
                        title: "الملف الشخصي",
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            PageRouteBuilder(pageBuilder: (context, animation, secondaryAnimation) => ProfileScreen()),
                          );
                        },

                        size: size,
                      ),
                      _buildMenuItem(
                        icon: Icons.notifications_outlined,
                        title: "الإشعارات",
                        onTap: () => Navigator.pop(context),
                        size: size,
                        badge: "0",
                      ),
                      _buildMenuItem(
                        icon: Icons.lock_outline_rounded,
                        title: "الخصوصية",
                        onTap: () => Navigator.pop(context),
                        size: size,
                      ),

                      Padding(
                        padding: EdgeInsets.fromLTRB(24, 24, 24, 12),
                        child: Text(
                          'الدعم',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.grey.withOpacity(0.7),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      _buildMenuItem(
                        icon: Icons.help_outline_rounded,
                        title: "المساعدة",
                        onTap: () => Navigator.pop(context),
                        size: size,
                      ),

                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        child: Divider(color: AppTheme.darkBorderColor.withOpacity(0.5), thickness: 1),
                      ),

                      _buildMenuItem(
                        icon: Icons.logout_rounded,
                        title: "تسجيل الخروج",
                        onTap: () => CommonDialogs().showDialogYesNo(
                          context,
                          btnColor: AppTheme.dangerColor,
                          title: 'تسجيل الخروج',
                          btnText: 'تسجيل الخروج',
                          content: 'هل أنت متأكد من تسجيل الخروج؟',
                          onYes: () {
                            Navigator.pop(context);
                            Navigator.pushAndRemoveUntil(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, animation, secondaryAnimation) => GeneralConstant.loginScreen!,
                                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                  return FadeTransition(opacity: animation, child: child);
                                },
                                transitionDuration: Duration(milliseconds: 500),
                              ),
                              (route) => false,
                            );
                            GeneralConstant.userLogged = null;
                            SharedPreference.sharedPreferencesSetDynamic(SharedPreference.userLoggedKey, null);
                          },
                          icon: Icon(Icons.logout_rounded, color: AppTheme.dangerColor),
                        ),
                        size: size,
                        isDestructive: true,
                      ),
                      SizedBox(height: 16),
                    ],
                  ),
                ),
                _buildFooter(size),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context, Size size) {
    if (kDebugMode) {
      print("==========================================");
      print("userLogged is null: ${GeneralConstant.userLogged == null}");
      print("userLogged value: ${GeneralConstant.userLogged}");
      print("==========================================");
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.gradientStart, AppTheme.gradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Decorative circles in background
          Positioned(
            top: -size.width * 0.13,
            right: -size.width * 0.13,
            child: Container(
              width: size.width * 0.5,
              height: size.width * 0.5,
              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.05)),
            ),
          ),
          Positioned(
            bottom: -size.width * 0.08,
            left: -size.width * 0.08,
            child: Container(
              width: size.width * 0.4,
              height: size.width * 0.4,
              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.03)),
            ),
          ),

          // Main content
          Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + size.height * 0.04,
              bottom: size.height * 0.04,
              left: size.width * 0.064,
              right: size.width * 0.064,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar Section with edit button
                Row(
                  children: [
                    // Avatar with glow effect
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.3),
                            blurRadius: size.width * 0.053,
                            spreadRadius: size.width * 0.013,
                          ),
                        ],
                      ),
                      child: Container(
                        padding: EdgeInsets.all(size.width * 0.008),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [Colors.white.withOpacity(0.8), Colors.white.withOpacity(0.4)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Container(
                          padding: EdgeInsets.all(size.width * 0.008),
                          decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                          child: CircleAvatar(
                            radius: size.width * 0.101,
                            backgroundColor: Colors.white,
                            child: Text(
                              GeneralConstant.userLogged["FullName"].substring(0, 2).toUpperCase(),
                              style: TextStyle(
                                fontSize: size.width * 0.075,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.mainColor,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    Spacer(),

                    // Edit button
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          // Navigate to edit profile
                        },
                        borderRadius: BorderRadius.circular(size.width * 0.032),
                        child: Container(
                          padding: EdgeInsets.all(size.width * 0.032),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(size.width * 0.032),
                            border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
                          ),
                          child: Icon(Icons.edit_rounded, color: Colors.white, size: size.width * 0.053),
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: size.height * 0.03),

                // User Info Card
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(size.width * 0.053),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(size.width * 0.043),
                    border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: size.width * 0.027,
                        offset: Offset(0, size.height * 0.005),
                      ),
                    ],
                  ),
                  child: Text(
                    GeneralConstant.userLogged["FullName"],
                    style: TextStyle(
                      fontSize: size.width * 0.059,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.3,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.2),
                          offset: Offset(0, size.height * 0.0025),
                          blurRadius: size.width * 0.011,
                        ),
                      ],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required Size size,
    bool isDestructive = false,
    Widget? trailing,
    String? badge,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: isDestructive ? AppTheme.dangerColor.withOpacity(0.1) : AppTheme.mainColor.withOpacity(0.1),
          highlightColor: isDestructive ? AppTheme.dangerColor.withOpacity(0.05) : AppTheme.mainColor.withOpacity(0.05),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDestructive ? AppTheme.dangerColor.withOpacity(0.12) : AppTheme.mainColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: isDestructive ? AppTheme.dangerColor : AppTheme.mainColor, size: 22),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      color: isDestructive ? AppTheme.dangerColor : Colors.white,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
                if (badge != null)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: AppTheme.mainColor, borderRadius: BorderRadius.circular(12)),
                    child: Text(
                      badge,
                      style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  )
                else if (trailing != null)
                  trailing
                else
                  Icon(Icons.arrow_back_ios_rounded, size: 16, color: AppTheme.grey.withOpacity(0.5)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(Size size) {
    return Container(
      padding: EdgeInsets.fromLTRB(24, 20, 24, 24),
      decoration: BoxDecoration(
        color: AppTheme.darkCardColor.withOpacity(0.3),
        border: Border(top: BorderSide(color: AppTheme.darkBorderColor.withOpacity(0.5), width: 1)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSocialIcon(Icons.facebook_rounded, () {}),
              SizedBox(width: 14),
              _buildSocialIcon(Icons.language_rounded, () {}),
              SizedBox(width: 14),
              _buildSocialIcon(Icons.phone_rounded, () {}),
            ],
          ),
          SizedBox(height: 20),
          Text(
            '${GeneralConstant.appValues.version}الاصدار: ',
            style: TextStyle(fontSize: 12, color: AppTheme.grey.withOpacity(0.7), fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 6),
          Text('© 2025 ${GeneralConstant.appName}', style: TextStyle(fontSize: 11, color: AppTheme.grey.withOpacity(0.5))),
        ],
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        splashColor: AppTheme.mainColor.withOpacity(0.2),
        child: Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.darkCardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.darkBorderColor.withOpacity(0.5), width: 1),
          ),
          child: Icon(icon, color: AppTheme.mainColor, size: 20),
        ),
      ),
    );
  }
}
