import 'package:flutter/material.dart';

class AppTheme {
  static final lightTheme = _createTheme(
    name: 'Light',
    brightness: Brightness.light,
    primary: Colors.blue[700]!,
    secondary: Colors.blueAccent[400]!,
    background: Colors.grey[50]!,
    surface: Colors.white,
    onSurface: Colors.black87,
    text: Colors.black87,
    error: Colors.redAccent,
    success: Colors.green[600]!,
    disabled: Colors.grey[300]!,
    hint: Colors.grey[500]!,
    warning: Color(0xFFFF9800),
  );

  static final darkTheme = _createTheme(
    name: 'Dark',
    brightness: Brightness.dark,
    primary: Colors.blueGrey,
    secondary: Color(0xFF2E3B4E),
    background: Colors.grey[900]!,
    surface: Colors.grey[800]!,
    onSurface: Colors.white70,
    error: Colors.red[300]!,
    success: Colors.green[300]!,
    text: Colors.white,
    disabled: Colors.grey[600]!,
    hint: Colors.grey[400]!,
    warning: Color(0xFFFF9800),
  );

  static final glassmorphismTheme = _createTheme(
    name: 'Glassmorphism',
    brightness: Brightness.light,
    primary: Colors.white.withOpacity(0.2),
    secondary: Colors.white.withOpacity(0.1),
    background: Colors.transparent,
    surface: Colors.white.withOpacity(0.1),
    onSurface: Colors.white,
    error: Colors.red.withOpacity(0.7),
    success: Colors.green.withOpacity(0.7),
    text: Colors.white,
    disabled: Colors.grey.withOpacity(0.5),
    hint: Colors.white70,
    warning: Color(0xFFFF9800),
  );

  static final neumorphismTheme = _createTheme(
    name: 'Neumorphism',
    brightness: Brightness.light,
    primary: Color(0xFFE0E0E0),
    secondary: Color(0xFFD0D0D0),
    background: Color(0xFFE0E0E0),
    surface: Color(0xFFE0E0E0),
    onSurface: Colors.black87,
    error: Colors.red[300]!,
    success: Colors.green[300]!,
    text: Colors.black87,
    disabled: Colors.grey[400]!,
    hint: Colors.grey[600]!,
    warning: Color(0xFFFF9800),
  );

  static final materialTheme = _createTheme(
    name: 'Material',
    brightness: Brightness.light,
    primary: Colors.blue,
    secondary: Colors.pink,
    background: Colors.grey[50]!,
    surface: Colors.white,
    onSurface: Colors.black87,
    error: Colors.red,
    success: Colors.green,
    text: Colors.black87,
    disabled: Colors.grey[400]!,
    hint: Colors.grey[600]!,
    warning: Color(0xFFFF9800),
  );

  static final gradientTheme = _createTheme(
    name: 'Gradient',
    brightness: Brightness.light,
    primary: Colors.purple,
    secondary: Colors.pink,
    background: Colors.white,
    surface: Colors.white,
    onSurface: Colors.black87,
    error: Colors.red,
    success: Colors.green,
    text: Colors.black87,
    disabled: Colors.grey[400]!,
    hint: Colors.grey[600]!,
    warning: Color(0xFFFF9800),
  );

  static final minimalTheme = _createTheme(
    name: 'Minimal',
    brightness: Brightness.light,
    primary: Colors.black,
    secondary: Colors.grey[800]!,
    background: Colors.white,
    surface: Colors.white,
    onSurface: Colors.black87,
    error: Colors.red[900]!,
    success: Colors.green[900]!,
    text: Colors.black87,
    disabled: Colors.grey[300]!,
    hint: Colors.grey[500]!,
    warning: Color(0xFFFF9800),
  );

  static final pastelTheme = _createTheme(
    name: 'Pastel',
    brightness: Brightness.light,
    primary: Color(0xFFFFB3BA),
    secondary: Color(0xFFFFDFBA),
    background: Color(0xFFFFFFE4),
    surface: Colors.white,
    onSurface: Colors.black87,
    error: Color(0xFFFFA07A),
    success: Color(0xFFBAFFB3),
    text: Colors.black87,
    disabled: Color(0xFFD3D3D3),
    hint: Colors.grey[600]!,
    warning: Color(0xFFFF9800),
  );

