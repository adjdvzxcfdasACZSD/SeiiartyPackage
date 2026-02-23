import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:seiiarty_package/Package/Core/app_theme.dart';
import 'package:seiiarty_package/Package/Core/general_const.dart';
import 'package:seiiarty_package/Package/Core/general_function.dart';
import 'package:seiiarty_package/Package/Screen/DrawerScreen/Profile/sc_edit_profile.dart';
import 'package:seiiarty_package/Package/Widget/my_appbar.dart';
import 'package:seiiarty_package/Package/Widget/my_drawer.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    GeneralFunctions.loadUserData("Profile Screen");
    if (kDebugMode) {
      print(GeneralConstant.userLogged);
    }
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeIn));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: AppTheme.darkBackground,
        appBar: MyStyledAppBar(
          title: ' الملف الشخصي',
          scaffoldKey: _scaffoldKey,
          showBackButton: true,
        ),
        drawer: MyDrawer(),
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(size.width * 0.053),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileCard(size),
                  SizedBox(height: size.height * 0.03),
                  _buildAccountSettings(size),
                  SizedBox(height: size.height * 0.03),
                  _buildPreferencesSettings(size),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard(Size size) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.gradientStart, AppTheme.gradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(size.width * 0.043),
        boxShadow: [
          BoxShadow(
            color: AppTheme.mainColor.withOpacity(0.3),
            blurRadius: size.width * 0.053,
            offset: Offset(0, size.height * 0.0125),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: -size.width * 0.1,
            right: -size.width * 0.1,
            child: Container(
              width: size.width * 0.3,
              height: size.width * 0.3,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          Positioned(
            bottom: -size.width * 0.06,
            left: -size.width * 0.06,
            child: Container(
              width: size.width * 0.25,
              height: size.width * 0.25,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.03),
              ),
            ),
          ),

          // Main content
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.053,
              vertical: size.height * 0.025,
            ),
            child: Row(
              children: [
                // Avatar with glow
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.3),
                        blurRadius: size.width * 0.04,
                        spreadRadius: size.width * 0.008,
                      ),
                    ],
                  ),
                  child: Container(
                    padding: EdgeInsets.all(size.width * 0.008),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.3),
                          Colors.white.withOpacity(0.1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Container(
                      padding: EdgeInsets.all(size.width * 0.005),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: CircleAvatar(
                        radius: size.width * 0.09,
                        backgroundColor: Colors.white,
                        child: Text(
                          GeneralFunctions.ifMapOrNull(GeneralConstant.userLogged["FullName"])
                              .substring(0, 2)
                              .toUpperCase(),
                          style: TextStyle(
                            fontSize: size.width * 0.064,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.mainColor,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(width: size.width * 0.043),

                // Name and edit button
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                  GeneralFunctions.ifMapOrNull(GeneralConstant.userLogged["FullName"]),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: size.width * 0.053,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.3),
                              offset: Offset(0, size.height * 0.0025),
                              blurRadius: size.width * 0.011,
                            ),
                          ],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSettings(Size size) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الحساب',
          style: TextStyle(
            fontSize: size.width * 0.053,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: size.height * 0.02),
        _buildSettingItem(
          icon: Icons.person_outline,
          title: "تعديل الملف الشخصي",
          color: Colors.blue,
          size: size,
          onTap: () async {
            await Navigator.push(
              context,
              PageRouteBuilder(pageBuilder: (context, animation, secondaryAnimation) => EditProfileScreen()),
            );
            setState(() {});
          },
        ),
        SizedBox(height: size.height * 0.02),
        _buildSettingItem(
          icon: Icons.notifications_outlined,
          title: "الإشعارات",
          color: Colors.purple,
          size: size,
          onTap: () {
            if (kDebugMode) {
              print("الإشعارات");
            }
          },
        ),
      ],
    );
  }

  Widget _buildPreferencesSettings(Size size) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'أخرى',
          style: TextStyle(
            fontSize: size.width * 0.053,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),

        SizedBox(height: size.height * 0.015),
        _buildSettingItem(
          icon: Icons.info_outline,
          title: "حول التطبيق",
          color: Colors.teal,
          size: size,
          onTap: () {
            if (kDebugMode) {
              print("حول التطبيق");
            }
          },
        ),
        SizedBox(height: size.height * 0.015),
        _buildSettingItem(
          icon: Icons.logout,
          title: "تسجيل الخروج",
          color: Colors.red,
          size: size,
          onTap: () {
            if (kDebugMode) {
              print("تسجيل الخروج");
            }
          },
        ),
      ],
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required Color color,
    required Size size,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(size.width * 0.043),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(size.width * 0.043),
          border: Border.all(color: AppTheme.darkBorderColor, width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(size.width * 0.032),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(size.width * 0.032),
              ),
              child: Icon(
                icon,
                color: color,
                size: size.width * 0.064,
              ),
            ),
            SizedBox(width: size.width * 0.043),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: size.width * 0.043,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white.withOpacity(0.5),
              size: size.width * 0.043,
            ),
          ],
        ),
      ),
    );
  }
}