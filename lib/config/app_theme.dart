import 'package:flutter/material.dart';

/// Neon Nightlife Theme Configuration
/// Inspired by cyberpunk gaming and Las Vegas casino aesthetics
class AppTheme {
  // Primary Colors - Neon Nightlife Palette
  static const Color hotPink = Color(
    0xFFFF1493,
  ); // Primary - Bet invitations, uploads
  static const Color electricYellow = Color(
    0xFFFFFF33,
  ); // Accent - Wins, streaks, challenges
  static const Color neonBlue = Color(
    0xFF00FFFF,
  ); // Secondary - Navigation, profiles
  static const Color darkSlateGray = Color(0xFF2F4F4F); // Neutral - Backgrounds

  // Additional colors for depth
  static const Color deepNavy = Color(0xFF0A0E27); // Dark background
  static const Color richPurple = Color(0xFF6B21F5); // Alternative accent
  static const Color neonGreen = Color(0xFF39FF14); // Success/Live indicators

  // Functional colors
  static const Color successColor = neonGreen;
  static const Color warningColor = electricYellow;
  static const Color errorColor = hotPink;
  static const Color infoColor = neonBlue;

  // Text colors
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color textMuted = Color(0xFF6B7280);

  // Build the dark theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Color scheme
      colorScheme: ColorScheme.dark(
        primary: hotPink,
        secondary: neonBlue,
        tertiary: electricYellow,
        surface: deepNavy,
        error: hotPink,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: textPrimary,
      ),

      // Scaffold background
      scaffoldBackgroundColor: deepNavy,

      // AppBar theme
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: neonBlue),
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),

      // Card theme
      cardTheme: CardThemeData(
        color: darkSlateGray,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: hotPink,
          foregroundColor: Colors.white,
          elevation: 8,
          shadowColor: hotPink.withValues(alpha: 0.5),
          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
          ),
        ),
      ),

      // Outlined button theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: neonBlue,
          side: BorderSide(color: neonBlue, width: 2),
          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
          ),
        ),
      ),

      // Text button theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: electricYellow,
          textStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSlateGray,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: neonBlue.withValues(alpha: 0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: neonBlue.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: neonBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: hotPink, width: 2),
        ),
        labelStyle: TextStyle(color: textSecondary),
        hintStyle: TextStyle(color: textMuted),
      ),

      // Bottom navigation bar theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: deepNavy,
        selectedItemColor: hotPink,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 16,
        selectedLabelStyle: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        unselectedLabelStyle: TextStyle(fontSize: 11),
      ),

      // Icon theme
      iconTheme: IconThemeData(color: neonBlue, size: 24),

      // Text theme
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textPrimary,
          letterSpacing: 1.5,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textPrimary,
          letterSpacing: 1.2,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        headlineLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        bodyLarge: TextStyle(fontSize: 16, color: textPrimary),
        bodyMedium: TextStyle(fontSize: 14, color: textPrimary),
        bodySmall: TextStyle(fontSize: 12, color: textSecondary),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: 1.0,
        ),
      ),

      // Floating action button theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: hotPink,
        foregroundColor: Colors.white,
        elevation: 12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      // Chip theme
      chipTheme: ChipThemeData(
        backgroundColor: darkSlateGray,
        labelStyle: TextStyle(color: textPrimary),
        side: BorderSide(color: neonBlue.withValues(alpha: 0.3)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),

      // Divider theme
      dividerTheme: DividerThemeData(
        color: neonBlue.withValues(alpha: 0.2),
        thickness: 1,
      ),
    );
  }

  // Gradient styles for special effects
  static LinearGradient get primaryGradient => LinearGradient(
    colors: [hotPink, richPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient get accentGradient => LinearGradient(
    colors: [neonBlue, neonGreen],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient get winGradient => LinearGradient(
    colors: [neonGreen, electricYellow],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient get loseGradient => LinearGradient(
    colors: [hotPink, Colors.red.shade900],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Glow effects for neon aesthetic
  static BoxShadow neonGlow(Color color, {double blurRadius = 20}) {
    return BoxShadow(
      color: color.withValues(alpha: 0.6),
      blurRadius: blurRadius,
      spreadRadius: blurRadius / 4,
    );
  }

  // Button styles for betting actions
  static BoxDecoration landButtonDecoration = BoxDecoration(
    gradient: LinearGradient(
      colors: [neonGreen, Color(0xFF00FF88)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(12),
    boxShadow: [neonGlow(neonGreen)],
  );

  static BoxDecoration failButtonDecoration = BoxDecoration(
    gradient: LinearGradient(
      colors: [hotPink, Color(0xFFFF006E)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(12),
    boxShadow: [neonGlow(hotPink)],
  );
}
