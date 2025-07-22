import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

// Core imports
import 'Country/models/country_model.dart';
import 'Country/views/screens/countries_list_screen.dart';
import 'Country/controllers/theme_controller.dart';
import 'Country/controllers/achievement_controller.dart';
import 'services/local_storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register Hive Adapters
  Hive.registerAdapter(CountryAdapter());
  Hive.registerAdapter(CountryNameAdapter());
  Hive.registerAdapter(CurrencyAdapter());
  Hive.registerAdapter(CountryFlagsAdapter());

  // Initialize Local Storage Service
  await Get.putAsync(() => LocalStorageService().init());

  // Initialize Controllers
  Get.put(ThemeController());
  Get.put(AchievementController());

  runApp(const CountryExplorerApp());
}

/// Main application widget
class CountryExplorerApp extends StatelessWidget {
  const CountryExplorerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return Obx(
      () => GetMaterialApp(
        title: 'Country Explorer',
        debugShowCheckedModeBanner: false,
        theme: themeController.currentTheme,
        themeMode: themeController.themeMode,
        home: const CountriesListScreen(),
        builder: EasyLoading.init(),
        // Configure EasyLoading
        onInit: () => _configureEasyLoading(),
      ),
    );
  }

  /// Configure EasyLoading settings
  void _configureEasyLoading() {
    EasyLoading.instance
      ..displayDuration = const Duration(milliseconds: 2000)
      ..indicatorType = EasyLoadingIndicatorType.wanderingCubes
      ..loadingStyle = EasyLoadingStyle.custom
      ..indicatorSize = 45.0
      ..radius = 10.0
      ..progressColor = Colors.white
      ..backgroundColor = Colors.blue.shade600
      ..indicatorColor = Colors.white
      ..textColor = Colors.white
      ..maskColor = Colors.black.withOpacity(0.5)
      ..userInteractions = false
      ..dismissOnTap = false;
  }
}
