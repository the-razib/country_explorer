# 🚀 Country Explorer App - Quick Start Implementation Guide

## 📋 Prerequisites Checklist

Before starting development, ensure you have:
- ✅ Flutter SDK (latest stable version)
- ✅ Android Studio / VS Code with Flutter extensions
- ✅ Git for version control
- ✅ Device/Emulator for testing
- ✅ Internet connection for API testing

## 🛠️ Step 1: Project Dependencies Setup

Update your `pubspec.yaml` with the required dependencies:

```yaml
name: country_explorer_app
description: A comprehensive country information app using REST Countries API
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'
  flutter: ">=3.10.0"

dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  get: ^4.6.6
  
  # Networking
  dio: ^5.4.0
  connectivity_plus: ^5.0.2
  
  # Local Storage
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  
  # UI Components
  cached_network_image: ^3.3.1
  flutter_staggered_grid_view: ^0.7.0
  fl_chart: ^0.66.2
  shimmer: ^3.0.0
  lottie: ^2.7.0
  
  # Utilities
  logger: ^2.0.2+1
  flutter_easyloading: ^3.0.5
  intl: ^0.19.0
  url_launcher: ^6.2.4
  share_plus: ^7.2.2
  
  # Fonts & Icons
  google_fonts: ^6.1.0
  cupertino_icons: ^1.0.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  hive_generator: ^2.0.1
  build_runner: ^2.4.7

flutter:
  uses-material-design: true
  assets:
    - assets/images/
    - assets/animations/
```

## 🏗️ Step 2: Project Structure Creation

Create the following folder structure in your `lib` directory:

```bash
# Run these commands in your terminal
mkdir -p lib/Country/{controllers,models,views/{screens,widgets}}
mkdir -p lib/Favorites/{controllers,models,views/{screens,widgets}}
mkdir -p lib/Quiz/{controllers,models,views/{screens,widgets}}
mkdir -p lib/Compare/{controllers,models,views/{screens,widgets}}
mkdir -p lib/services
mkdir -p lib/utils
mkdir -p lib/shared/{widgets,themes}
mkdir -p assets/{images,animations}
```

## 🔧 Step 3: Core Implementation Files

### 1. API Constants (`lib/utils/api_constants.dart`)

```dart
class ApiConstants {
  // Base URL for REST Countries API
  static const String baseUrl = 'https://restcountries.com/v3.1';
  
  // Endpoints
  static const String allCountries = '$baseUrl/all';
  static const String countryByName = '$baseUrl/name';
  static const String countryByCode = '$baseUrl/alpha';
  static const String countryByRegion = '$baseUrl/region';
  static const String countryByCurrency = '$baseUrl/currency';
  static const String countryByLanguage = '$baseUrl/lang';
  
  // Field selections for API optimization
  static const String basicFields = 'name,capital,population,region,subregion,flags';
  static const String detailFields = 'name,capital,population,region,subregion,area,borders,languages,currencies,timezones,flags,coatOfArms,car,continents,gini,fifa,independent,unMember,latlng';
  
  // HTTP request timeouts
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 15);
}
```

### 2. Country Model (`lib/Country/models/country_model.dart`)

