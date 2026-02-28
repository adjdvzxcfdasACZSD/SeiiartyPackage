import 'package:flutter/material.dart';
import 'package:seiiarty_package/Package/Core/app_theme.dart';
import 'package:seiiarty_package/Package/Widget/my_appbar.dart';

class AboutAppScreen extends StatefulWidget {
  const AboutAppScreen({super.key});

  @override
  _AboutAppScreenState createState() => _AboutAppScreenState();
}

class _AboutAppScreenState extends State<AboutAppScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppTheme.darkBackground,
        appBar: MyStyledAppBar(title: 'عن التطبيق', showBackButton: true),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: ClampingScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.06,
              vertical: size.height * 0.02,
            ),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── App Logo ───────────────────────────────────────────
                  _buildLogo(size),
                  SizedBox(height: size.height * 0.04),

                  // ── About App Section ──────────────────────────────────
                  _buildSectionTitle(size, Icons.info_outline, 'عن التطبيق'),
                  SizedBox(height: size.height * 0.02),
                  _buildAboutCard(size),
                  SizedBox(height: size.height * 0.03),

                  // ── How it works Section ───────────────────────────────
                  _buildSectionTitle(size, Icons.help_outline, 'كيف يعمل؟'),
                  SizedBox(height: size.height * 0.02),
                  _buildHowItWorksCard(size),
                  SizedBox(height: size.height * 0.03),

                  // ── Developer Section ──────────────────────────────────
                  _buildSectionTitle(size, Icons.code, 'المطور'),
                  SizedBox(height: size.height * 0.02),
                  _buildDeveloperCard(size),
                  SizedBox(height: size.height * 0.04),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Logo ────────────────────────────────────────────────────────────────────
  Widget _buildLogo(Size size) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(seconds: 1),
      builder: (context, double value, child) {
        return Transform.scale(
          scale: value,
          child: Center(
            child: Container(
              height: size.width * 0.28,
              width: size.width * 0.28,
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
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Icon(
                Icons.search,
                size: size.width * 0.13,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Section title ────────────────────────────────────────────────────────────
  Widget _buildSectionTitle(Size size, IconData icon, String title) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(size.width * 0.02),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.gradientStart, AppTheme.gradientEnd],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.white, size: size.width * 0.05),
        ),
        SizedBox(width: size.width * 0.03),
        Text(
          title,
          style: TextStyle(
            fontSize: size.width * 0.05,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  // ── Glass card base ──────────────────────────────────────────────────────────
  Widget _buildGlassCard({required Size size, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(size.width * 0.05),
      decoration: BoxDecoration(
        color: AppTheme.darkBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.darkBorderColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }

  // ── About card ───────────────────────────────────────────────────────────────
  Widget _buildAboutCard(Size size) {
    return _buildGlassCard(
      size: size,
      child: Text(
        'سيارتي هو تطبيق يساعدك على إيجاد ما تبحث عنه بسرعة وسهولة. '
            'لم تعد بحاجة إلى التجول بين المحلات بحثاً عن قطعة أو منتج معين، '
            'كل ما عليك هو فتح التطبيق والبحث عن ما تريد.',
        style: TextStyle(
          fontSize: size.width * 0.038,
          color: AppTheme.grey,
          height: 1.8,
        ),
        textAlign: TextAlign.justify,
      ),
    );
  }

  // ── How it works card ────────────────────────────────────────────────────────
  Widget _buildHowItWorksCard(Size size) {
    final List<_Step> steps = [
      _Step(
        icon: Icons.search,
        title: 'ابحث عن منتجك',
        description: 'افتح التطبيق وابحث عن الشيء الذي تريده من خلال خاصية البحث.',
      ),
      _Step(
        icon: Icons.touch_app,
        title: 'اختر وأرسل طلبك',
        description: 'اختر المنتج المناسب واضغط على زر "طلب" لإرسال طلبك.',
      ),
      _Step(
        icon: Icons.store,
        title: 'يصل الطلب للبائعين',
        description: 'يتم إرسال طلبك فوراً إلى جميع البائعين والمحلات المسجلة في التطبيق.',
      ),
      _Step(
        icon: Icons.reply,
        title: 'البائع يرد عليك',
        description: 'إذا كان البائع يملك المنتج، يرسل لك رسالة بالسعر والموقع.',
      ),
      _Step(
        icon: Icons.location_on,
        title: 'أقرب موقع أولاً',
        description: 'يعرض لك التطبيق أقرب البائعين إليك أولاً لتوفير وقتك وجهدك.',
      ),
      _Step(
        icon: Icons.shopping_bag,
        title: 'اذهب واشترِ',
        description: 'توجه إلى المحل واحصل على ما تريد بكل سهولة.',
      ),
    ];

    return _buildGlassCard(
      size: size,
      child: Column(
        children: steps
            .asMap()
            .entries
            .map((entry) => _buildStepRow(size, entry.key + 1, entry.value,
            isLast: entry.key == steps.length - 1))
            .toList(),
      ),
    );
  }

  // ── Single step row ──────────────────────────────────────────────────────────
  Widget _buildStepRow(Size size, int stepNumber, _Step step,
      {bool isLast = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Step number + connector line ─────────────────────────────
        Column(
          children: [
            Container(
              height: size.width * 0.09,
              width: size.width * 0.09,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.gradientStart, AppTheme.gradientEnd],
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$stepNumber',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: size.width * 0.035,
                  ),
                ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: size.height * 0.06,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.mainColor.withOpacity(0.6),
                      AppTheme.mainColor.withOpacity(0.1),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
          ],
        ),
        SizedBox(width: size.width * 0.04),

        // ── Step content ─────────────────────────────────────────────
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : size.height * 0.02),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(step.icon,
                        color: AppTheme.mainColor, size: size.width * 0.045),
                    SizedBox(width: size.width * 0.02),
                    Text(
                      step.title,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: size.width * 0.038,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: size.height * 0.006),
                Text(
                  step.description,
                  style: TextStyle(
                    color: AppTheme.grey,
                    fontSize: size.width * 0.033,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Developer card ───────────────────────────────────────────────────────────
  Widget _buildDeveloperCard(Size size) {
    return _buildGlassCard(
      size: size,
      child: Row(
        children: [
          // ── Avatar ──────────────────────────────────────────────────
          Container(
            height: size.width * 0.15,
            width: size.width * 0.15,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.gradientStart, AppTheme.gradientEnd],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.mainColor.withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              Icons.person,
              color: Colors.white,
              size: size.width * 0.08,
            ),
          ),
          SizedBox(width: size.width * 0.04),

          // ── Name & role ──────────────────────────────────────────────
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'رضوان بن موسى',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: size.width * 0.045,
                ),
              ),
              SizedBox(height: size.height * 0.005),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.03,
                  vertical: size.height * 0.004,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.mainColor.withOpacity(0.2),
                      AppTheme.mainColor.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppTheme.mainColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  'مطور التطبيق',
                  style: TextStyle(
                    color: AppTheme.mainColor,
                    fontSize: size.width * 0.03,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
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
}

// ── Step data model ──────────────────────────────────────────────────────────
class _Step {
  final IconData icon;
  final String title;
  final String description;

  const _Step({
    required this.icon,
    required this.title,
    required this.description,
  });
}