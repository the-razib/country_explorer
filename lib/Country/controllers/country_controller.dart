import 'package:get/get.dart';
import 'package:logger/logger.dart';
import '../models/country_model.dart';
import '../../services/api_service.dart';
import '../../services/local_storage_service.dart';
import '../../utils/api_constants.dart';

/// Controller for managing country data and operations
class CountryController extends GetxController {
  final CountryApiService _apiService = CountryApiService();
  final LocalStorageService _storageService = Get.find<LocalStorageService>();
  final Logger _logger = Logger();
  
  // Observable variables
  final RxList<Country> countries = <Country>[].obs;
  final RxList<Country> filteredCountries = <Country>[].obs;
  final RxList<Country> favoriteCountries = <Country>[].obs;
  final RxBool isLoading = false.obs;
  final RxString selectedRegion = 'All'.obs;
  final RxString searchQuery = ''.obs;
  final RxString sortOption = 'Name A-Z'.obs;
  final RxBool isGridView = true.obs;

  // Available options for filtering and sorting
  List<String> get availableRegions => ApiConstants.regions;
  List<String> get sortOptions => ApiConstants.sortOptions;

  @override
  void onInit() {
    super.onInit();
    loadCountries();
    loadFavorites();
  }

  /// Load all countries from API with caching support
  Future<void> loadCountries() async {
    try {
      isLoading.value = true;
      _logger.i('🔄 Loading countries...');
      
      // Try to load from cache first
      final cachedCountries = await _storageService.getCachedCountries();
      if (cachedCountries.isNotEmpty) {
        countries.value = cachedCountries;
        filteredCountries.value = cachedCountries;
        _logger.i('📦 Loaded ${cachedCountries.length} countries from cache');
      }
      
      // Fetch fresh data from API
      final freshCountries = await _apiService.getAllCountries();
      countries.value = freshCountries;
      filteredCountries.value = freshCountries;
      
      // Cache the data
      await _storageService.cacheCountries(freshCountries);
      
      // Apply current filters and sorting
      _applyFiltersAndSort();
      
      _logger.i('✅ Successfully loaded ${freshCountries.length} countries');
      
    } catch (error) {
      _logger.e('❌ Failed to load countries: $error');
      
      // Show error message
      Get.snackbar(
        'Error',
        'Failed to load countries. Please check your internet connection.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
      
      // If we have cached data, use it
      if (countries.isEmpty) {
        final cachedCountries = await _storageService.getCachedCountries();
        if (cachedCountries.isNotEmpty) {
          countries.value = cachedCountries;
          filteredCountries.value = cachedCountries;
          _applyFiltersAndSort();
          
          Get.snackbar(
            'Offline Mode',
            'Showing cached data from last update.',
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 2),
          );
        }
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Search countries by name or capital
  void searchCountries(String query) {
    searchQuery.value = query;
    _logger.i('🔍 Searching for: "$query"');
    
    // Save search to history
    if (query.trim().isNotEmpty) {
      _storageService.saveSearchHistory(query.trim());
    }
    
    _applyFiltersAndSort();
  }

  /// Filter countries by region
  void filterByRegion(String region) {
    selectedRegion.value = region;
    _logger.i('🌍 Filtering by region: $region');
    _applyFiltersAndSort();
  }

  /// Sort countries by selected option
  void sortCountries(String option) {
    sortOption.value = option;
    _logger.i('📊 Sorting by: $option');
    _applyFiltersAndSort();
  }

  /// Apply current filters and sorting to countries list
  void _applyFiltersAndSort() {
    List<Country> result = List.from(countries);
    
    // Apply search filter
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      result = result.where((country) {
        return country.name.common.toLowerCase().contains(query) ||
               country.name.official.toLowerCase().contains(query) ||
               country.capital.any((capital) => 
                 capital.toLowerCase().contains(query)) ||
               country.region.toLowerCase().contains(query) ||
               country.subregion.toLowerCase().contains(query);
      }).toList();
    }
    
    // Apply region filter
    if (selectedRegion.value != 'All') {
      result = result.where((country) {
        return country.region == selectedRegion.value;
      }).toList();
    }
    
    // Apply sorting
    switch (sortOption.value) {
      case 'Name A-Z':
        result.sort((a, b) => a.name.common.compareTo(b.name.common));
        break;
      case 'Name Z-A':
        result.sort((a, b) => b.name.common.compareTo(a.name.common));
        break;
      case 'Population High-Low':
        result.sort((a, b) => b.population.compareTo(a.population));
        break;
      case 'Population Low-High':
        result.sort((a, b) => a.population.compareTo(b.population));
        break;
      case 'Area Large-Small':
        result.sort((a, b) {
          final aArea = a.area ?? 0;
          final bArea = b.area ?? 0;
          return bArea.compareTo(aArea);
        });
        break;
      case 'Area Small-Large':
        result.sort((a, b) {
          final aArea = a.area ?? 0;
          final bArea = b.area ?? 0;
          return aArea.compareTo(bArea);
        });
        break;
    }
    
    filteredCountries.value = result;
    _logger.i('📋 Filtered to ${result.length} countries');
  }

  /// Toggle favorite status for a country
  void toggleFavorite(Country country) {
    if (favoriteCountries.contains(country)) {
      favoriteCountries.remove(country);
      _storageService.removeFromFavorites(country);
      _logger.i('⭐ Removed ${country.name.common} from favorites');
      
      Get.snackbar(
        'Removed from Favorites',
        '${country.name.common} was removed from your favorites.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } else {
      favoriteCountries.add(country);
      _storageService.addToFavorites(country);
      _logger.i('⭐ Added ${country.name.common} to favorites');
      
      Get.snackbar(
        'Added to Favorites',
        '${country.name.common} was added to your favorites.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    }
  }

  /// Check if country is in favorites
  bool isFavorite(Country country) {
    return favoriteCountries.any((fav) => 
      fav.name.common == country.name.common);
  }

  /// Load favorite countries from storage
  void loadFavorites() {
    try {
      final favorites = _storageService.getFavoriteCountries();
      favoriteCountries.value = favorites;
      _logger.i('⭐ Loaded ${favorites.length} favorite countries');
    } catch (error) {
      _logger.e('❌ Failed to load favorites: $error');
    }
  }

  /// Get countries by region (for detailed view)
  Future<List<Country>> getCountriesByRegion(String region) async {
    try {
      if (region == 'All') return countries;
      
      return await _apiService.getCountriesByRegion(region);
    } catch (error) {
      _logger.e('❌ Failed to get countries by region: $error');
      return countries.where((c) => c.region == region).toList();
    }
  }

  /// Search countries with API call for more detailed results
  Future<List<Country>> searchCountriesDetailed(String query) async {
    try {
      if (query.trim().isEmpty) return [];
      
      return await _apiService.searchCountriesByName(query);
    } catch (error) {
      _logger.e('❌ Failed to search countries: $error');
      return [];
    }
  }

  /// Get country by code for detailed view
  Future<Country?> getCountryByCode(String code) async {
    try {
      return await _apiService.getCountryByCode(code);
    } catch (error) {
      _logger.e('❌ Failed to get country by code: $error');
      return null;
    }
  }

  /// Clear all filters and search
  void clearFilters() {
    searchQuery.value = '';
    selectedRegion.value = 'All';
    sortOption.value = 'Name A-Z';
    _applyFiltersAndSort();
    _logger.i('🧹 Cleared all filters');
  }

  /// Clear search query
  void clearSearch() {
    searchQuery.value = '';
    _applyFiltersAndSort();
    _logger.i('🧹 Cleared search');
  }

  /// Toggle between grid and list view
  void toggleViewMode() {
    isGridView.value = !isGridView.value;
    _logger.i('👁️ Switched to ${isGridView.value ? 'Grid' : 'List'} view');
  }

  /// Refresh data (pull to refresh)
  Future<void> refreshCountries() async {
    await loadCountries();
  }

  /// Get search suggestions based on current query
  List<String> getSearchSuggestions(String query) {
    if (query.length < 2) return [];
    
    final suggestions = <String>[];
    final lowerQuery = query.toLowerCase();
    
    // Add country names
    for (final country in countries) {
      if (country.name.common.toLowerCase().startsWith(lowerQuery)) {
        suggestions.add(country.name.common);
      }
    }
    
    // Add capitals
    for (final country in countries) {
      for (final capital in country.capital) {
        if (capital.toLowerCase().startsWith(lowerQuery)) {
          suggestions.add(capital);
        }
      }
    }
    
    // Add regions
    for (final region in ApiConstants.regions) {
      if (region.toLowerCase().startsWith(lowerQuery)) {
        suggestions.add(region);
      }
    }
    
    return suggestions.take(10).toList();
  }

  /// Get countries count by region for statistics
  Map<String, int> getCountriesByRegionCount() {
    final Map<String, int> regionCounts = {};
    
    for (final country in countries) {
      regionCounts[country.region] = (regionCounts[country.region] ?? 0) + 1;
    }
    
    return regionCounts;
  }

  /// Clear all favorite countries
  void clearAllFavorites() {
    favoriteCountries.clear();
    _storageService.clearFavorites();
    _logger.i('🧹 Cleared all favorite countries');
    
    Get.snackbar(
      'Favorites Cleared',
      'All favorite countries have been removed.',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void onClose() {
    _logger.i('🔄 Country controller closing...');
    super.onClose();
  }
}