```dart
import 'package:hive/hive.dart';

part 'country_model.g.dart';

@HiveType(typeId: 0)
class Country extends HiveObject {
  @HiveField(0)
  final CountryName name;
  
  @HiveField(1)
  final List<String> capital;
  
  @HiveField(2)
  final int population;
  
  @HiveField(3)
  final String region;
  
  @HiveField(4)
  final String subregion;
  
  @HiveField(5)
  final double? area;
  
  @HiveField(6)
  final List<String> borders;
  
  @HiveField(7)
  final Map<String, String> languages;
  
  @HiveField(8)
  final Map<String, Currency> currencies;
  
  @HiveField(9)
  final List<String> timezones;
  
  @HiveField(10)
  final CountryFlags flags;
  
  @HiveField(11)
  final List<double>? latlng;
  
  @HiveField(12)
  final bool independent;
  
  @HiveField(13)
  final bool unMember;
  
  @HiveField(14)
  final String? fifa;

  Country({
    required this.name,
    required this.capital,
    required this.population,
    required this.region,
    required this.subregion,
    this.area,
    required this.borders,
    required this.languages,
    required this.currencies,
    required this.timezones,
    required this.flags,
    this.latlng,
    required this.independent,
    required this.unMember,
    this.fifa,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      name: CountryName.fromJson(json['name'] ?? {}),
      capital: List<String>.from(json['capital'] ?? []),
      population: json['population'] ?? 0,
      region: json['region'] ?? '',
      subregion: json['subregion'] ?? '',
      area: json['area']?.toDouble(),
      borders: List<String>.from(json['borders'] ?? []),
      languages: _parseLanguages(json['languages']),
      currencies: _parseCurrencies(json['currencies']),
      timezones: List<String>.from(json['timezones'] ?? []),
      flags: CountryFlags.fromJson(json['flags'] ?? {}),
      latlng: json['latlng'] != null ? List<double>.from(json['latlng']) : null,
      independent: json['independent'] ?? false,
      unMember: json['unMember'] ?? false,
      fifa: json['fifa'],
    );
  }

  static Map<String, String> _parseLanguages(dynamic languages) {
    if (languages == null) return {};
    return Map<String, String>.from(languages);
  }

  static Map<String, Currency> _parseCurrencies(dynamic currencies) {
    if (currencies == null) return {};
    Map<String, Currency> result = {};
    currencies.forEach((key, value) {
      result[key] = Currency.fromJson(value);
    });
    return result;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Country && 
           other.name.common == name.common &&
           other.name.official == name.official;
  }

  @override
  int get hashCode => name.common.hashCode ^ name.official.hashCode;
}

@HiveType(typeId: 1)
class CountryName extends HiveObject {
  @HiveField(0)
  final String common;
  
  @HiveField(1)
  final String official;

  CountryName({
    required this.common,
    required this.official,
  });

  factory CountryName.fromJson(Map<String, dynamic> json) {
    return CountryName(
      common: json['common'] ?? '',
      official: json['official'] ?? '',
    );
  }
}

@HiveType(typeId: 2)
class Currency extends HiveObject {
  @HiveField(0)
  final String name;
  
  @HiveField(1)
  final String symbol;

  Currency({
    required this.name,
    required this.symbol,
  });

  factory Currency.fromJson(Map<String, dynamic> json) {
    return Currency(
      name: json['name'] ?? '',
      symbol: json['symbol'] ?? '',
    );
  }
}

@HiveType(typeId: 3)
class CountryFlags extends HiveObject {
  @HiveField(0)
  final String png;
  
  @HiveField(1)
  final String svg;
  
  @HiveField(2)
  final String alt;

  CountryFlags({
    required this.png,
    required this.svg,
    required this.alt,
  });

  factory CountryFlags.fromJson(Map<String, dynamic> json) {
    return CountryFlags(
      png: json['png'] ?? '',
      svg: json['svg'] ?? '',
      alt: json['alt'] ?? '',
    );
  }
}
```

### 3. API Service (`lib/services/api_service.dart`)

```dart
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../utils/api_constants.dart';
import '../Country/models/country_model.dart';

class CountryApiService {
  late final Dio _dio;
  final Logger _logger = Logger();

  CountryApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: ApiConstants.connectTimeout,
      receiveTimeout: ApiConstants.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
    
    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          _logger.d('🌐 API Request: ${options.method} ${options.path}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          _logger.d('✅ API Response: ${response.statusCode} ${response.requestOptions.path}');
          handler.next(response);
        },
        onError: (error, handler) {
          _logger.e('❌ API Error: ${error.message}');
          handler.next(error);
        },
      ),
    );
  }

  /// Fetch all countries with basic information
  Future<List<Country>> getAllCountries() async {
    try {
      EasyLoading.show(status: 'Loading countries...');
      
      final response = await _dio.get(
        '/all',
        queryParameters: {'fields': ApiConstants.basicFields},
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        final countries = data.map((json) => Country.fromJson(json)).toList();
        
        _logger.i('📍 Loaded ${countries.length} countries successfully');
        return countries;
      }
      
      throw DioException(
        requestOptions: response.requestOptions,
        message: 'Failed to load countries',
      );
      
    } on DioException catch (e) {
      _logger.e('🚫 Network error: ${e.message}');
      throw _handleDioError(e);
    } catch (error) {
      _logger.e('💥 Unexpected error: $error');
      throw Exception('An unexpected error occurred. Please try again.');
    } finally {
      EasyLoading.dismiss();
    }
  }

  /// Search countries by name
  Future<List<Country>> searchCountriesByName(String name) async {
    try {
      if (name.trim().isEmpty) return [];
      
      final response = await _dio.get(
        '/name/$name',
        queryParameters: {'fields': ApiConstants.detailFields},
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Country.fromJson(json)).toList();
      }
      
      return [];
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return []; // No countries found
      }
      _logger.e('🔍 Search error: ${e.message}');
      return [];
    } catch (error) {
      _logger.e('🔍 Search unexpected error: $error');
      return [];
    }
  }

  /// Filter countries by region
  Future<List<Country>> getCountriesByRegion(String region) async {
    try {
      final response = await _dio.get(
        '/region/$region',
        queryParameters: {'fields': ApiConstants.detailFields},
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Country.fromJson(json)).toList();
      }
      
      return [];
    } on DioException catch (e) {
      _logger.e('🌍 Region filter error: ${e.message}');
      return [];
    } catch (error) {
      _logger.e('🌍 Region filter unexpected error: $error');
      return [];
    }
  }

  /// Get detailed country information by country code
  Future<Country?> getCountryByCode(String code) async {
    try {
      final response = await _dio.get(
        '/alpha/$code',
        queryParameters: {'fields': ApiConstants.detailFields},
      );
      
      if (response.statusCode == 200) {
        return Country.fromJson(response.data[0]);
      }
      
      return null;
    } on DioException catch (e) {
      _logger.e('🔍 Country code search error: ${e.message}');
      return null;
    } catch (error) {
      _logger.e('🔍 Country code search unexpected error: $error');
      return null;
    }
  }

  Exception _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return Exception('Connection timeout. Please check your internet connection.');
      case DioExceptionType.sendTimeout:
        return Exception('Request timeout. Please try again.');
      case DioExceptionType.receiveTimeout:
        return Exception('Response timeout. Please try again.');
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        return Exception('Server error ($statusCode). Please try again later.');
      case DioExceptionType.cancel:
        return Exception('Request was cancelled.');
      case DioExceptionType.connectionError:
        return Exception('No internet connection. Please check your network.');
      default:
        return Exception('An unexpected error occurred. Please try again.');
    }
  }
}
```

