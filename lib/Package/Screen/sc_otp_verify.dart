import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:seiiarty_package/Package/Core/app_theme.dart';

class OtpVerifyScreen extends StatefulWidget {
  final String phoneNumber;

  const OtpVerifyScreen({super.key, required this.phoneNumber});

  @override
  State<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends State<OtpVerifyScreen>
    with SingleTickerProviderStateMixin {
  final _otpControllers = List.generate(4, (_) => TextEditingController());
  bool _isLoading = false;
  bool _otpVerified = false;

  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(begin: Offset(0, 0.5), end: Offset.zero)
        .animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );
    _slideController.forward();
  }

  Future<void> _verifyOTP() async {
    String otp = _otpControllers.map((c) => c.text).join();
    if (otp.length != 4) {
      _showSnackBar('رجاءً أدخل OTP الكامل', AppTheme.warningColor);
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(Duration(seconds: 2));

    setState(() {
      _isLoading = false;
      _otpVerified = true;
    });

    _showSnackBar('تم التحقق من رقم الهاتف!', AppTheme.successColor);

    await Future.delayed(Duration(milliseconds: 500));
    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: Container(
        decoration: BoxDecoration(color: AppTheme.darkBackground),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 32),
                        _buildHeader(),
                        const SizedBox(height: 32),
                        _buildOTPCard(),
                        const SizedBox(height: 32),
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text(
                            'العودة إلى الخطوة السابقة',
                            style: TextStyle(
                              color: AppTheme.grey,
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
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context, false),
          ),
          Text(
            'التحقق من الرمز',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          height: 80,
          width: 80,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.gradientStart, AppTheme.gradientEnd],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppTheme.mainColor.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Icon(Icons.security, size: 40, color: Colors.white),
        ),
        const SizedBox(height: 16),
        Text(
          'التحقق من الرمز',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'تم إرسال رمز التحقق إلى ${widget.phoneNumber}',
          style: TextStyle(fontSize: 14, color: AppTheme.grey, height: 1.5),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildOTPCard() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.darkCardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.darkBorderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.security, color: AppTheme.mainColor, size: 20),
              const SizedBox(width: 8),
              Text(
                'أدخل رمز التحقق',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(4, (index) => _buildOTPField(index)),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _verifyOTP,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.mainColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _isLoading
                  ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
                  : Text(
                'تحقق من الرمز',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOTPField(int index) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      width: 55,
      height: 55,
      decoration: BoxDecoration(
        color: AppTheme.darkTextFieldBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _otpControllers[index].text.isNotEmpty
              ? AppTheme.mainColor
              : AppTheme.darkBorderColor,
          width: _otpControllers[index].text.isNotEmpty ? 2 : 1,
        ),
      ),
      child: TextFormField(
        controller: _otpControllers[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        enabled: !_otpVerified,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: _otpVerified ? AppTheme.successColor : Colors.white,
        ),
        decoration: InputDecoration(
          counterText: '',
          border: InputBorder.none,
          filled: false,
        ),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: (value) {
          setState(() {});
          if (value.isNotEmpty && index < 3) {
            FocusScope.of(context).nextFocus();
          }
          if (index == 3 && value.isNotEmpty) {
            FocusScope.of(context).unfocus();
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    _slideController.dispose();
    for (var c in _otpControllers) {
      c.dispose();
    }
    super.dispose();
  }
}