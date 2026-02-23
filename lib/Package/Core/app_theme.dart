import 'package:flutter/material.dart';

class AppTheme {
  // Snackbar Message Colors - Purple themed
  static const String colorReset = '\x1B[0m';
  static const String colorCyan = '\x1B[36m';
  static const String colorGreen = '\x1B[32m';
  static const String colorYellow = '\x1B[33m';
  static const String colorRed = '\x1B[31m';
  static const String colorMagenta = '\x1B[35m';
  static const String colorBlue = '\x1B[34m';

  static const Color msgSnackInfoColor = Color(0xFF9C88FF);
  static const Color msgSnackWarningColor = Color(0xFFB794F6);
  static const Color msgSnackSuccessColor = Color(0xFF8B7FE8);

  // Dark Purple Theme Colors - Enhanced
  static const Color darkBackground = Color(0xFF1F1F1F);        // Deep dark purple-black
  static const Color darkCardColor = Color(0xFF1A1825);         // Rich dark purple
  static const Color darkSurfaceColor = Color(0xFF252032);      // Elevated purple surface
  static const Color darkTextFieldBg = Color(0xFF1E1B2E);       // Subtle purple for inputs
  static const Color darkBorderColor = Color(0xFF2D2640);       // Purple-tinted borders

  // Additional Dark Theme Shades
  static const Color darkElevated = Color(0xFF2A2540);          // For hover/pressed states
  static const Color darkDivider = Color(0xFF312952);           // For dividers/separators
  static const Color darkOverlay = Color(0x33000000);           // For overlays

  // Primary Purple Palette
  static const Color mainColor = Color(0xFF7C3AED);             // Vibrant purple (primary)
  static const Color accentColor = Color(0xFF9C6FFF);           // Lighter purple accent
  static const Color secondaryColor = Color(0xFFA78BFA);        // Soft purple
  static const Color deepPurple = Color(0xFF5B21B6);            // Deep rich purple

  // Gradient Colors - Enhanced Purple Gradients
  static const Color gradientStart = Color(0xFF7C3AED);         // Primary purple
  static const Color gradientMid = Color(0xFF9C6FFF);           // Mid transition
  static const Color gradientEnd = Color(0xFFC4B5FD);           // Light purple end

  // Alternative Gradients
  static const Color darkGradientStart = Color(0xFF5B21B6);
  static const Color darkGradientEnd = Color(0xFF7C3AED);

