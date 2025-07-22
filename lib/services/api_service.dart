import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../utils/api_constants.dart';
import '../Country/models/country_model.dart';

/// Service class for handling REST Countries API calls
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

  /// Setup dio interceptors for logging and error handling
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
  /// Returns list of countries with essential data
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

  /// Search countries by name with detailed information
  /// [name] - Country name to search for
  /// Returns list of matching countries
  Future<List<Country>> searchCountriesByName(String name) async {
    try {
      if (name.trim().isEmpty) return [];
      
      final response = await _dio.get(
        '/name/$name',
        queryParameters: {'fields': ApiConstants.detailFields},
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        final countries = data.map((json) => Country.fromJson(json)).toList();
        _logger.i('🔍 Found ${countries.length} countries for "$name"');
        return countries;
      }
      
      return [];
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        _logger.i('🔍 No countries found for "$name"');
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
  /// [region] - Region name to filter by
  /// Returns list of countries in the specified region
  Future<List<Country>> getCountriesByRegion(String region) async {
    try {
      final response = await _dio.get(
        '/region/$region',
        queryParameters: {'fields': ApiConstants.detailFields},
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        final countries = data.map((json) => Country.fromJson(json)).toList();
        _logger.i('🌍 Found ${countries.length} countries in $region');
        return countries;
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
  /// [code] - ISO country code (2 or 3 letter)
  /// Returns country details or null if not found
  Future<Country?> getCountryByCode(String code) async {
    try {
      final response = await _dio.get(
        '/alpha/$code',
        queryParameters: {'fields': ApiConstants.detailFields},
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is List && data.isNotEmpty) {
          final country = Country.fromJson(data[0]);
          _logger.i('🔍 Found country: ${country.name.common}');
          return country;
        }
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

  /// Filter countries by currency
  /// [currency] - Currency code to filter by
  /// Returns list of countries using the specified currency
  Future<List<Country>> getCountriesByCurrency(String currency) async {
    try {
      final response = await _dio.get(
        '/currency/$currency',
        queryParameters: {'fields': ApiConstants.detailFields},
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        final countries = data.map((json) => Country.fromJson(json)).toList();
        _logger.i('💰 Found ${countries.length} countries using $currency');
        return countries;
      }
      
      return [];
    } on DioException catch (e) {
      _logger.e('💰 Currency filter error: ${e.message}');
      return [];
    } catch (error) {
      _logger.e('💰 Currency filter unexpected error: $error');
      return [];
    }
  }

  /// Filter countries by language
  /// [language] - Language code to filter by
  /// Returns list of countries using the specified language
  Future<List<Country>> getCountriesByLanguage(String language) async {
    try {
      final response = await _dio.get(
        '/lang/$language',
        queryParameters: {'fields': ApiConstants.detailFields},
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        final countries = data.map((json) => Country.fromJson(json)).toList();
        _logger.i('🗣️ Found ${countries.length} countries speaking $language');
        return countries;
      }
      
      return [];
    } on DioException catch (e) {
      _logger.e('🗣️ Language filter error: ${e.message}');
      return [];
    } catch (error) {
      _logger.e('🗣️ Language filter unexpected error: $error');
      return [];
    }
  }

  /// Handle Dio errors and convert them to user-friendly messages
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
        if (statusCode == 404) {
          return Exception('No data found.');
        }
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
