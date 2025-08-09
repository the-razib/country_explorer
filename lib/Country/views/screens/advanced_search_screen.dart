import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/country_controller.dart';
import '../../models/country_model.dart';
import 'country_detail_screen.dart';

/// Advanced search screen with multiple filter options
class AdvancedSearchScreen extends StatefulWidget {
  const AdvancedSearchScreen({super.key});

  @override
  State<AdvancedSearchScreen> createState() => _AdvancedSearchScreenState();
}

class _AdvancedSearchScreenState extends State<AdvancedSearchScreen>
    with TickerProviderStateMixin {
  final controller = Get.find<CountryController>();
  final searchController = TextEditingController();
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

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

    /// Initialize animation controllers for smooth transitions
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    /// Start animations when screen loads
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          /// Modern app bar with glass-morphism effect
          _buildModernAppBar(),

          /// Search filters section
          SliverToBoxAdapter(
            child: SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: _buildModernSearchFilters(),
              ),
            ),
          ),

          /// Results count with modern styling
          SliverToBoxAdapter(child: _buildModernResultsHeader()),

          /// Search results with staggered animation
          isSearching
              ? const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                )
              : searchResults.isEmpty
              ? SliverToBoxAdapter(child: _buildModernEmptyState())
              : _buildModernResultsList(),
        ],
      ),
      floatingActionButton: _buildModernFloatingActionButton(),
    );
  }

  /// Modern app bar with glass-morphism effect and gradient background
  Widget _buildModernAppBar() {
    return SliverAppBar(
      floating: true,
      pinned: true,
      snap: false,
      elevation: 0,
      backgroundColor: Colors.transparent,
      expandedHeight: 120,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
          ),
        ),
        child: FlexibleSpaceBar(
          title: const Text(
            'Advanced Search',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          ),
          centerTitle: true,
          background: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
              ),
            ),
            child: Stack(
              children: [
                /// Background pattern
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.1,
                    child: Container(
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(
                            'https://www.transparenttextures.com/patterns/cubes.png',
                          ),
                          repeat: ImageRepeat.repeat,
                        ),
                      ),
                    ),
                  ),
                ),

                /// Search icon decoration
                Positioned(
                  right: 20,
                  bottom: 20,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.search,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1),
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
    );
  }

  /// Modern search filters with enhanced styling
  Widget _buildModernSearchFilters() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Search title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.filter_list,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Search Filters',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          /// Text search field with modern styling
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
            ),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search by name, capital, or code...',
                hintStyle: TextStyle(color: Colors.grey[500], fontSize: 16),
                prefixIcon: Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.search,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                suffixIcon: searchController.text.isNotEmpty
                    ? Container(
                        margin: const EdgeInsets.all(8),
                        child: IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.clear,
                              color: Colors.grey,
                              size: 16,
                            ),
                          ),
                          onPressed: () {
                            searchController.clear();
                            _performSearch();
                          },
                        ),
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              onChanged: (_) => _performSearch(),
            ),
          ),
          const SizedBox(height: 20),

          /// Filter chips with enhanced design
          const Text(
            'Quick Filters',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildModernFilterChip(
                  'Region',
                  selectedRegion,
                  _showRegionDialog,
                ),
                const SizedBox(width: 12),
                _buildModernFilterChip(
                  'Population',
                  populationRange,
                  _showPopulationDialog,
                ),
                const SizedBox(width: 12),
                _buildModernFilterChip('Area', areaRange, _showAreaDialog),
                const SizedBox(width: 12),
                _buildModernBooleanFilterChip('Independent', isIndependent, (
                  value,
                ) {
                  setState(() => isIndependent = value);
                  _performSearch();
                }),
                const SizedBox(width: 12),
                _buildModernBooleanFilterChip('UN Member', isUnMember, (value) {
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

  /// Modern filter chip with enhanced styling
  Widget _buildModernFilterChip(
    String label,
    String value,
    VoidCallback onTap,
  ) {
    final isActive = value != 'All';
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: isActive
              ? const LinearGradient(
                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                )
              : null,
          color: isActive ? null : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isActive ? Colors.transparent : const Color(0xFFE2E8F0),
            width: 1,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: const Color(0xFF667EEA).withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isActive
                    ? Colors.white.withValues(alpha: 0.2)
                    : const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isActive ? Colors.white : const Color(0xFF64748B),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Modern boolean filter chip with enhanced design
  Widget _buildModernBooleanFilterChip(
    String label,
    bool? value,
    Function(bool?) onChanged,
  ) {
    String displayValue = value == null ? 'All' : (value ? 'Yes' : 'No');
    final isActive = value != null;

    return GestureDetector(
      onTap: () => _showModernBooleanDialog(label, value, onChanged),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: isActive
              ? const LinearGradient(
                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                )
              : null,
          color: isActive ? null : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isActive ? Colors.transparent : const Color(0xFFE2E8F0),
            width: 1,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: const Color(0xFF667EEA).withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isActive
                    ? Colors.white.withValues(alpha: 0.2)
                    : const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                displayValue,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isActive ? Colors.white : const Color(0xFF64748B),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Modern results header with count and styling
  Widget _buildModernResultsHeader() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF667EEA).withValues(alpha: 0.1),
            const Color(0xFF764BA2).withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF667EEA).withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.bar_chart, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${searchResults.length} Countries Found',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                ),
                Text(
                  'Results matching your search criteria',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Modern empty state with engaging design
  Widget _buildModernEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          /// Animated empty state illustration
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 800),
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF667EEA).withValues(alpha: 0.2),
                        const Color(0xFF764BA2).withValues(alpha: 0.2),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(60),
                  ),
                  child: const Icon(
                    Icons.search_off,
                    size: 60,
                    color: Color(0xFF667EEA),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          /// Main message
          const Text(
            'No Countries Found',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),

          /// Subtitle
          Text(
            'Try adjusting your search filters to find more countries',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),

          /// Suggestion cards
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  'Search Suggestions:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF475569),
                  ),
                ),
                const SizedBox(height: 12),
                _buildSuggestionItem('🌍', 'Try searching by region'),
                _buildSuggestionItem('👥', 'Filter by population size'),
                _buildSuggestionItem('🏛️', 'Search for specific capitals'),
                _buildSuggestionItem('🔄', 'Reset all filters'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build suggestion item for empty state
  Widget _buildSuggestionItem(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  /// Modern results list with staggered animation
  Widget _buildModernResultsList() {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate((context, index) {
          final country = searchResults[index];
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 300 + (index * 50)),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: Hero(
                    tag: 'country-card-${country.name.common}',
                    child: _buildModernCountryCard(country),
                  ),
                ),
              );
            },
          );
        }, childCount: searchResults.length),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
      ),
    );
  }

  /// Modern country card with enhanced styling
  Widget _buildModernCountryCard(Country country) {
    return GestureDetector(
      onTap: () => Get.to(
        () => CountryDetailScreen(country: country),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 300),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            /// Flag container
            Expanded(
              flex: 3,
              child: Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  child: Image.network(
                    country.flags.png,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF667EEA).withValues(alpha: 0.3),
                              const Color(0xFF764BA2).withValues(alpha: 0.3),
                            ],
                          ),
                        ),
                        child: const Icon(
                          Icons.flag,
                          color: Colors.white,
                          size: 32,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            /// Country info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    /// Country name
                    Text(
                      country.name.common,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    /// Capital and region
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (country.capital.isNotEmpty)
                          Text(
                            country.capital.first,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF667EEA).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            country.region,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF667EEA),
                            ),
                          ),
                        ),
                      ],
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
            country.capital.any(
              (capital) => capital.toLowerCase().contains(query),
            ) ||
            country.region.toLowerCase().contains(query) ||
            country.subregion.toLowerCase().contains(query);
      }).toList();
    }

    // Region filter
    if (selectedRegion != 'All') {
      results = results
          .where((country) => country.region == selectedRegion)
          .toList();
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
      results = results
          .where((country) => country.independent == isIndependent)
          .toList();
    }

    // UN membership filter
    if (isUnMember != null) {
      results = results
          .where((country) => country.unMember == isUnMember)
          .toList();
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
        return countries
            .where((c) => c.population >= 1000000 && c.population < 10000000)
            .toList();
      case 'Large (10M - 100M)':
        return countries
            .where((c) => c.population >= 10000000 && c.population < 100000000)
            .toList();
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
        return countries
            .where((c) => c.area != null && c.area! < 10000)
            .toList();
      case 'Medium (10K - 100K km²)':
        return countries
            .where(
              (c) => c.area != null && c.area! >= 10000 && c.area! < 100000,
            )
            .toList();
      case 'Large (100K - 1M km²)':
        return countries
            .where(
              (c) => c.area != null && c.area! >= 100000 && c.area! < 1000000,
            )
            .toList();
      case 'Very Large (> 1M km²)':
        return countries
            .where((c) => c.area != null && c.area! >= 1000000)
            .toList();
      default:
        return countries;
    }
  }

  /// Show region selection dialog
  void _showRegionDialog() {
    final regions = [
      'All',
      ...controller.availableRegions.where((r) => r != 'All'),
    ];

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

  /// Modern floating action button with gradient
  Widget _buildModernFloatingActionButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667EEA).withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: _resetModernFilters,
        backgroundColor: Colors.transparent,
        elevation: 0,
        icon: const Icon(Icons.refresh, color: Colors.white),
        label: const Text(
          'Reset Filters',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  /// Reset all filters with modern implementation
  void _resetModernFilters() {
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

  /// Modern boolean dialog with enhanced styling
  void _showModernBooleanDialog(
    String title,
    bool? currentValue,
    Function(bool?) onChanged,
  ) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// Dialog header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.tune,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Select $title',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              /// Options
              _buildModernRadioOption('All', null, currentValue, onChanged),
              _buildModernRadioOption('Yes', true, currentValue, onChanged),
              _buildModernRadioOption('No', false, currentValue, onChanged),
            ],
          ),
        ),
      ),
    );
  }

  /// Build modern radio option
  Widget _buildModernRadioOption(
    String label,
    bool? value,
    bool? currentValue,
    Function(bool?) onChanged,
  ) {
    final isSelected = value == currentValue;
    return GestureDetector(
      onTap: () {
        onChanged(value);
        Navigator.pop(context);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF667EEA).withValues(alpha: 0.1)
              : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF667EEA)
                : const Color(0xFFE2E8F0),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? const Color(0xFF667EEA)
                    : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF667EEA)
                      : const Color(0xFFCBD5E1),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 12)
                  : null,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? const Color(0xFF667EEA)
                    : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    /// Clean up animation controllers
    _fadeController.dispose();
    _slideController.dispose();
    searchController.dispose();
    super.dispose();
  }
}
