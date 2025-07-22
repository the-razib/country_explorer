# 🔧 Country Explorer App - Technical Specification

## 📋 API Integration Strategy

### REST Countries API Endpoints Usage

#### Primary Endpoints:
```dart
class ApiConstants {
  static const String baseUrl = 'https://restcountries.com/v3.1';
  
  // Core endpoints
  static const String allCountries = '$baseUrl/all';
  static const String countryByName = '$baseUrl/name';
  static const String countryByCode = '$baseUrl/alpha';
  static const String countryByRegion = '$baseUrl/region';
  static const String countryByCurrency = '$baseUrl/currency';
  static const String countryByLanguage = '$baseUrl/lang';
  
  // Field selections for optimization
  static const String basicFields = 'name,capital,population,region,flags';
  static const String detailFields = 'name,capital,population,region,subregion,area,borders,languages,currencies,timezones,flags,coatOfArms,car,continents,gini,fifa';
}
```

#### Data Models Structure:

```dart
// Country Model
class Country {
  final CountryName name;
  final List<String> capital;
  final int population;
  final String region;
  final String subregion;
  final double area;
  final List<String> borders;
  final Map<String, Language> languages;
  final Map<String, Currency> currencies;
  final List<String> timezones;
  final CountryFlags flags;
  final CountryCoatOfArms? coatOfArms;
  final List<double>? latlng;
  final bool independent;
  final bool unMember;
  final Map<String, String>? gini;
  final String? fifa;
  
  // Constructor and methods...
}

// Supporting Models
class CountryName {
  final String common;
  final String official;
  final Map<String, NativeName>? nativeName;
}

class Currency {
  final String name;
  final String symbol;
}

class Language {
  final String name;
}

class CountryFlags {
  final String png;
  final String svg;
  final String alt;
}
```

## 🏗️ Architecture Implementation

### 1. Service Layer

```dart
// API Service
class CountryApiService {
  final Dio _dio = Dio();
  final Logger _logger = Logger();
  
  /// Fetch all countries with basic information
  Future<List<Country>> getAllCountries() async {
    try {
      EasyLoading.show(status: 'Loading countries...');
      
      final response = await _dio.get(
        '${ApiConstants.allCountries}?fields=${ApiConstants.basicFields}',
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Country.fromJson(json)).toList();
      }
      
      throw Exception('Failed to load countries');
    } catch (error) {
      _logger.e('Error fetching countries: $error');
      throw Exception('Unable to load countries. Please try again.');
    } finally {
      EasyLoading.dismiss();
    }
  }
  
  /// Search countries by name
  Future<List<Country>> searchCountriesByName(String name) async {
    try {
      if (name.isEmpty) return [];
      
      final response = await _dio.get(
        '${ApiConstants.countryByName}/$name?fields=${ApiConstants.detailFields}',
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Country.fromJson(json)).toList();
      }
      
      return [];
    } catch (error) {
      _logger.e('Error searching countries: $error');
      return [];
    }
  }
  
  /// Filter countries by region
  Future<List<Country>> getCountriesByRegion(String region) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.countryByRegion}/$region?fields=${ApiConstants.detailFields}',
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Country.fromJson(json)).toList();
      }
      
      return [];
    } catch (error) {
      _logger.e('Error fetching countries by region: $error');
      return [];
    }
  }
}
```

### 2. Controller Layer

```dart
// Country Controller
class CountryController extends GetxController {
  final CountryApiService _apiService = CountryApiService();
  final LocalStorageService _storageService = Get.find<LocalStorageService>();
  
  // Observable variables
  final RxList<Country> countries = <Country>[].obs;
  final RxList<Country> filteredCountries = <Country>[].obs;
  final RxList<Country> favoriteCountries = <Country>[].obs;
  final RxBool isLoading = false.obs;
  final RxString selectedRegion = 'All'.obs;
  final RxString searchQuery = ''.obs;
  
  @override
  void onInit() {
    super.onInit();
    loadCountries();
    loadFavorites();
  }
  
  /// Load all countries from API
  Future<void> loadCountries() async {
    try {
      isLoading.value = true;
      
      // Try to load from cache first
      final cachedCountries = await _storageService.getCachedCountries();
      if (cachedCountries.isNotEmpty) {
        countries.value = cachedCountries;
        filteredCountries.value = cachedCountries;
      }
      
      // Fetch fresh data from API
      final freshCountries = await _apiService.getAllCountries();
      countries.value = freshCountries;
      filteredCountries.value = freshCountries;
      
      // Cache the data
      await _storageService.cacheCountries(freshCountries);
      
    } catch (error) {
      Get.snackbar(
        'Error',
        'Failed to load countries. Please check your internet connection.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  /// Search countries
  void searchCountries(String query) {
    searchQuery.value = query;
    
    if (query.isEmpty) {
      filteredCountries.value = countries;
      return;
    }
    
    filteredCountries.value = countries.where((country) {
      return country.name.common.toLowerCase().contains(query.toLowerCase()) ||
             country.capital.any((capital) => 
               capital.toLowerCase().contains(query.toLowerCase()));
    }).toList();
  }
  
  /// Filter by region
  void filterByRegion(String region) {
    selectedRegion.value = region;
    
    if (region == 'All') {
      filteredCountries.value = countries;
      return;
    }
    
    filteredCountries.value = countries.where((country) {
      return country.region == region;
    }).toList();
  }
  
  /// Toggle favorite status
  void toggleFavorite(Country country) {
    if (favoriteCountries.contains(country)) {
      favoriteCountries.remove(country);
    } else {
      favoriteCountries.add(country);
    }
    
    _storageService.saveFavorites(favoriteCountries);
  }
  
  /// Check if country is favorite
  bool isFavorite(Country country) {
    return favoriteCountries.contains(country);
  }
}
```

