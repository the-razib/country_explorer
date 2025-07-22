import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/country_controller.dart';
import '../../models/country_model.dart';
import '../widgets/country_card_widget.dart';
import 'country_detail_screen.dart';

/// Advanced search screen with multiple filter options
class AdvancedSearchScreen extends StatefulWidget {
  const AdvancedSearchScreen({Key? key}) : super(key: key);

  @override
  State<AdvancedSearchScreen> createState() => _AdvancedSearchScreenState();
}

class _AdvancedSearchScreenState extends State<AdvancedSearchScreen> {
  final controller = Get.find<CountryController>();
  final searchController = TextEditingController();
  
  // Search filters
  String selectedRegion = 'All';
  String selectedSubregion = 'All';
  bool? isIndependent;
  bool? isUnMember;
  String populationRange = 'All';
  String areaRange = 'All';
  
  // Search results
  List<Country> searchResults = [];
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    searchResults = controller.countries;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Advanced Search'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search filters
          _buildSearchFilters(),
          
          // Results count
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            width: double.infinity,
            color: Colors.grey[100],
            child: Text(
              '${searchResults.length} countries found',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          
          // Search results
          Expanded(
            child: isSearching
                ? const Center(child: CircularProgressIndicator())
                : searchResults.isEmpty
                    ? _buildEmptyState()
                    : _buildResultsList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _resetFilters,
        icon: const Icon(Icons.refresh),
        label: const Text('Reset'),
      ),
    );
  }

  /// Build search filters section
  Widget _buildSearchFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Text search
          TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'Search by name, capital, or code...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        searchController.clear();
                        _performSearch();
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (_) => _performSearch(),
          ),
          const SizedBox(height: 16),
          
          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('Region', selectedRegion, _showRegionDialog),
                const SizedBox(width: 8),
                _buildFilterChip('Population', populationRange, _showPopulationDialog),
                const SizedBox(width: 8),
                _buildFilterChip('Area', areaRange, _showAreaDialog),
                const SizedBox(width: 8),
                _buildBooleanFilterChip('Independent', isIndependent, (value) {
                  setState(() => isIndependent = value);
                  _performSearch();
                }),
                const SizedBox(width: 8),
                _buildBooleanFilterChip('UN Member', isUnMember, (value) {
                  setState(() => isUnMember = value);
                  _performSearch();
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build filter chip
  Widget _buildFilterChip(String label, String value, VoidCallback onTap) {
    final isActive = value != 'All';
    return FilterChip(
      label: Text('$label: $value'),
      selected: isActive,
      onSelected: (_) => onTap(),
      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
      checkmarkColor: Theme.of(context).primaryColor,
    );
  }

  /// Build boolean filter chip
  Widget _buildBooleanFilterChip(String label, bool? value, Function(bool?) onChanged) {
    String displayValue = value == null ? 'All' : (value ? 'Yes' : 'No');
    return FilterChip(
      label: Text('$label: $displayValue'),
      selected: value != null,
      onSelected: (_) => _showBooleanDialog(label, value, onChanged),
      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
      checkmarkColor: Theme.of(context).primaryColor,
    );
  }

  /// Build empty state
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No countries found',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search filters',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  /// Build results list
  Widget _buildResultsList() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        final country = searchResults[index];
        return CountryCardWidget(
          country: country,
          onTap: () => Get.to(() => CountryDetailScreen(country: country)),
        );
      },
    );
  }

  /// Perform search with all filters
  void _performSearch() {
    setState(() => isSearching = true);
    
    List<Country> results = List.from(controller.countries);
    
    // Text search
    final query = searchController.text.toLowerCase().trim();
    if (query.isNotEmpty) {
      results = results.where((country) {
        return country.name.common.toLowerCase().contains(query) ||
               country.name.official.toLowerCase().contains(query) ||
               country.capital.any((capital) => capital.toLowerCase().contains(query)) ||
               country.region.toLowerCase().contains(query) ||
               country.subregion.toLowerCase().contains(query);
      }).toList();
    }
    
    // Region filter
    if (selectedRegion != 'All') {
      results = results.where((country) => country.region == selectedRegion).toList();
    }
    
    // Population filter
    if (populationRange != 'All') {
      results = _filterByPopulation(results, populationRange);
    }
    
    // Area filter
    if (areaRange != 'All') {
      results = _filterByArea(results, areaRange);
    }
    
    // Independence filter
    if (isIndependent != null) {
      results = results.where((country) => country.independent == isIndependent).toList();
    }
    
    // UN membership filter
    if (isUnMember != null) {
      results = results.where((country) => country.unMember == isUnMember).toList();
    }
    
    setState(() {
      searchResults = results;
      isSearching = false;
    });
  }

  /// Filter by population range
  List<Country> _filterByPopulation(List<Country> countries, String range) {
    switch (range) {
      case 'Small (< 1M)':
        return countries.where((c) => c.population < 1000000).toList();
      case 'Medium (1M - 10M)':
        return countries.where((c) => c.population >= 1000000 && c.population < 10000000).toList();
      case 'Large (10M - 100M)':
        return countries.where((c) => c.population >= 10000000 && c.population < 100000000).toList();
      case 'Very Large (> 100M)':
        return countries.where((c) => c.population >= 100000000).toList();
      default:
        return countries;
    }
  }

  /// Filter by area range
  List<Country> _filterByArea(List<Country> countries, String range) {
    switch (range) {
      case 'Small (< 10K km²)':
        return countries.where((c) => c.area != null && c.area! < 10000).toList();
      case 'Medium (10K - 100K km²)':
        return countries.where((c) => c.area != null && c.area! >= 10000 && c.area! < 100000).toList();
      case 'Large (100K - 1M km²)':
        return countries.where((c) => c.area != null && c.area! >= 100000 && c.area! < 1000000).toList();
      case 'Very Large (> 1M km²)':
        return countries.where((c) => c.area != null && c.area! >= 1000000).toList();
      default:
        return countries;
    }
  }

  /// Show region selection dialog
  void _showRegionDialog() {
    final regions = ['All', ...controller.availableRegions.where((r) => r != 'All')];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Region'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: regions.length,
            itemBuilder: (context, index) {
              final region = regions[index];
              return RadioListTile<String>(
                title: Text(region),
                value: region,
                groupValue: selectedRegion,
                onChanged: (value) {
                  setState(() => selectedRegion = value!);
                  Navigator.pop(context);
                  _performSearch();
                },
              );
            },
          ),
        ),
      ),
    );
  }

  /// Show population range dialog
  void _showPopulationDialog() {
    final ranges = [
      'All',
      'Small (< 1M)',
      'Medium (1M - 10M)',
      'Large (10M - 100M)',
      'Very Large (> 100M)',
    ];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Population Range'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: ranges.length,
            itemBuilder: (context, index) {
              final range = ranges[index];
              return RadioListTile<String>(
                title: Text(range),
                value: range,
                groupValue: populationRange,
                onChanged: (value) {
                  setState(() => populationRange = value!);
                  Navigator.pop(context);
                  _performSearch();
                },
              );
            },
          ),
        ),
      ),
    );
  }

  /// Show area range dialog
  void _showAreaDialog() {
    final ranges = [
      'All',
      'Small (< 10K km²)',
      'Medium (10K - 100K km²)',
      'Large (100K - 1M km²)',
      'Very Large (> 1M km²)',
    ];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Area Range'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: ranges.length,
            itemBuilder: (context, index) {
              final range = ranges[index];
              return RadioListTile<String>(
                title: Text(range),
                value: range,
                groupValue: areaRange,
                onChanged: (value) {
                  setState(() => areaRange = value!);
                  Navigator.pop(context);
                  _performSearch();
                },
              );
            },
          ),
        ),
      ),
    );
  }

  /// Show boolean selection dialog
  void _showBooleanDialog(String title, bool? currentValue, Function(bool?) onChanged) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select $title'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<bool?>(
              title: const Text('All'),
              value: null,
              groupValue: currentValue,
              onChanged: (value) {
                onChanged(value);
                Navigator.pop(context);
              },
            ),
            RadioListTile<bool?>(
              title: const Text('Yes'),
              value: true,
              groupValue: currentValue,
              onChanged: (value) {
                onChanged(value);
                Navigator.pop(context);
              },
            ),
            RadioListTile<bool?>(
              title: const Text('No'),
              value: false,
              groupValue: currentValue,
              onChanged: (value) {
                onChanged(value);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Reset all filters
  void _resetFilters() {
    setState(() {
      searchController.clear();
      selectedRegion = 'All';
      selectedSubregion = 'All';
      isIndependent = null;
      isUnMember = null;
      populationRange = 'All';
      areaRange = 'All';
    });
    _performSearch();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