  static final retroTheme = _createTheme(
    name: 'Retro',
    brightness: Brightness.light,
    primary: Color(0xFFE8D03A),
    secondary: Color(0xFFF2622E),
    background: Color(0xFFF0E4D4),
    surface: Color(0xFFF5E6CC),
    onSurface: Colors.brown[800]!,
    error: Color(0xFFC41E3A),
    success: Color(0xFF1E8449),
    text: Colors.brown[800]!,
    disabled: Colors.brown[300]!,
    hint: Colors.brown[500]!,
    warning: Color(0xFFFF9800),
  );

  static final cyberpunkTheme = _createTheme(
    name: 'Cyberpunk',
    brightness: Brightness.dark,
    primary: Color(0xFF00FFFF),
    secondary: Color(0xFFFF00FF),
    background: Color(0xFF0D0221),
    surface: Color(0xFF1A1A2E),
    onSurface: Color(0xFF00FFFF),
    error: Color(0xFFFF0000),
    success: Color(0xFF00FF00),
    text: Color(0xFFE6E6FA),
    disabled: Colors.grey[600]!,
    hint: Colors.grey[400]!,
    warning: Color(0xFFFF9800),
  );

  static final greeneryTheme = _createTheme(
    name: 'Greenery',
    brightness: Brightness.light,
    primary: Color(0xFF7CB342),
    secondary: Color(0xFF8BC34A),
    background: Color(0xFFF1F8E9),
    surface: Colors.white,
    onSurface: Colors.black87,
    error: Colors.red[700]!,
    success: Color(0xFF4CAF50),
    text: Colors.black87,
    disabled: Colors.grey[400]!,
    hint: Colors.grey[600]!,
    warning: Color(0xFFFF9800),
  );

  static final woodenTheme = _createTheme(
    name: 'Wooden',
    brightness: Brightness.light,
    primary: Color(0xFF8B4513),
    secondary: Color(0xFFD2691E),
    background: Color(0xFFFFF8DC),
    surface: Color(0xFFFFEBCD),
    onSurface: Colors.brown[800]!,
    error: Color(0xFFB22222),
    success: Color(0xFF228B22),
    text: Colors.brown[800]!,
    disabled: Colors.brown[300]!,
    hint: Colors.brown[500]!,
    warning: Color(0xFFFF9800),
  );

  static final natureTheme = _createTheme(
    name: 'Nature',
    brightness: Brightness.light,
    primary: Color(0xFF4CAF50),
    secondary: Color(0xFF81C784),
    background: Color(0xFFF1F8E9),
    surface: Colors.white,
    onSurface: Colors.black87,
    error: Color(0xFFE57373),
    success: Color(0xFF81C784),
    text: Colors.black87,
    disabled: Colors.grey[400]!,
    hint: Colors.grey[600]!,
    warning: Color(0xFFFF9800),
  );

  static final spaceTheme = _createTheme(
    name: 'Space',
    brightness: Brightness.dark,
    primary: Color(0xFF3F51B5),
    secondary: Color(0xFF7986CB),
    background: Color(0xFF121212),
    surface: Color(0xFF212121),
    onSurface: Colors.white70,
    error: Color(0xFFFF5252),
    success: Color(0xFF69F0AE),
    text: Colors.white,
    disabled: Colors.grey[600]!,
    hint: Colors.grey[400]!,
    warning: Color(0xFFFF9800),
  );

  static final luxuryTheme = _createTheme(
    name: 'Luxury',
    brightness: Brightness.dark,
    primary: Color(0xFFFFD700),
    secondary: Color(0xFFFFA500),
    background: Color(0xFF1C1C1C),
    surface: Color(0xFF2C2C2C),
    onSurface: Color(0xFFE0E0E0),
    error: Color(0xFFFF4444),
    success: Color(0xFF00C851),
    text: Color(0xFFE0E0E0),
    disabled: Colors.grey[600]!,
    hint: Colors.grey[400]!,
    warning: Color(0xFFFF9800),
  );