  // Status Colors - Purple-themed
  static const Color successColor = Color(0xFF8B5CF6);          // Purple success
  static const Color dangerColor = Color(0xFFDC2626);           // Red (keep distinct)
  static const Color warningColor = Color(0xFFF59E0B);          // Amber (keep distinct)
  static const Color infoColor = Color(0xFF818CF8);             // Info purple-blue

  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);           // White
  static const Color textSecondary = Color(0xFFE2E8F0);         // Light gray
  static const Color textTertiary = Color(0xFFA0AEC0);          // Medium gray
  static const Color textMuted = Color(0xFF718096);             // Muted gray
  static const Color textDisabled = Color(0xFF4A5568);          // Disabled gray

  // UI Element Colors
  static const Color grey = Color(0xFF94A3B8);
  static const Color greyLight = Color(0xFFCBD5E1);
  static const Color greyDark = Color(0xFF475569);

  // Shimmer Colors for Loading States
  static const Color shimmerBase = Color(0xFF1E1B2E);
  static const Color shimmerHighlight = Color(0xFF2D2640);

  // Icon Colors
  static const Color iconPrimary = Color(0xFFFFFFFF);
  static const Color iconSecondary = Color(0xFFA78BFA);
  static const Color iconMuted = Color(0xFF718096);

  // Shadow Colors
  static const Color shadowLight = Color(0x1A000000);
  static const Color shadowMedium = Color(0x33000000);
  static const Color shadowHeavy = Color(0x4D000000);
  static const Color purpleShadow = Color(0x407C3AED);

  // Glassmorphism Colors
  static const Color glassBackground = Color(0x1AFFFFFF);
  static const Color glassBorder = Color(0x33FFFFFF);
  static const Color errorColor = Color(0xFFFF5252);
  // Theme Data
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: mainColor,
    scaffoldBackgroundColor: darkBackground,
    cardColor: darkCardColor,
    dividerColor: darkDivider,

    colorScheme: ColorScheme.dark(
      primary: mainColor,
      secondary: accentColor,
      tertiary: secondaryColor,
      surface: darkSurfaceColor,
      background: darkBackground,
      error: dangerColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: textPrimary,
      onBackground: textPrimary,
      onError: Colors.white,
      outline: darkBorderColor,
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: darkBackground,
      elevation: 0,
      iconTheme: IconThemeData(color: iconPrimary),
      actionsIconTheme: IconThemeData(color: iconSecondary),
      titleTextStyle: TextStyle(
        color: textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
      ),
      centerTitle: true,
    ),

    textTheme: TextTheme(
      // Headlines
      headlineLarge: TextStyle(
        color: textPrimary,
        fontSize: 32,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
      ),
      headlineMedium: TextStyle(
        color: textPrimary,
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
      headlineSmall: TextStyle(
        color: textPrimary,
        fontSize: 24,
        fontWeight: FontWeight.w600,
      ),

      // Titles
      titleLarge: TextStyle(
        color: textPrimary,
        fontSize: 22,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: TextStyle(
        color: textSecondary,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: TextStyle(
        color: textSecondary,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),

      // Body
      bodyLarge: TextStyle(
        color: textSecondary,
        fontSize: 16,
        fontWeight: FontWeight.normal,
      ),
      bodyMedium: TextStyle(
        color: textSecondary,
        fontSize: 14,
        fontWeight: FontWeight.normal,
      ),
      bodySmall: TextStyle(
        color: textTertiary,
        fontSize: 12,
        fontWeight: FontWeight.normal,
      ),

      // Labels
      labelLarge: TextStyle(
        color: textPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      labelMedium: TextStyle(
        color: textSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      labelSmall: TextStyle(
        color: textMuted,
        fontSize: 11,
        fontWeight: FontWeight.w500,
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      fillColor: darkTextFieldBg,
      filled: true,

      // Label Style
      labelStyle: TextStyle(
        color: textTertiary,
        fontSize: 14,
      ),
      floatingLabelStyle: TextStyle(
        color: mainColor,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),

      // Hint Style
      hintStyle: TextStyle(
        color: textMuted,
        fontSize: 14,
      ),

      // Content Padding
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),

      // Borders
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: darkBorderColor,
          width: 1.5,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: mainColor,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: dangerColor,
          width: 1.5,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: dangerColor,
          width: 2,
        ),
      ),

      // Error Style
      errorStyle: TextStyle(
        color: dangerColor,
        fontSize: 12,
      ),

      // Prefix/Suffix Icon Theme
      prefixIconColor: textMuted,
      suffixIconColor: textMuted,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: mainColor,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: mainColor,
        side: BorderSide(color: mainColor, width: 1.5),
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: mainColor,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    iconTheme: IconThemeData(
      color: iconSecondary,
      size: 24,
    ),

    dividerTheme: DividerThemeData(
      color: darkDivider,
      thickness: 1,
      space: 1,
    ),

    snackBarTheme: SnackBarThemeData(
      backgroundColor: darkCardColor,
      contentTextStyle: TextStyle(color: textPrimary),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      behavior: SnackBarBehavior.floating,
    ),
  );

  // Gradient Helpers
  static LinearGradient primaryGradient = LinearGradient(
    colors: [gradientStart, gradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient darkGradient = LinearGradient(
    colors: [darkGradientStart, darkGradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient purpleShimmer = LinearGradient(
    colors: [shimmerBase, shimmerHighlight, shimmerBase],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Box Shadow Helpers
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: shadowLight,
      blurRadius: 10,
      offset: Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get purpleGlow => [
    BoxShadow(
      color: purpleShadow,
      blurRadius: 20,
      spreadRadius: 2,
      offset: Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get elevatedShadow => [
    BoxShadow(
      color: shadowMedium,
      blurRadius: 15,
      offset: Offset(0, 6),
    ),
  ];
}