## 📱 Step 4: Basic UI Setup

### Main App Configuration (`lib/main.dart`)

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_fonts/google_fonts.dart';

import 'Country/models/country_model.dart';
import 'Country/views/screens/countries_list_screen.dart';
import 'services/local_storage_service.dart';
import 'shared/themes/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Register Hive adapters
  Hive.registerAdapter(CountryAdapter());
  Hive.registerAdapter(CountryNameAdapter());
  Hive.registerAdapter(CurrencyAdapter());
  Hive.registerAdapter(CountryFlagsAdapter());
  
  // Initialize services
  await Get.putAsync(() => LocalStorageService().init());
  
  runApp(const CountryExplorerApp());
  
  // Configure EasyLoading
  _configureEasyLoading();
}

void _configureEasyLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.fadingCircle
    ..loadingStyle = EasyLoadingStyle.dark
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..maskType = EasyLoadingMaskType.black
    ..userInteractions = false
    ..dismissOnTap = false;
}

class CountryExplorerApp extends StatelessWidget {
  const CountryExplorerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Country Explorer',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const CountriesListScreen(),
      builder: EasyLoading.init(),
      defaultTransition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}
```

## ⚡ Step 5: Quick Development Commands

Run these commands in sequence to get started:

```bash
# 1. Install dependencies
flutter pub get

# 2. Generate Hive adapters
flutter packages pub run build_runner build

# 3. Create necessary directories (if not done manually)
mkdir -p lib/Country/{controllers,models,views/{screens,widgets}}
mkdir -p lib/services
mkdir -p lib/utils
mkdir -p lib/shared/{widgets,themes}

# 4. Run the app
flutter run
```

## 🎯 Next Steps Checklist

After setting up the basic structure:

1. **✅ Implement Local Storage Service** (`lib/services/local_storage_service.dart`)
2. **✅ Create App Theme** (`lib/shared/themes/app_theme.dart`)
3. **✅ Build Country Controller** (`lib/Country/controllers/country_controller.dart`)
4. **✅ Create Countries List Screen** (`lib/Country/views/screens/countries_list_screen.dart`)
5. **✅ Design Country Card Widget** (`lib/Country/views/widgets/country_card_widget.dart`)

## 🔧 Development Tips

### Hot Tips for Faster Development:
1. **Use Hot Reload**: Press `r` in terminal for quick UI updates
2. **Test on Real Device**: Better performance testing
3. **Use Flutter Inspector**: Debug widget tree easily
4. **Enable Dart DevTools**: Better debugging experience
5. **Use Logger**: Replace print statements with proper logging

### Common Issues & Solutions:
- **Hive Error**: Run `flutter packages pub run build_runner build --delete-conflicting-outputs`
- **API Timeout**: Check internet connection and API endpoints
- **Build Error**: Run `flutter clean && flutter pub get`
- **Hot Reload Issues**: Restart the app completely

## 📱 Testing Your Setup

Create a simple test to verify everything works:

```dart
// test/api_test.dart
import 'package:flutter_test/flutter_test.dart';
import '../lib/services/api_service.dart';

void main() {
  group('API Service Tests', () {
    late CountryApiService apiService;
    
    setUp(() {
      apiService = CountryApiService();
    });
    
    test('should fetch countries from API', () async {
      final countries = await apiService.getAllCountries();
      
      expect(countries, isNotEmpty);
      expect(countries.length, greaterThan(200));
      expect(countries.first.name.common, isNotEmpty);
    });
  });
}
```

Run the test:
```bash
flutter test test/api_test.dart
```

## 🚀 Ready to Start!

You now have a solid foundation to start building your Country Explorer app. The next steps would be:

1. Implement the remaining service classes
2. Create the UI components following the MVC pattern
3. Add features incrementally based on the feature breakdown
4. Test thoroughly on different devices

Start with the basic country listing functionality and gradually add more features. Remember to follow the coding guidelines in your `.github/copilot-instructions.md` file!

Happy coding! 🎉