  static final abstractTheme = _createTheme(
    name: 'Abstract',
    brightness: Brightness.light,
    primary: Color(0xFFFF6B6B),
    secondary: Color(0xFF4ECDC4),
    background: Color(0xFFF7FFF7),
    surface: Colors.white,
    onSurface: Colors.black87,
    error: Color(0xFFFF6B6B),
    success: Color(0xFF4ECDC4),
    text: Colors.black87,
    disabled: Colors.grey[400]!,
    hint: Colors.grey[600]!,
    warning: Color(0xFFFF9800),
  );

  static final futuristicTheme = _createTheme(
    name: 'Futuristic',
    brightness: Brightness.dark,
    primary: Color(0xFF00FFFF),
    secondary: Color(0xFF1E90FF),
    background: Color(0xFF000033),
    surface: Color(0xFF000066),
    onSurface: Colors.white,
    error: Color(0xFFFF4500),
    success: Color(0xFF32CD32),
    text: Colors.white,
    disabled: Colors.grey[600]!,
    hint: Colors.grey[400]!,
    warning: Color(0xFFFF9800),
  );

  static final vintageTheme = _createTheme(
    name: 'Vintage',
    brightness: Brightness.light,
    primary: Color(0xFF8E6C4E),
    secondary: Color(0xFFD4A76A),
    background: Color(0xFFF3E5D8),
    surface: Color(0xFFFFF8E1),
    onSurface: Colors.brown[800]!,
    error: Color(0xFFB22222),
    success: Color(0xFF556B2F),
    text: Colors.brown[800]!,
    disabled: Colors.brown[300]!,
    hint: Colors.brown[500]!,
    warning: Color(0xFFFF9800),
  );

  static final monochromeTheme = _createTheme(
    name: 'Monochrome',
    brightness: Brightness.light,
    primary: Colors.black,
    secondary: Colors.grey[800]!,
    background: Colors.white,
    surface: Colors.grey[100]!,
    onSurface: Colors.black87,
    error: Colors.grey[700]!,
    success: Colors.grey[500]!,
    text: Colors.black87,
    disabled: Colors.grey[400]!,
    hint: Colors.grey[600]!,
    warning: Color(0xFFFF9800),
  );

  static final amoledTheme = _createTheme(
    name: 'Amoled',
    brightness: Brightness.dark,
    primary: Colors.white,
    secondary: Colors.grey[300]!,
    background: Colors.black,
    surface: Color(0xFF121212),
    onSurface: Colors.white,
    error: Colors.red[300]!,
    success: Colors.green[300]!,
    text: Colors.white,
    disabled: Colors.grey[600]!,
    hint: Colors.grey[400]!,
    warning: Color(0xFFFF9800),
  );

