import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/local_storage_service.dart';

/// Theme controller for managing app themes and user preferences
class ThemeController extends GetxController {
  final LocalStorageService _storageService = Get.find();

  // Theme preferences
  final _isDarkMode = false.obs;
  final _selectedTheme = 'blue'.obs;
  final _fontSize = 1.0.obs;

  // Available themes
  final Map<String, ThemeData> _lightThemes = {
    'blue': _createLightTheme(Colors.blue),
    'green': _createLightTheme(Colors.green),
    'purple': _createLightTheme(Colors.purple),
    'orange': _createLightTheme(Colors.orange),
    'red': _createLightTheme(Colors.red),
    'teal': _createLightTheme(Colors.teal),
  };

  final Map<String, ThemeData> _darkThemes = {
    'blue': _createDarkTheme(Colors.blue),
    'green': _createDarkTheme(Colors.green),
    'purple': _createDarkTheme(Colors.purple),
    'orange': _createDarkTheme(Colors.orange),
    'red': _createDarkTheme(Colors.red),
    'teal': _createDarkTheme(Colors.teal),
  };

  // Getters
  bool get isDarkMode => _isDarkMode.value;
  String get selectedTheme => _selectedTheme.value;
  double get fontSize => _fontSize.value;

  List<String> get availableThemes => _lightThemes.keys.toList();

  ThemeData get currentTheme =>
      isDarkMode ? _darkThemes[selectedTheme]! : _lightThemes[selectedTheme]!;

  ThemeMode get themeMode => isDarkMode ? ThemeMode.dark : ThemeMode.light;

  @override
  void onInit() {
    super.onInit();
    _loadThemePreferences();
  }

  /// Load theme preferences from storage
  Future<void> _loadThemePreferences() async {
    try {
      _isDarkMode.value = _storageService.getThemePreference();

      // For now, use default values for theme color and font size
      // Can be extended later when storage service supports these
      _selectedTheme.value = 'blue';
      _fontSize.value = 1.0;

      // Apply theme
      Get.changeThemeMode(themeMode);
      Get.changeTheme(currentTheme);
    } catch (e) {
      // Use default values if loading fails
      _isDarkMode.value = false;
      _selectedTheme.value = 'blue';
      _fontSize.value = 1.0;
    }
  }

  /// Toggle between light and dark mode
  Future<void> toggleDarkMode() async {
    _isDarkMode.value = !_isDarkMode.value;

    // Apply new theme mode
    Get.changeThemeMode(themeMode);
    Get.changeTheme(currentTheme);

    // Save preference
    await _saveThemePreferences();
  }

  /// Change app theme color
  Future<void> changeTheme(String themeName) async {
    if (_lightThemes.containsKey(themeName)) {
      _selectedTheme.value = themeName;

      // Apply new theme
      Get.changeTheme(currentTheme);

      // Save preference
      await _saveThemePreferences();
    }
  }

  /// Change app font size
  Future<void> changeFontSize(double size) async {
    _fontSize.value = size.clamp(0.8, 1.4);

    // Apply new theme with updated font size
    Get.changeTheme(currentTheme);

    // Save preference
    await _saveThemePreferences();
  }

  /// Save theme preferences to storage
  Future<void> _saveThemePreferences() async {
    try {
      await _storageService.saveThemePreference(_isDarkMode.value);
      // For now, only save dark mode preference
      // Can be extended later for theme color and font size
    } catch (e) {
      // Handle save error silently
    }
  }

  /// Create light theme with custom primary color
  static ThemeData _createLightTheme(Color primaryColor) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: primaryColor,
        titleTextStyle: TextStyle(
          color: primaryColor,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: primaryColor),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: Colors.white,
        shadowColor: Colors.black.withOpacity(0.1),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 0,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  /// Create dark theme with custom primary color
  static ThemeData _createDarkTheme(Color primaryColor) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: primaryColor,
        titleTextStyle: TextStyle(
          color: primaryColor,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: primaryColor),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: Colors.grey[900],
        shadowColor: Colors.black.withOpacity(0.3),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey[800],
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 0,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  /// Get theme color for display
  Color getThemeColor(String themeName) {
    switch (themeName) {
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'purple':
        return Colors.purple;
      case 'orange':
        return Colors.orange;
      case 'red':
        return Colors.red;
      case 'teal':
        return Colors.teal;
      default:
        return Colors.blue;
    }
  }

  /// Get theme display name
  String getThemeDisplayName(String themeName) {
    switch (themeName) {
      case 'blue':
        return 'Ocean Blue';
      case 'green':
        return 'Nature Green';
      case 'purple':
        return 'Royal Purple';
      case 'orange':
        return 'Sunset Orange';
      case 'red':
        return 'Classic Red';
      case 'teal':
        return 'Modern Teal';
      default:
        return 'Ocean Blue';
    }
  }
}
