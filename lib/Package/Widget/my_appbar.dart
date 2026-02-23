import 'package:flutter/material.dart';
import '../Core/app_theme.dart';
import '../Core/general_const.dart';

class MyStyledAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final GlobalKey<ScaffoldState>? scaffoldKey;
  final List<Widget>? actions;
  final bool showBackButton;
  final bool empty;
  const MyStyledAppBar({
    super.key,
    required this.title,
    this.scaffoldKey,
    this.actions,
    this.showBackButton = false,
    this.empty = false,
  });

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.gradientStart, AppTheme.gradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.mainColor.withOpacity(0.3),
            blurRadius: size.width * 0.04,
            offset: Offset(0, size.height * 0.005),
          )
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.021,
            vertical: size.height * 0.01,
          ),
          child: Row(
            children: [
              // Back Button or Menu Button
              if(!empty)...[showBackButton
                  ? _buildBackButton(context, size)
                  : _buildMenuButton(context, size),

                SizedBox(width: size.width * 0.032),
              ],

              // Title
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: size.width * 0.053,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),

              // Show actions, notification, and avatar only if NOT back button mode
              if (!showBackButton && !empty) ...[
                // Action Buttons
                if (actions != null) ...actions!,

                // Notification Bell with Badge
                _buildNotificationButton(size),

                SizedBox(width: size.width * 0.021),


              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context, Size size) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(size.width * 0.032),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(size.width * 0.032),
          onTap: () {
            Navigator.pop(context);
          },
          child: Padding(
            padding: EdgeInsets.all(size.width * 0.027),
            child: Icon(
              Icons.arrow_back_rounded,
              color: Colors.white,
              size: size.width * 0.064,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, Size size) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(size.width * 0.032),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(size.width * 0.032),
          onTap: () {
            scaffoldKey?.currentState?.openDrawer();
          },
          child: Padding(
            padding: EdgeInsets.all(size.width * 0.027),
            child: Icon(
              Icons.menu_rounded,
              color: Colors.white,
              size: size.width * 0.064,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationButton(Size size) {
    return Container(
      margin: EdgeInsets.only(right: size.width * 0.011),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(size.width * 0.032),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(size.width * 0.032),
                onTap: () {
                  // Handle notification
                },
                child: Padding(
                  padding: EdgeInsets.all(size.width * 0.027),
                  child: Icon(
                    Icons.notifications_rounded,
                    color: Colors.white,
                    size: size.width * 0.059,
                  ),
                ),
              ),
            ),
          ),
          // Notification Badge
          Positioned(
            top: -size.width * 0.011,
            right: -size.width * 0.011,
            child: Container(
              padding: EdgeInsets.all(size.width * 0.011),
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: size.width * 0.005,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.4),
                    blurRadius: size.width * 0.021,
                    offset: Offset(0, size.height * 0.0025),
                  )
                ],
              ),
              constraints: BoxConstraints(
                minWidth: size.width * 0.053,
                minHeight: size.width * 0.053,
              ),
              child: Center(
                child: Text(
                  '3',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: size.width * 0.027,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }



  @override
  Size get preferredSize => Size.fromHeight(70);
}

class MinimalistAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onMenuTap;

  const MinimalistAppBar({Key? key, required this.title, this.onMenuTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: size.width * 0.027,
            offset: Offset(0, size.height * 0.0025),
          )
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.053,
            vertical: size.height * 0.02,
          ),
          child: Row(
            children: [
              // Animated Menu Icon
              _AnimatedMenuIcon(onTap: onMenuTap, size: size),

              SizedBox(width: size.width * 0.053),

              // Title
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: Color(0xFF2D3142),
                    fontSize: size.width * 0.059,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
              ),

              // Search Button
              _IconButton(
                icon: Icons.search_rounded,
                onTap: () {},
                size: size,
              ),

              SizedBox(width: size.width * 0.032),

              // Profile with Status
              _ProfileBubble(size: size),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(70);
}

class _AnimatedMenuIcon extends StatefulWidget {
  final VoidCallback? onTap;
  final Size size;

  const _AnimatedMenuIcon({this.onTap, required this.size});

  @override
  State<_AnimatedMenuIcon> createState() => _AnimatedMenuIconState();
}

class _AnimatedMenuIconState extends State<_AnimatedMenuIcon> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: 1 - (_controller.value * 0.1),
            child: Container(
              padding: EdgeInsets.all(widget.size.width * 0.021),
              decoration: BoxDecoration(
                color: AppTheme.mainColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(widget.size.width * 0.032),
              ),
              child: Icon(
                Icons.menu_rounded,
                color: AppTheme.mainColor,
                size: widget.size.width * 0.064,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Size size;

  const _IconButton({
    required this.icon,
    required this.onTap,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(size.width * 0.032),
        child: Container(
          padding: EdgeInsets.all(size.width * 0.027),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(size.width * 0.032),
          ),
          child: Icon(
            icon,
            size: size.width * 0.053,
            color: Color(0xFF2D3142),
          ),
        ),
      ),
    );
  }
}

class _ProfileBubble extends StatelessWidget {
  final Size size;

  const _ProfileBubble({required this.size});

  @override
  Widget build(BuildContext context) {
    // Check if user data is available
    if (GeneralConstant.userLogged == null ||
        GeneralConstant.userLogged["FullName"] == null) {
      return SizedBox.shrink();
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: EdgeInsets.all(size.width * 0.005),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [AppTheme.gradientStart, AppTheme.gradientEnd],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: CircleAvatar(
            radius: size.width * 0.048,
            backgroundColor: Colors.white,
            child: Text(
              GeneralConstant.userLogged["FullName"].toString().substring(0, 1).toUpperCase(),
              style: TextStyle(
                fontSize: size.width * 0.037,
                fontWeight: FontWeight.bold,
                color: AppTheme.mainColor,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: size.width * 0.032,
            height: size.width * 0.032,
            decoration: BoxDecoration(
              color: Color(0xFF4CAF50),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: size.width * 0.005,
              ),
            ),
          ),
        ),
      ],
    );
  }
}