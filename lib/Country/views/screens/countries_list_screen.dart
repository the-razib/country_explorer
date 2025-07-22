import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/country_controller.dart';
import '../../models/country_model.dart';
import '../widgets/country_card_widget.dart';
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
  const CountriesListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CountryController>(
      init: CountryController(),
      builder: (controller) => Scaffold(
        appBar: AppBar(
          title: const Text('Country Explorer'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => _showSearchDialog(context, controller),
            ),
            IconButton(
              icon: const Icon(Icons.manage_search),
              onPressed: () => Get.to(() => const AdvancedSearchScreen()),
            ),
            IconButton(
              icon: const Icon(Icons.favorite),
              onPressed: () => Get.to(() => const FavoritesScreen()),
            ),
          ],
        ),
        drawer: _buildDrawer(context, controller),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading countries...'),
                ],
              ),
            );
          }

          if (controller.filteredCountries.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No countries found'),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: controller.refreshCountries,
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: controller.filteredCountries.length,
              itemBuilder: (context, index) {
                final country = controller.filteredCountries[index];
                return CountryCardWidget(
                  country: country,
                  onTap: () => _navigateToCountryDetail(country),
                );
              },
            ),
          );
        }),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showFilterDialog(context, controller),
          child: const Icon(Icons.filter_list),
        ),
      ),
    );
  }

  void _showSearchDialog(BuildContext context, CountryController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Countries'),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Enter country name...',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (value) => controller.searchCountries(value),
        ),
        actions: [
          TextButton(
            onPressed: () {
              controller.clearSearch();
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog(BuildContext context, CountryController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter by Region'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: controller.availableRegions.map((region) {
              return Obx(
                () => RadioListTile<String>(
                  title: Text(region),
                  value: region,
                  groupValue: controller.selectedRegion.value,
                  onChanged: (value) {
                    controller.filterByRegion(value!);
                    Navigator.pop(context);
                  },
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  void _navigateToCountryDetail(Country country) {
    Get.to(() => CountryDetailScreen(country: country));
  }

  /// Build navigation drawer
  Widget _buildDrawer(BuildContext context, CountryController controller) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor.withOpacity(0.7),
                ],
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.public, size: 48, color: Colors.white),
                SizedBox(height: 8),
                Text(
                  'Country Explorer',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Discover the world',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.explore),
            title: const Text('Explore Countries'),
            selected: true,
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text('Favorites'),
            onTap: () {
              Navigator.pop(context);
              Get.to(() => const FavoritesScreen());
            },
          ),
          ListTile(
            leading: const Icon(Icons.compare_arrows),
            title: const Text('Compare Countries'),
            onTap: () {
              Navigator.pop(context);
              Get.to(() => const CountryComparisonScreen());
            },
          ),
          ListTile(
            leading: const Icon(Icons.quiz),
            title: const Text('Country Quiz'),
            onTap: () {
              Navigator.pop(context);
              Get.to(() => const CountryQuizScreen());
            },
          ),
          ListTile(
            leading: const Icon(Icons.map),
            title: const Text('World Map'),
            onTap: () {
              Navigator.pop(context);
              Get.to(() => const WorldMapScreen());
            },
          ),
          const Divider(),
          Obx(
            () => ListTile(
              leading: const Icon(Icons.pie_chart),
              title: const Text('Statistics'),
              subtitle: Text('${controller.countries.length} countries loaded'),
              onTap: () {
                Navigator.pop(context);
                Get.to(() => const StatisticsScreen());
              },
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.emoji_events),
            title: const Text('Achievements'),
            onTap: () {
              Navigator.pop(context);
              Get.to(() => const AchievementsScreen());
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              Get.to(() => const PreferencesScreen());
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            onTap: () {
              Navigator.pop(context);
              _showAboutDialog(context);
            },
          ),
        ],
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
