import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:seiiarty_package/Package/Core/StoredProcedures/user.dart';
import 'package:seiiarty_package/Package/Core/app_theme.dart';
import 'package:seiiarty_package/Package/Core/general_const.dart';
import 'package:seiiarty_package/Package/Core/general_function.dart';
import 'package:seiiarty_package/Package/Widget/my_appbar.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    GeneralFunctions.loadUserData("Change Password Screen");
    _animationController = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeIn));
    _animationController.forward();
  }

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    GeneralFunctions.loadUserData("Change Password Screen");
    Size size = MediaQuery.sizeOf(context);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: AppTheme.darkBackground,
        appBar: MyStyledAppBar(title: 'تغيير كلمة المرور', scaffoldKey: _scaffoldKey, showBackButton: true),
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(size.width * 0.053),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoCard(size),
                  SizedBox(height: size.height * 0.03),
                  _buildPasswordFields(size),
                  SizedBox(height: size.height * 0.04),
                  _buildChangePasswordButton(size),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(Size size) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(size.width * 0.053),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.mainColor.withOpacity(0.2), AppTheme.mainColor.withOpacity(0.1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(size.width * 0.043),
        border: Border.all(color: AppTheme.mainColor.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(size.width * 0.032),
            decoration: BoxDecoration(
              color: AppTheme.mainColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(size.width * 0.032),
            ),
            child: Icon(Icons.info_outline, color: AppTheme.mainColor, size: size.width * 0.064),
          ),
          SizedBox(width: size.width * 0.043),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'نصيحة أمنية',
                  style: TextStyle(color: Colors.white, fontSize: size.width * 0.043, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: size.height * 0.005),
                Text(
                  'استخدم كلمة مرور قوية تحتوي على أحرف وأرقام ورموز',
                  style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: size.width * 0.035),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordFields(Size size) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'تغيير كلمة المرور',
          style: TextStyle(fontSize: size.width * 0.053, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        SizedBox(height: size.height * 0.02),
        _buildPasswordField(
          controller: _oldPasswordController,
          label: 'كلمة المرور القديمة',
          icon: Icons.lock_outline,
          size: size,
          obscureText: _obscureOldPassword,
          onToggleVisibility: () {
            setState(() {
              _obscureOldPassword = !_obscureOldPassword;
            });
          },
        ),
        SizedBox(height: size.height * 0.015),
        _buildPasswordField(
          controller: _newPasswordController,
          label: 'كلمة المرور الجديدة',
          icon: Icons.lock_reset,
          size: size,
          obscureText: _obscureNewPassword,
          onToggleVisibility: () {
            setState(() {
              _obscureNewPassword = !_obscureNewPassword;
            });
          },
        ),
        SizedBox(height: size.height * 0.015),
        _buildPasswordField(
          controller: _confirmPasswordController,
          label: 'تأكيد كلمة المرور الجديدة',
          icon: Icons.lock_clock,
          size: size,
          obscureText: _obscureConfirmPassword,
          onToggleVisibility: () {
            setState(() {
              _obscureConfirmPassword = !_obscureConfirmPassword;
            });
          },
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Size size,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.darkCardColor,
        borderRadius: BorderRadius.circular(size.width * 0.043),
        border: Border.all(color: AppTheme.darkBorderColor, width: 1),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: TextStyle(color: Colors.white, fontSize: size.width * 0.043),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: size.width * 0.04),
          prefixIcon: Container(
            margin: EdgeInsets.all(size.width * 0.027),
            padding: EdgeInsets.all(size.width * 0.021),
            decoration: BoxDecoration(
              color: AppTheme.mainColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(size.width * 0.027),
            ),
            child: Icon(icon, color: AppTheme.mainColor, size: size.width * 0.053),
          ),
          suffixIcon: IconButton(
            icon: Icon(
              obscureText ? Icons.visibility_off : Icons.visibility,
              color: Colors.white.withOpacity(0.6),
              size: size.width * 0.053,
            ),
            onPressed: onToggleVisibility,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: size.width * 0.043, vertical: size.height * 0.02),
        ),
      ),
    );
  }

  Widget _buildChangePasswordButton(Size size) {
    return Container(
      width: double.infinity,
      height: size.height * 0.065,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.gradientStart, AppTheme.gradientEnd],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(size.width * 0.043),
        boxShadow: [
          BoxShadow(
            color: AppTheme.mainColor.withOpacity(0.4),
            blurRadius: size.width * 0.027,
            offset: Offset(0, size.height * 0.006),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(size.width * 0.043),
          onTap: () {
            _changePassword();
          },
          child: Center(
            child: Text(
              'تغيير كلمة المرور',
              style: TextStyle(color: Colors.white, fontSize: size.width * 0.045, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _changePassword() async {
    if (_oldPasswordController.text.isNotEmpty &&
        _newPasswordController.text.isNotEmpty &&
        _confirmPasswordController.text.isNotEmpty) {
      if (GeneralFunctions.hashPassword(_oldPasswordController.text) != GeneralConstant.userLogged["Password"]) {
        return GeneralFunctions.showSnackBar(context, "كلمة المرور القدمية غير صحيحة", Colors.red);
      }
    }
    if (_newPasswordController.text != _confirmPasswordController.text) {
      return GeneralFunctions.showSnackBar(context, "كلمة المرور الجديدة غير متطابقة", Colors.red);
    }

    if (kDebugMode) {
      print("==========================================");
      print("Changing Password:");
      print("Old Password: ${_oldPasswordController.text}");
      print("New Password: ${_newPasswordController.text}");
      print("==========================================");
    }
    await SpUser.update(password: GeneralFunctions.hashPassword(_newPasswordController.text));
    // Show success message
    GeneralFunctions.showSnackBar(context, "تم تغيير كلمة المرور بنجاح", Colors.green);
    // Navigate back after success
    Future.delayed(Duration(seconds: 1), () {
      Navigator.pop(context);
    });
  }
}
