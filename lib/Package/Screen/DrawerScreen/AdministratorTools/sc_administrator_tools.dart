import 'package:flutter/material.dart';
import 'package:seiiarty_package/Package/Core/app_theme.dart';
import 'package:seiiarty_package/Package/Screen/DrawerScreen/AdministratorTools/sc_Category_edit.dart';
import 'package:seiiarty_package/Package/Screen/DrawerScreen/AdministratorTools/sc_Item_edit.dart';
import 'package:seiiarty_package/Package/Widget/my_appbar.dart';
import '../../../Widget/my_drawer.dart';

class AdminToolsScreen extends StatefulWidget {
  const AdminToolsScreen({super.key});

  @override
  State<AdminToolsScreen> createState() => _AdminToolsScreenState();
}

class _AdminToolsScreenState extends State<AdminToolsScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: AppTheme.darkBackground,
        drawer: MyDrawer(afterTap: () => setState(() {})),
        appBar: MyStyledAppBar(
          title: "أدوات المدير",
          scaffoldKey: _scaffoldKey,
          showBackButton: true,
        ),
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(size.width * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(size),
                  SizedBox(height: size.height * 0.035),
                  _buildSectionTitle(size, "إدارة البيانات"),
                  SizedBox(height: size.height * 0.02),
                  _buildToolCard(
                    size: size,
                    icon: Icons.build_circle_outlined,
                    title: "إدارة القطع",
                    subtitle: "إضافة، تعديل، حذف وتجميد القطع",
                    color: Colors.orange,
                    onTap: () => Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder:
                            (context, animation, secondaryAnimation) =>
                        const ItemEditScreen(),
                      ),
                    ),
                  ),
                  SizedBox(height: size.height * 0.015),

                  _buildToolCard(
                    size: size,
                    icon: Icons.category_outlined,
                    title: "إدارة الفئات",
                    subtitle: "إضافة، تعديل، حذف وتجميد الفئات",
                    color: Colors.teal,
                    onTap: () => Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder:
                            (context, animation, secondaryAnimation) =>
                        const CategoryEditScreen(),
                      ),
                    ),
                  ),
                  // ── Add more tool cards here as the app grows ──
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── Widgets ──────────────────────────────────────────────────────────────

  Widget _buildHeader(Size size) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(size.width * 0.06),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.gradientStart, AppTheme.gradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(size.width * 0.05),
        boxShadow: [
          BoxShadow(
            color: AppTheme.mainColor.withOpacity(0.3),
            blurRadius: size.width * 0.05,
            offset: Offset(0, size.height * 0.012),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(size.width * 0.035),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(size.width * 0.04),
            ),
            child: Icon(
              Icons.admin_panel_settings_outlined,
              color: Colors.white,
              size: size.width * 0.08,
            ),
          ),
          SizedBox(width: size.width * 0.04),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "أدوات المدير",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: size.width * 0.055,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: size.height * 0.005),
              Text(
                "تحكم كامل في بيانات التطبيق",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: size.width * 0.033,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(Size size, String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: size.width * 0.045,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _buildToolCard({
    required Size size,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(size.width * 0.05),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(size.width * 0.045),
          border: Border.all(color: AppTheme.darkBorderColor, width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(size.width * 0.035),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(size.width * 0.035),
              ),
              child: Icon(icon, color: color, size: size.width * 0.07),
            ),
            SizedBox(width: size.width * 0.04),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: size.width * 0.04,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: size.height * 0.005),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: size.width * 0.03,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(size.width * 0.02),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(size.width * 0.025),
              ),
              child: Icon(
                Icons.arrow_back_ios_new,
                color: color,
                size: size.width * 0.035,
              ),
            ),
          ],
        ),
      ),
    );
  }
}