### 3. View Layer Implementation

```dart
// Countries List Screen
class CountriesListScreen extends StatelessWidget {
  const CountriesListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CountryController>(
      init: CountryController(),
      builder: (controller) => Scaffold(
        appBar: AppBar(
          title: const Text('Country Explorer'),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => Get.to(() => const SearchScreen()),
            ),
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: () => _showFilterBottomSheet(context),
            ),
          ],
        ),
        body: Obx(() {
          if (controller.isLoading.value && controller.countries.isEmpty) {
            return const LoadingWidget();
          }
          
          if (controller.filteredCountries.isEmpty) {
            return const EmptyStateWidget(
              message: 'No countries found',
            );
          }
          
          return RefreshIndicator(
            onRefresh: controller.loadCountries,
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.8,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: controller.filteredCountries.length,
              itemBuilder: (context, index) {
                final country = controller.filteredCountries[index];
                return CountryCardWidget(
                  country: country,
                  onTap: () => Get.to(
                    () => CountryDetailScreen(country: country),
                  ),
                );
              },
            ),
          );
        }),
      ),
    );
  }
  
  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => const FilterBottomSheetWidget(),
    );
  }
}
```

## 📱 UI Components

### Custom Widgets:

```dart
// Country Card Widget
class CountryCardWidget extends StatelessWidget {
  final Country country;
  final VoidCallback onTap;
  
  const CountryCardWidget({
    Key? key,
    required this.country,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Flag Image
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: CachedNetworkImageProvider(country.flags.png),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            
            // Country Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      country.name.common,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      country.capital.isNotEmpty ? country.capital.first : 'No capital',
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      NumberFormat.compact().format(country.population),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

## 🔧 Performance Optimizations

### 1. Image Caching Strategy:
```dart
// Global image cache configuration
void configureCaching() {
  CachedNetworkImage.logLevel = CacheManagerLogLevel.warning;
  
  // Pre-cache flag images for better performance
  DefaultCacheManager().emptyCache();
}
```

### 2. Debounced Search:
```dart
class SearchController extends GetxController {
  Timer? _debounceTimer;
  final Duration debounceDuration = const Duration(milliseconds: 500);
  
  void onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(debounceDuration, () {
      performSearch(query);
    });
  }
}
```

### 3. Lazy Loading:
```dart
// Implement pagination for large datasets
class PaginatedCountryList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LazyLoadScrollView(
      onEndOfPage: () => controller.loadMoreCountries(),
      child: ListView.builder(
        itemCount: controller.countries.length,
        itemBuilder: (context, index) {
          return CountryListTileWidget(
            country: controller.countries[index],
          );
        },
      ),
    );
  }
}
```

## 📊 Testing Strategy

### 1. Unit Tests:
```dart
// Test country model serialization
void main() {
  group('Country Model Tests', () {
    test('should create Country from JSON', () {
      final json = {
        'name': {'common': 'Canada', 'official': 'Canada'},
        'capital': ['Ottawa'],
        'population': 38005238,
        'region': 'Americas',
        'flags': {
          'png': 'https://flagcdn.com/w320/ca.png',
          'svg': 'https://flagcdn.com/ca.svg',
        },
      };
      
      final country = Country.fromJson(json);
      
      expect(country.name.common, 'Canada');
      expect(country.capital.first, 'Ottawa');
      expect(country.population, 38005238);
    });
  });
}
```

### 2. Widget Tests:
```dart
// Test country card widget
void main() {
  testWidgets('CountryCardWidget displays country information', (tester) async {
    final country = Country(
      name: CountryName(common: 'Test Country'),
      capital: ['Test Capital'],
      population: 1000000,
      region: 'Test Region',
    );
    
    await tester.pumpWidget(
      MaterialApp(
        home: CountryCardWidget(
          country: country,
          onTap: () {},
        ),
      ),
    );
    
    expect(find.text('Test Country'), findsOneWidget);
    expect(find.text('Test Capital'), findsOneWidget);
  });
}
```

## 🚀 Deployment Checklist

### Pre-deployment:
- [ ] API rate limiting handling
- [ ] Error handling for all network calls
- [ ] Offline functionality testing
- [ ] Performance optimization verification
- [ ] Security review (API keys, data handling)
- [ ] Accessibility testing
- [ ] Different screen sizes testing
- [ ] App store guidelines compliance

### Release Configuration:
- [ ] Release build optimization
- [ ] ProGuard configuration (Android)
- [ ] App signing setup
- [ ] Store listing preparation
- [ ] Privacy policy creation
- [ ] Terms of service

This technical specification provides a solid foundation for implementing the Country Explorer app with proper architecture, performance considerations, and testing strategies.
