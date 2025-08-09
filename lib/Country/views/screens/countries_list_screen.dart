import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/country_controller.dart';
import '../../models/country_model.dart';
import 'country_detail_screen.dart';
import 'favorites_screen.dart';
import 'country_comparison_screen.dart';
import 'country_quiz_screen.dart';
import 'advanced_search_screen.dart';
import 'statistics_screen.dart';
import 'world_map_screen.dart';
import 'preferences_screen.dart';
import 'achievements_screen.dart';

/// Main screen for displaying countries list
class CountriesListScreen extends StatelessWidget {
  const CountriesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CountryController>(
      init: CountryController(),
      builder: (controller) => Scaffold(
        backgroundColor: Colors.grey[50],
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                expandedHeight: 140,
                floating: false,
                pinned: true,
                elevation: 0,
                backgroundColor: Colors.transparent,
                flexibleSpace: FlexibleSpaceBar(
                  title: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Country Explorer',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 24,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      Obx(
                        () => Text(
                          '${controller.filteredCountries.length} countries',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  centerTitle: true,
                ),
                actions: [
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.search_rounded,
                          color: Theme.of(context).primaryColor,
                          size: 20,
                        ),
                      ),
                      onPressed: () =>
                          _showModernSearchDialog(context, controller),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.favorite_rounded,
                          color: Colors.red[400],
                          size: 20,
                        ),
                      ),
                      onPressed: () => Get.to(() => const FavoritesScreen()),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(right: 16),
                    child: IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.filter_list_rounded,
                          color: Theme.of(context).primaryColor,
                          size: 20,
                        ),
                      ),
                      onPressed: () =>
                          _showModernFilterDialog(context, controller),
                    ),
                  ),
                ],
              ),
            ];
          },
          body: Obx(() {
            if (controller.isLoading.value) {
              return _buildModernLoadingState();
            }

            if (controller.filteredCountries.isEmpty) {
              return _buildModernEmptyState();
            }

            return _buildModernCountriesList(controller);
          }),
        ),
        drawer: _buildModernDrawer(context, controller),
        floatingActionButton: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: FloatingActionButton(
            onPressed: () => Get.to(() => const AdvancedSearchScreen()),
            backgroundColor: Theme.of(context).primaryColor,
            elevation: 0,
            child: const Icon(
              Icons.manage_search_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }

  /// Build modern loading state
  Widget _buildModernLoadingState() {
    return Builder(
      builder: (context) => Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor,
                    ),
                    strokeWidth: 3,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Discovering Countries',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Loading amazing places from around the world...',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build modern empty state
  Widget _buildModernEmptyState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(60),
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: 60,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Countries Found',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or filter criteria',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                final controller = Get.find<CountryController>();
                controller.clearSearch();
                controller.filterByRegion('All');
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reset Filters'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build modern countries list
  Widget _buildModernCountriesList(CountryController controller) {
    return Builder(
      builder: (context) => RefreshIndicator(
        onRefresh: controller.refreshCountries,
        color: Theme.of(context).primaryColor,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.0,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final country = controller.filteredCountries[index];
                  return _buildModernCountryCard(country);
                }, childCount: controller.filteredCountries.length),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  /// Build modern country card
  Widget _buildModernCountryCard(Country country) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _navigateToCountryDetail(country),
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Flag section
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      child: Image.network(
                        country.flags.png,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey[200],
                          child: Icon(
                            Icons.flag_rounded,
                            size: 40,
                            color: Colors.grey[400],
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Favorite button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GetBuilder<CountryController>(
                      builder: (controller) => Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: Icon(
                            controller.isFavorite(country)
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            color: controller.isFavorite(country)
                                ? Colors.red[400]
                                : Colors.grey[600],
                            size: 20,
                          ),
                          onPressed: () => controller.toggleFavorite(country),
                          padding: const EdgeInsets.all(8),
                          constraints: const BoxConstraints(
                            minWidth: 36,
                            minHeight: 36,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Info section
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        country.name.common,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey[800],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      country.region,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Icon(
                          Icons.people_rounded,
                          size: 11,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            _formatPopulation(country.population),
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                            ),
                            overflow: TextOverflow.ellipsis,
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

  void _navigateToCountryDetail(Country country) {
    Get.to(() => CountryDetailScreen(country: country));
  }

  /// Format population number
  String _formatPopulation(int population) {
    if (population >= 1000000000) {
      return '${(population / 1000000000).toStringAsFixed(1)}B';
    } else if (population >= 1000000) {
      return '${(population / 1000000).toStringAsFixed(1)}M';
    } else if (population >= 1000) {
      return '${(population / 1000).toStringAsFixed(1)}K';
    } else {
      return population.toString();
    }
  }

  /// Show modern search dialog
  void _showModernSearchDialog(
    BuildContext context,
    CountryController controller,
  ) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.search_rounded,
                    color: Theme.of(context).primaryColor,
                    size: 28,
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Search Countries',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Enter country name...',
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: Colors.grey[400],
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  fillColor: Colors.grey[100],
                  filled: true,
                ),
                onChanged: (value) => controller.searchCountries(value),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        controller.clearSearch();
                        Navigator.pop(context);
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Clear'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Done'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Show modern filter dialog
  void _showModernFilterDialog(
    BuildContext context,
    CountryController controller,
  ) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.filter_list_rounded,
                    color: Theme.of(context).primaryColor,
                    size: 28,
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Filter by Region',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.maxFinite,
                height: 300,
                child: ListView(
                  children: controller.availableRegions.map((region) {
                    return Obx(
                      () => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: controller.selectedRegion.value == region
                              ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
                              : Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: RadioListTile<String>(
                          title: Text(
                            region,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: controller.selectedRegion.value == region
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey[700],
                            ),
                          ),
                          value: region,
                          groupValue: controller.selectedRegion.value,
                          activeColor: Theme.of(context).primaryColor,
                          onChanged: (value) {
                            controller.filterByRegion(value!);
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build modern navigation drawer
  Widget _buildModernDrawer(
    BuildContext context,
    CountryController controller,
  ) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor.withValues(alpha: 0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.public_rounded,
                        size: 32,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Country Explorer',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Discover the world',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildModernDrawerItem(
                  context,
                  Icons.explore_rounded,
                  'Explore Countries',
                  true,
                  () => Navigator.pop(context),
                ),
                _buildModernDrawerItem(
                  context,
                  Icons.favorite_rounded,
                  'Favorites',
                  false,
                  () {
                    Navigator.pop(context);
                    Get.to(() => const FavoritesScreen());
                  },
                ),
                _buildModernDrawerItem(
                  context,
                  Icons.compare_arrows_rounded,
                  'Compare Countries',
                  false,
                  () {
                    Navigator.pop(context);
                    Get.to(() => const CountryComparisonScreen());
                  },
                ),
                _buildModernDrawerItem(
                  context,
                  Icons.quiz_rounded,
                  'Country Quiz',
                  false,
                  () {
                    Navigator.pop(context);
                    Get.to(() => const CountryQuizScreen());
                  },
                ),
                _buildModernDrawerItem(
                  context,
                  Icons.map_rounded,
                  'World Map',
                  false,
                  () {
                    Navigator.pop(context);
                    Get.to(() => const WorldMapScreen());
                  },
                ),
                const SizedBox(height: 16),
                Container(height: 1, color: Colors.grey[200]),
                const SizedBox(height: 16),
                Obx(
                  () => _buildModernDrawerItemWithSubtitle(
                    context,
                    Icons.pie_chart_rounded,
                    'Statistics',
                    '${controller.countries.length} countries loaded',
                    () {
                      Navigator.pop(context);
                      Get.to(() => const StatisticsScreen());
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Container(height: 1, color: Colors.grey[200]),
                const SizedBox(height: 16),
                _buildModernDrawerItem(
                  context,
                  Icons.emoji_events_rounded,
                  'Achievements',
                  false,
                  () {
                    Navigator.pop(context);
                    Get.to(() => const AchievementsScreen());
                  },
                ),
                _buildModernDrawerItem(
                  context,
                  Icons.settings_rounded,
                  'Settings',
                  false,
                  () {
                    Navigator.pop(context);
                    Get.to(() => const PreferencesScreen());
                  },
                ),
                _buildModernDrawerItem(
                  context,
                  Icons.info_outline_rounded,
                  'About',
                  false,
                  () {
                    Navigator.pop(context);
                    _showAboutDialog(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build modern drawer item
  Widget _buildModernDrawerItem(
    BuildContext context,
    IconData icon,
    String title,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? Theme.of(context).primaryColor : Colors.grey[600],
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected
                ? Theme.of(context).primaryColor
                : Colors.grey[700],
          ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  /// Build modern drawer item with subtitle
  Widget _buildModernDrawerItemWithSubtitle(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.grey[600]),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 12, color: Colors.grey[500]),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  /// Show about dialog
  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Country Explorer',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.public, size: 48),
      children: [
        const Text('A beautiful app to explore countries around the world.'),
        const SizedBox(height: 8),
        const Text('Built with Flutter and powered by REST Countries API.'),
      ],
    );
  }
}
