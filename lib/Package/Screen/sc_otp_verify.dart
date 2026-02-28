import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:seiiarty_package/Package/Core/app_theme.dart';
import 'package:seiiarty_package/Package/Widget/my_appbar.dart';

import '../Core/phone_number_formatter.dart';

// ── Scenario enum ─────────────────────────────────────────────────────────────
enum OtpScenario {
  forgotPassword,
  // add more scenarios here as the app grows
}

extension OtpScenarioLabels on OtpScenario {
  String get title {
    switch (this) {
      case OtpScenario.forgotPassword:
        return 'التحقق من الرمز';
    }
  }

  String get subtitle {
    switch (this) {
      case OtpScenario.forgotPassword:
        return 'تم إرسال رمز التحقق إلى';
    }
  }

  String get buttonLabel {
    switch (this) {
      case OtpScenario.forgotPassword:
        return 'تحقق من الرمز';
    }
  }
}
// ─────────────────────────────────────────────────────────────────────────────

class OtpVerifyScreen extends StatefulWidget {
  final String      phoneNumber;
  final OtpScenario scenario;
  final dynamic user;

  const OtpVerifyScreen({
    super.key,
    required this.phoneNumber,
    this.scenario = OtpScenario.forgotPassword,
    this.user,
  });

  @override
  State<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends State<OtpVerifyScreen>
    with SingleTickerProviderStateMixin {
  final _otpControllers = List.generate(4, (_) => TextEditingController());
  bool _isLoading   = false;
  bool _otpVerified = false;

  late AnimationController _slideController;
  late Animation<Offset>   _slideAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
        duration: const Duration(milliseconds: 800), vsync: this);
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero)
            .animate(CurvedAnimation(
            parent: _slideController, curve: Curves.easeOutCubic));
    _slideController.forward();
  }

  Future<void> _verifyOTP() async {
    final otp = _otpControllers.map((c) => c.text).join();
    if (otp.length != 4) {
      _showSnackBar('رجاءً أدخل OTP الكامل', AppTheme.warningColor);
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2)); // replace with real API
    setState(() {
      _isLoading   = false;
      _otpVerified = true;
    });

    _showSnackBar('تم التحقق من رقم الهاتف!', AppTheme.successColor);

    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) Navigator.pop(context, true);
  }

  void _showSnackBar(String message, Color color) {
    final Size size = MediaQuery.sizeOf(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        message,
        style: TextStyle(fontSize: size.width * 0.035),
      ),
      backgroundColor: color,
      behavior:        SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(size.width * 0.03)),
      margin: EdgeInsets.all(size.width * 0.04),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppTheme.darkBackground,
        appBar: MyStyledAppBar(title:  widget.scenario.title,showBackButton: true,),
        body: Container(
          decoration: BoxDecoration(color: AppTheme.darkBackground),
          child: SafeArea(
            child: Column(
              children: [

                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(size.width * 0.06),
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(height: size.height * 0.04),
                          _buildHeader(size),
                          SizedBox(height: size.height * 0.04),
                          Directionality(
                            textDirection: TextDirection.ltr,
                            child: _buildOTPCard(size),
                          ),
                          SizedBox(height: size.height * 0.04),
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text(
                              'العودة إلى الخطوة السابقة',
                              style: TextStyle(
                                color:      AppTheme.grey,
                                fontSize:   size.width * 0.035,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }



  Widget _buildHeader(Size size) {
    return Column(
      children: [
        Container(
          height: size.width * 0.2,
          width:  size.width * 0.2,
          decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [AppTheme.gradientStart, AppTheme.gradientEnd]),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color:        AppTheme.mainColor.withOpacity(0.3),
                blurRadius:   size.width * 0.05,
                spreadRadius: size.width * 0.005,
              ),
            ],
          ),
          child: Icon(Icons.security,
              size: size.width * 0.1, color: Colors.white),
        ),
        SizedBox(height: size.height * 0.02),
        Text(
          widget.scenario.title,
          style: TextStyle(
            fontSize:   size.width * 0.06,
            fontWeight: FontWeight.bold,
            color:      Colors.white,
          ),
        ),
        SizedBox(height: size.height * 0.01),
        Text(
          '${widget.scenario.subtitle} ${PhoneNumberFormatter.toLocalFormat(widget.phoneNumber)}',
          style: TextStyle(
            fontSize: size.width * 0.035,
            color:    AppTheme.grey,
            height:   1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildOTPCard(Size size) {
    return Container(
      padding: EdgeInsets.all(size.width * 0.06),
      decoration: BoxDecoration(
        color:        AppTheme.darkCardColor,
        borderRadius: BorderRadius.circular(size.width * 0.06),
        border:       Border.all(color: AppTheme.darkBorderColor),
        boxShadow: [
          BoxShadow(
            color:     Colors.black.withOpacity(0.2),
            blurRadius: size.width * 0.05,
            offset:    Offset(0, size.height * 0.012),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.security,
                  color: AppTheme.mainColor, size: size.width * 0.05),
              SizedBox(width: size.width * 0.02),
              Text(
                'أدخل رمز التحقق',
                style: TextStyle(
                  fontSize:   size.width * 0.035,
                  fontWeight: FontWeight.w600,
                  color:      Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: size.height * 0.03),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(4, (i) => _buildOTPField(i, size)),
          ),
          SizedBox(height: size.height * 0.03),
          SizedBox(
            width:  double.infinity,
            height: size.height * 0.065,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _verifyOTP,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.mainColor,
                shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(size.width * 0.04)),
              ),
              child: _isLoading
                  ? SizedBox(
                width:  size.width * 0.05,
                height: size.width * 0.05,
                child: const CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2),
              )
                  : Text(
                widget.scenario.buttonLabel,
                style: TextStyle(
                  color:      Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize:   size.width * 0.04,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOTPField(int index, Size size) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width:  size.width * 0.14,
      height: size.width * 0.14,
      decoration: BoxDecoration(
        color:        AppTheme.darkTextFieldBg,
        borderRadius: BorderRadius.circular(size.width * 0.03),
        border: Border.all(
          color: _otpControllers[index].text.isNotEmpty
              ? AppTheme.mainColor
              : AppTheme.darkBorderColor,
          width: _otpControllers[index].text.isNotEmpty ? 2 : 1,
        ),
      ),
      child: TextFormField(
        controller:   _otpControllers[index],
        textAlign:    TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength:    1,
        enabled:      !_otpVerified,
        style: TextStyle(
          fontSize:   size.width * 0.06,
          fontWeight: FontWeight.bold,
          color: _otpVerified ? AppTheme.successColor : Colors.white,
        ),
        decoration: const InputDecoration(
          counterText: '',
          border:      InputBorder.none,
          filled:      false,
        ),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: (value) {
          setState(() {});
          if (value.isNotEmpty && index < 3)
            FocusScope.of(context).nextFocus();
          if (index == 3 && value.isNotEmpty)
            FocusScope.of(context).unfocus();
        },
      ),
    );
  }

  @override
  void dispose() {
    _slideController.dispose();
    for (final c in _otpControllers) {
      c.dispose();
    }
    super.dispose();
  }
}