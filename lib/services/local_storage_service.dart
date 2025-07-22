import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';
import '../Country/models/country_model.dart';

/// Service class for handling local storage operations
class LocalStorageService {
  final Logger _logger = Logger();
  
  // Box names for different data types
  static const String _countriesBoxName = 'countries_cache';
  static const String _favoritesBoxName = 'favorites';
  static const String _settingsBoxName = 'settings';
  
  late Box<Country> _countriesBox;
  late Box<Country> _favoritesBox;
  late Box<dynamic> _settingsBox;

  /// Initialize Hive and open boxes
  /// Must be called before using any other methods
  Future<LocalStorageService> init() async {
    try {
      await Hive.initFlutter();
      
      // Register adapters
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(CountryAdapter());
      }
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(CountryNameAdapter());
      }
      if (!Hive.isAdapterRegistered(2)) {
        Hive.registerAdapter(CurrencyAdapter());
      }
      if (!Hive.isAdapterRegistered(3)) {
        Hive.registerAdapter(CountryFlagsAdapter());
      }
      
      // Open boxes
      _countriesBox = await Hive.openBox<Country>(_countriesBoxName);
      _favoritesBox = await Hive.openBox<Country>(_favoritesBoxName);
      _settingsBox = await Hive.openBox<dynamic>(_settingsBoxName);
      
