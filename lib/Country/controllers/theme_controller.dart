import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Theme controller for managing app themes and appearance
class ThemeController extends GetxController {
  // Observable theme state
  final _isDarkMode = false.obs;
  final _selectedTheme = 'blue'.obs;
  final _currentTheme = Rx<ThemeData?>(null);

  // Available themes
  final List<String> availableThemes = [
    'blue',
    'purple',
    'green',
    'orange',
    'red',
    'teal',
  ];

  // Getters
  bool get isDarkMode => _isDarkMode.value;
  String get selectedTheme => _selectedTheme.value;
  ThemeData? get currentTheme => _currentTheme.value;
  ThemeMode get themeMode =>
      _isDarkMode.value ? ThemeMode.dark : ThemeMode.light;

  /// Toggle dark mode
  void toggleDarkMode() {
    _isDarkMode.value = !_isDarkMode.value;
    _updateTheme();
  }

  /// Change theme color
  void changeTheme(String themeName) {
    _selectedTheme.value = themeName;
    _updateTheme();
  }

  /// Get theme color by name
  Color getThemeColor(String themeName) {
    switch (themeName) {
      case 'blue':
        return const Color(0xFF667EEA);
      case 'purple':
        return const Color(0xFF764BA2);
      case 'green':
        return const Color(0xFF10B981);
      case 'orange':
        return const Color(0xFFF59E0B);
      case 'red':
        return const Color(0xFFEF4444);
      case 'teal':
        return const Color(0xFF14B8A6);
      default:
        return const Color(0xFF667EEA);
    }
  }

  /// Get theme display name
  String getThemeDisplayName(String themeName) {
    switch (themeName) {
      case 'blue':
        return 'Ocean Blue';
      case 'purple':
        return 'Royal Purple';
      case 'green':
        return 'Forest Green';
      case 'orange':
        return 'Sunset Orange';
      case 'red':
        return 'Cherry Red';
      case 'teal':
        return 'Tropical Teal';
      default:
        return 'Ocean Blue';
    }
  }

  /// Update app theme
  void _updateTheme() {
    final primaryColor = getThemeColor(_selectedTheme.value);

    final lightTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primarySwatch: _createMaterialColor(primaryColor),
      primaryColor: primaryColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
    );

    final darkTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primarySwatch: _createMaterialColor(primaryColor),
      primaryColor: primaryColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
    );

    _currentTheme.value = _isDarkMode.value ? darkTheme : lightTheme;
    Get.changeTheme(_currentTheme.value!);
  }

  /// Create MaterialColor from Color
  MaterialColor _createMaterialColor(Color color) {
    List strengths = <double>[.05];
    Map<int, Color> swatch = {};
    final int r = (color.r * 255.0).round() & 0xff;
    final int g = (color.g * 255.0).round() & 0xff;
    final int b = (color.b * 255.0).round() & 0xff;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(color.toARGB32(), swatch);
  }

  @override
  void onInit() {
    super.onInit();
    _updateTheme();
  }
}
