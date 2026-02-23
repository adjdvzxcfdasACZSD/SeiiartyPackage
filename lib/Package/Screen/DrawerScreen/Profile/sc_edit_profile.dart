import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:seiiarty_package/Package/Core/StoredProcedures/user.dart';
import 'package:seiiarty_package/Package/Core/app_theme.dart';
import 'package:seiiarty_package/Package/Core/general_const.dart';
import 'package:seiiarty_package/Package/Core/general_function.dart';
import 'package:seiiarty_package/Package/Core/phone_number_formatter.dart';
import 'package:seiiarty_package/Package/Core/shared_preference.dart';
import 'package:seiiarty_package/Package/Screen/DrawerScreen/Profile/sc_change_password.dart';
import 'package:seiiarty_package/Package/Widget/my_appbar.dart';

import '../../sc_otp_verify.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    GeneralFunctions.loadUserData("Edit Profile Screen");
    _nameController.text = GeneralFunctions.ifMapOrNull(GeneralConstant.userLogged["FullName"], whenEmpty: "");
    _phoneController.text = PhoneNumberFormatter.toLocalFormat(GeneralConstant.userLogged["PhoneNumber"]);

    _animationController = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeIn));
    _animationController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    GeneralFunctions.loadUserData("Edit Profile Screen");
    Size size = MediaQuery.sizeOf(context);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: AppTheme.darkBackground,
        appBar: MyStyledAppBar(title: 'تعديل الملف الشخصي', scaffoldKey: _scaffoldKey, showBackButton: true),
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(size.width * 0.053),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileHeader(size),
                  SizedBox(height: size.height * 0.03),
                  _buildPersonalInfo(size),
                  SizedBox(height: size.height * 0.03),
                  _buildChangePass(size),
                  SizedBox(height: size.height * 0.03),
                  _buildDeleteProfile(size),

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(Size size) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(size.width * 0.053),
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
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(size.width * 0.008),
            decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.2)),
            child: Container(
              padding: EdgeInsets.all(size.width * 0.005),
              decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: CircleAvatar(
                radius: size.width * 0.08,
                backgroundColor: Colors.white,
                child: Text(
                  GeneralFunctions.ifMapOrNull(
                    GeneralConstant.userLogged["FullName"],
                    whenEmpty: "",
                  ).substring(0, 2).toUpperCase(),
                  style: TextStyle(fontSize: size.width * 0.053, fontWeight: FontWeight.bold, color: AppTheme.mainColor),
                ),
              ),
            ),
          ),
          SizedBox(width: size.width * 0.043),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تحديث معلوماتك',
                  style: TextStyle(color: Colors.white, fontSize: size.width * 0.048, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: size.height * 0.005),
                Text(
                  'قم بتعديل بياناتك الشخصية',
                  style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: size.width * 0.035),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfo(Size size) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'المعلومات الشخصية',
          style: TextStyle(fontSize: size.width * 0.053, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        SizedBox(height: size.height * 0.02),
        _buildChangeTextField(
          size,
          controller: _nameController,
          label: 'الاسم الكامل',
          icon: Icons.person_outline,
          keyboardType: TextInputType.name,
          onTap: () {
            SpUser.update(fullName: _nameController.text,context: context,);
          },
        ),
        SizedBox(height: size.height * 0.015),
        _buildChangeTextField(
          size,
          readOnly: true,
          controller: _phoneController,
          label: "رقم الهاتف",
          icon: Icons.phone_android_rounded,
          onTap: () {
            _showChangePhoneDialog(size);
          },
        ),
      ],
    );
  }

  Widget _buildChangeTextField(
    Size size, {
    bool readOnly = false,
    required TextEditingController controller,
    required String label,
    required IconData icon,
    VoidCallback? onTap,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.darkCardColor,
        borderRadius: BorderRadius.circular(size.width * 0.043),
        border: Border.all(color: AppTheme.darkBorderColor, width: 1),
      ),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        // Make it non-editable
        keyboardType: keyboardType,
        style: TextStyle(color: Colors.white, fontSize: size.width * 0.043),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: size.width * 0.04),
          prefixIcon: Container(
            margin: EdgeInsets.all(size.width * 0.027),
            padding: EdgeInsets.all(size.width * 0.021),
            decoration: BoxDecoration(
              color: AppTheme.mainColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(size.width * 0.027),
            ),
            child: Icon(icon, color: AppTheme.mainColor, size: size.width * 0.053),
          ),
          suffixIcon: Padding(
            padding: EdgeInsets.all(size.width * 0.021),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                child: Text(
                  'تغيير',
                  style: TextStyle(color: AppTheme.mainColor, fontSize: size.width * 0.035, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: size.width * 0.043, vertical: size.height * 0.02),
        ),
      ),
    );
  }

  Widget _buildChangePass(Size size) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: size.height * 0.02),
        _buildActionItem(
          icon: Icons.lock_outline,
          title: "تغيير كلمة المرور",
          color: Colors.orange,
          size: size,
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => ChangePasswordScreen()));
          },
        ),
      ],
    );
  }

  Widget _buildDeleteProfile(Size size) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildActionItem(
          icon: Icons.delete_forever_outlined,
          title: "حذف الحساب",
          color: Colors.red,
          size: size,
          onTap: () {
            _showDeleteAccountDialog(size);
          },
        ),
      ],
    );
  }

  Widget _buildActionItem({
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
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(size.width * 0.032),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(size.width * 0.032)),
              child: Icon(icon, color: color, size: size.width * 0.064),
            ),
            SizedBox(width: size.width * 0.043),
            Expanded(
              child: Text(
                title,
                style: TextStyle(fontSize: size.width * 0.043, fontWeight: FontWeight.w600, color: color),
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color.withOpacity(0.5), size: size.width * 0.043),
          ],
        ),
      ),
    );
  }

  void _showChangePhoneDialog(Size size) {
    final TextEditingController newPhoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: AppTheme.darkCardColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(size.width * 0.043)),
            title: Row(
              children: [
                Icon(Icons.phone_android_rounded, color: AppTheme.mainColor, size: size.width * 0.075),
                SizedBox(width: size.width * 0.027),
                Text(
                  'تغيير رقم الهاتف',
                  style: TextStyle(color: Colors.white, fontSize: size.width * 0.053),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'الرقم الحالي: ${_phoneController.text}',
                  style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: size.width * 0.037),
                ),
                SizedBox(height: size.height * 0.02),
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.darkBackground,
                    borderRadius: BorderRadius.circular(size.width * 0.032),
                    border: Border.all(color: AppTheme.darkBorderColor, width: 1),
                  ),
                  child: TextField(
                    controller: newPhoneController,
                    keyboardType: TextInputType.phone,
                    style: TextStyle(color: Colors.white, fontSize: size.width * 0.043),
                    decoration: InputDecoration(
                      hintText: 'أدخل رقم الهاتف الجديد',
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: size.width * 0.04),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: size.width * 0.043, vertical: size.height * 0.015),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(
                  'إلغاء',
                  style: TextStyle(color: Colors.white, fontSize: size.width * 0.04),
                ),
              ),
              TextButton(
                onPressed: () async {
                  if (kDebugMode) {
                    print("==========================================");
                    print("Change Phone Request:");
                    print("Old Phone: ${_phoneController.text}");
                    print("New Phone: ${newPhoneController.text}");
                    print("==========================================");
                  }
                  Navigator.pop(dialogContext);
                  bool verified =await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          OtpVerifyScreen(phoneNumber: newPhoneController.text),
                    ),
                  );
                  if (verified == true) {
                    GeneralFunctions.loadingCenter();
                    await SpUser.update(phoneNumber: PhoneNumberFormatter.formatLibyanPhone(newPhoneController.text),context: (mounted)?context:null);
                    // Update the phone number
                    setState(() {
                      _phoneController.text = newPhoneController.text;
                    });
                  }


                },
                child: Text(
                  'تغيير',
                  style: TextStyle(color: AppTheme.mainColor, fontSize: size.width * 0.04, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteAccountDialog(Size size) {
    showDialog(
      context: context,
      builder: (BuildContext dContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: AppTheme.darkCardColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(size.width * 0.043)),
            title: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.red, size: size.width * 0.075),
                SizedBox(width: size.width * 0.027),
                Text(
                  'تحذير',
                  style: TextStyle(color: Colors.white, fontSize: size.width * 0.053),
                ),
              ],
            ),
            content: Text(
              'هل أنت متأكد من حذف حسابك؟ هذا الإجراء لا يمكن التراجع عنه.',
              style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: size.width * 0.04),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'إلغاء',
                  style: TextStyle(color: Colors.white, fontSize: size.width * 0.04),
                ),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(dContext);
                  await SpUser.update(deletionDate: DateTime.now(),context: (mounted)?context:null);
                  GeneralConstant.userLogged = null;
                  await SharedPreference.sharedPreferencesSetDynamic(SharedPreference.userLoggedKey, null);

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

                  if (kDebugMode) {
                    print("==========================================");
                    print("Account Deletion Requested");
                    print("==========================================");
                  }
                },
                child: Text(
                  'حذف',
                  style: TextStyle(color: Colors.red, fontSize: size.width * 0.04),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