  static ThemeData _createTheme({
    required String name,
    required Brightness brightness,
    required Color primary,
    required Color secondary,
    required Color background,
    required Color surface,
    required Color onSurface,
    required Color error,
    required Color success,
    required Color text,
    required Color disabled,
    required Color hint,
    required Color warning,
  }) {
    return ThemeData(
      brightness: brightness,
      primaryColor: primary,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: primary,
        secondary: secondary,
        surface: surface,
        onSurface: onSurface,
        error: error,
        onPrimary: brightness == Brightness.dark ? Colors.black : Colors.white,
        onSecondary:
            brightness == Brightness.dark ? Colors.black : Colors.white,
        onError: brightness == Brightness.dark ? Colors.black : Colors.white,
      ),
      scaffoldBackgroundColor: background,
      cardColor: surface,
      dividerColor: disabled,
      textTheme: TextTheme(
        bodyMedium: TextStyle(color: text),
        bodySmall: TextStyle(color: hint),
        titleMedium: TextStyle(color: text),
        titleSmall: TextStyle(color: text),
        headlineMedium: TextStyle(color: text),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: primary,
        foregroundColor:
            brightness == Brightness.dark ? Colors.black : Colors.white,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: disabled,
      ),
      switchTheme: SwitchThemeData(
        thumbColor:
            WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
          if (states.contains(WidgetState.selected)) {
            return primary;
          }
          return disabled;
        }),
        trackColor:
            WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
          if (states.contains(WidgetState.selected)) {
            return primary.withOpacity(0.5);
          }
          return disabled.withOpacity(0.5);
        }),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor:
            WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
          if (states.contains(WidgetState.selected)) {
            return primary;
          }
          return disabled;
        }),
        checkColor: WidgetStateProperty.all(
            brightness == Brightness.dark ? Colors.black : Colors.white),
      ),
      radioTheme: RadioThemeData(
        fillColor:
            WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
          if (states.contains(WidgetState.selected)) {
            return primary;
          }
          return disabled;
        }),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor:
            brightness == Brightness.dark ? Colors.black : Colors.white,
      ),
    );
  }

  static final List<ThemeData> allThemes = [
    lightTheme,
    darkTheme,
    glassmorphismTheme,
    neumorphismTheme,
    materialTheme,
    gradientTheme,
    minimalTheme,
    pastelTheme,
    retroTheme,
    cyberpunkTheme,
    greeneryTheme,
    woodenTheme,
    natureTheme,
    spaceTheme,
    luxuryTheme,
    abstractTheme,
    futuristicTheme,
    vintageTheme,
    monochromeTheme,
    amoledTheme,
  ];

  static ThemeData getThemeFromIndex(int index) {
    if (index >= 0 && index < allThemes.length) {
      return allThemes[index];
    }
    return lightTheme; // Default to light theme if index is out of range
  }

  static String getThemeNameFromIndex(int index) {
    if (index >= 0 && index < allThemes.length) {
      return allThemes[index].brightness == Brightness.light
          ? '${_getThemeName(index)} (Light)'
          : '${_getThemeName(index)} (Dark)';
    }
    return 'Light'; // Default to "Light" if index is out of range
  }

  static String _getThemeName(int index) {
    switch (index) {
      case 0:
        return 'Light';
      case 1:
        return 'Dark';
      case 2:
        return 'Glassmorphism';
      case 3:
        return 'Neumorphism';
      case 4:
        return 'Material';
      case 5:
        return 'Gradient';
      case 6:
        return 'Minimal';
      case 7:
        return 'Pastel';
      case 8:
        return 'Retro';
      case 9:
        return 'Cyberpunk';
      case 10:
        return 'Greenery';
      case 11:
        return 'Wooden';
      case 12:
        return 'Nature';
      case 13:
        return 'Space';
      case 14:
        return 'Luxury';
      case 15:
        return 'Abstract';
      case 16:
        return 'Futuristic';
      case 17:
        return 'Vintage';
      case 18:
        return 'Monochrome';
      case 19:
        return 'Amoled';
      default:
        return 'Custom';
    }
  }

  // Helper method to get color properties from a theme
  static Map<String, Color> getThemeColors(ThemeData theme) {
    return {
      'primary': theme.colorScheme.primary,
      'secondary': theme.colorScheme.secondary,
      'background': theme.colorScheme.surface,
      'surface': theme.colorScheme.surface,
      'onSurface': theme.colorScheme.onSurface,
      'error': theme.colorScheme.error,
      'text': theme.textTheme.bodyMedium?.color ?? Colors.black,
      'disabled': theme.disabledColor,
      'hint': theme.hintColor,
    };
  }

  // Helper method to apply a gradient overlay to a theme
  static ThemeData applyGradientOverlay(
      ThemeData baseTheme, List<Color> gradientColors) {
    // This method would be implemented to apply a gradient overlay to various theme elements
    // For simplicity, we'll just return the base theme here
    return baseTheme;
  }

  // Helper method to create a custom theme
  static ThemeData createCustomTheme(
      {required String name,
      required Brightness brightness,
      required Color primary,
      required Color secondary,
      required Color background,
      required Color surface,
      required Color onSurface,
      required Color error,
      required Color success,
      required Color text,
      required Color disabled,
      required Color hint,
      required Color warning}) {
    return _createTheme(
        name: name,
        brightness: brightness,
        primary: primary,
        secondary: secondary,
        background: background,
        surface: surface,
        onSurface: onSurface,
        error: error,
        success: success,
        text: text,
        disabled: disabled,
        hint: hint,
        warning: warning);
  }
}
