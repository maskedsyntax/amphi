import 'package:flutter/material.dart';

class AppThemes {
  static const Color amphiBlue = Color(0xFF2196F3);
  static const Color amphiNavy = Color(0xFF0D47A1);
  static const Color amphiAccent = Color(0xFF00B0FF);

  // Classic Theme: Elegant, Glassmorphism-lite, Rounded
  static ThemeData classic(bool isDark) {
    final scheme = ColorScheme.fromSeed(
      seedColor: amphiBlue,
      brightness: isDark ? Brightness.dark : Brightness.light,
      surface: isDark ? const Color(0xFF1A1C1E) : const Color(0xFFF8F9FA),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? Colors.white : Colors.black,
        titleTextStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: isDark ? Colors.white10 : Colors.black12),
        ),
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: amphiBlue,
        inactiveTrackColor: amphiBlue.withOpacity(0.2),
        thumbColor: amphiBlue,
        trackHeight: 4,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
      ),
    );
  }

  // Neubrutalism Theme: High-Contrast, Hard Edges, Bold Shadows
  static ThemeData neubrutalism(bool isDark) {
    final Color bgColor = isDark ? const Color(0xFF000000) : Colors.white;
    final Color borderColor = isDark ? Colors.white : Colors.black;

    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: bgColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: amphiBlue,
        brightness: isDark ? Brightness.dark : Brightness.light,
      ).copyWith(
        primary: amphiBlue,
        surface: bgColor,
        onSurface: isDark ? Colors.white : Colors.black,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: bgColor,
        elevation: 0,
        shape: Border(bottom: BorderSide(color: borderColor, width: 3)),
        titleTextStyle: TextStyle(
          color: isDark ? Colors.white : Colors.black,
          fontWeight: FontWeight.w900,
          fontSize: 24,
          letterSpacing: -1,
        ),
      ),
      cardTheme: CardThemeData(
        color: bgColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: borderColor, width: 3),
          borderRadius: BorderRadius.zero,
        ),
      ),
      sliderTheme: SliderThemeData(
        trackHeight: 12,
        activeTrackColor: amphiBlue,
        inactiveTrackColor: isDark ? Colors.white24 : Colors.black12,
        thumbColor: amphiAccent,
        thumbShape: const RoundSliderThumbShape(
          enabledThumbRadius: 12,
          elevation: 0,
          pressedElevation: 0,
        ),
        overlayColor: amphiBlue.withOpacity(0.2),
        trackShape: const RectangularSliderTrackShape(),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: amphiBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          shape: RoundedRectangleBorder(
            side: BorderSide(color: borderColor, width: 3),
            borderRadius: BorderRadius.zero,
          ),
        ).copyWith(
          overlayColor: WidgetStateProperty.all(Colors.white24),
        ),
      ),
    );
  }
}