      _logger.i('📦 Local storage initialized successfully');
      return this;
    } catch (error) {
      _logger.e('💥 Failed to initialize local storage: $error');
      rethrow;
    }
  }

  // Countries Cache Operations

  /// Cache countries list for offline access
  /// [countries] - List of countries to cache
  Future<void> cacheCountries(List<Country> countries) async {
    try {
      await _countriesBox.clear();
      
      for (int i = 0; i < countries.length; i++) {
        await _countriesBox.put(i, countries[i]);
      }
      
      // Store cache timestamp
      await _settingsBox.put('countries_cache_timestamp', DateTime.now().millisecondsSinceEpoch);
      
      _logger.i('💾 Cached ${countries.length} countries');
    } catch (error) {
      _logger.e('💥 Failed to cache countries: $error');
    }
  }

  /// Get cached countries
  /// Returns empty list if no cache exists or cache is expired
  Future<List<Country>> getCachedCountries() async {
    try {
      final timestamp = _settingsBox.get('countries_cache_timestamp', defaultValue: 0);
      final cacheAge = DateTime.now().millisecondsSinceEpoch - timestamp;
      
      // Cache expires after 24 hours
      if (cacheAge > 24 * 60 * 60 * 1000) {
        _logger.i('📦 Cache expired, clearing...');
        await clearCountriesCache();
        return [];
      }
      
      final countries = _countriesBox.values.toList();
      _logger.i('📦 Retrieved ${countries.length} cached countries');
      return countries;
    } catch (error) {
      _logger.e('💥 Failed to get cached countries: $error');
      return [];
    }
  }

  /// Clear countries cache
  Future<void> clearCountriesCache() async {
    try {
      await _countriesBox.clear();
      await _settingsBox.delete('countries_cache_timestamp');
      _logger.i('🗑️ Countries cache cleared');
    } catch (error) {
      _logger.e('💥 Failed to clear countries cache: $error');
    }
  }

  /// Check if countries cache exists and is valid
  bool get hasCachedCountries {
    try {
      final timestamp = _settingsBox.get('countries_cache_timestamp', defaultValue: 0);
      final cacheAge = DateTime.now().millisecondsSinceEpoch - timestamp;
      return _countriesBox.isNotEmpty && cacheAge <= 24 * 60 * 60 * 1000;
    } catch (error) {
      return false;
    }
  }

  // Favorites Operations

  /// Add country to favorites
  /// [country] - Country to add to favorites
  Future<void> addToFavorites(Country country) async {
    try {
      final key = country.name.common;
      await _favoritesBox.put(key, country);
      _logger.i('⭐ Added ${country.name.common} to favorites');
    } catch (error) {
      _logger.e('💥 Failed to add to favorites: $error');
    }
  }

  /// Remove country from favorites
  /// [country] - Country to remove from favorites
  Future<void> removeFromFavorites(Country country) async {
    try {
      final key = country.name.common;
      await _favoritesBox.delete(key);
      _logger.i('⭐ Removed ${country.name.common} from favorites');
    } catch (error) {
      _logger.e('💥 Failed to remove from favorites: $error');
    }
  }

  /// Get all favorite countries
  /// Returns list of favorite countries
  List<Country> getFavoriteCountries() {
    try {
      final favorites = _favoritesBox.values.toList();
      _logger.i('⭐ Retrieved ${favorites.length} favorite countries');
      return favorites;
    } catch (error) {
      _logger.e('💥 Failed to get favorite countries: $error');
      return [];
    }
  }

  /// Check if country is in favorites
  /// [country] - Country to check
  /// Returns true if country is favorited
  bool isFavorite(Country country) {
    try {
      return _favoritesBox.containsKey(country.name.common);
    } catch (error) {
      _logger.e('💥 Failed to check favorite status: $error');
      return false;
    }
  }

  /// Save favorites list (batch operation)
  /// [favorites] - List of favorite countries
  Future<void> saveFavorites(List<Country> favorites) async {
    try {
      await _favoritesBox.clear();
      
      for (final country in favorites) {
        await _favoritesBox.put(country.name.common, country);
      }
      
      _logger.i('⭐ Saved ${favorites.length} favorites');
    } catch (error) {
      _logger.e('💥 Failed to save favorites: $error');
    }
  }

  /// Clear all favorites
  Future<void> clearFavorites() async {
    try {
      await _favoritesBox.clear();
      _logger.i('🗑️ Favorites cleared');
    } catch (error) {
      _logger.e('💥 Failed to clear favorites: $error');
    }
  }

  // Settings Operations

  /// Save app theme preference
  /// [isDarkMode] - True for dark mode, false for light mode
  Future<void> saveThemePreference(bool isDarkMode) async {
    try {
      await _settingsBox.put('dark_mode', isDarkMode);
      _logger.i('🎨 Theme preference saved: ${isDarkMode ? 'Dark' : 'Light'}');
    } catch (error) {
      _logger.e('💥 Failed to save theme preference: $error');
    }
  }

  /// Get app theme preference
  /// Returns true for dark mode, false for light mode
  bool getThemePreference() {
    try {
      return _settingsBox.get('dark_mode', defaultValue: false);
    } catch (error) {
      _logger.e('💥 Failed to get theme preference: $error');
      return false;
    }
  }

  /// Save search history
  /// [searchQuery] - Search query to save
  Future<void> saveSearchHistory(String searchQuery) async {
    try {
      if (searchQuery.trim().isEmpty) return;
      
      List<String> history = getSearchHistory();
      
      // Remove if already exists
      history.remove(searchQuery);
      
      // Add to beginning
      history.insert(0, searchQuery);
      
      // Keep only last 10 searches
      if (history.length > 10) {
        history = history.sublist(0, 10);
      }
      
      await _settingsBox.put('search_history', history);
      _logger.i('🔍 Search history updated');
    } catch (error) {
      _logger.e('💥 Failed to save search history: $error');
    }
  }

  /// Get search history
  /// Returns list of recent search queries
  List<String> getSearchHistory() {
    try {
      final history = _settingsBox.get('search_history', defaultValue: <String>[]);
      return List<String>.from(history);
    } catch (error) {
      _logger.e('💥 Failed to get search history: $error');
      return [];
    }
  }

  /// Clear search history
  Future<void> clearSearchHistory() async {
    try {
      await _settingsBox.delete('search_history');
      _logger.i('🗑️ Search history cleared');
    } catch (error) {
      _logger.e('💥 Failed to clear search history: $error');
    }
  }

  /// Clear all data
  Future<void> clearAllData() async {
    try {
      await _countriesBox.clear();
      await _favoritesBox.clear();
      await _settingsBox.clear();
      _logger.i('🗑️ All data cleared');
    } catch (error) {
      _logger.e('💥 Failed to clear all data: $error');
    }
  }

  /// Close all boxes (call when app is closing)
  Future<void> close() async {
    try {
      await _countriesBox.close();
      await _favoritesBox.close();
      await _settingsBox.close();
      _logger.i('📦 Local storage closed');
    } catch (error) {
      _logger.e('💥 Failed to close local storage: $error');
    }
  }
}
