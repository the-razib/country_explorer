import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/country_controller.dart';
import '../../models/country_model.dart';
import '../widgets/country_card_widget.dart';
import 'country_detail_screen.dart';

/// Screen for displaying favorite countries
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CountryController>(
      builder: (controller) => Scaffold(
        appBar: AppBar(
          title: const Text('Favorite Countries'),
          centerTitle: true,
          actions: [
            Obx(() => controller.favoriteCountries.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_all),
                    onPressed: () => _showClearDialog(context, controller),
                    tooltip: 'Clear All Favorites',
                  )
                : const SizedBox()),
          ],
        ),
        body: Obx(() {
          if (controller.favoriteCountries.isEmpty) {
            return _buildEmptyState(context);
          }
          
          return RefreshIndicator(
            onRefresh: () async => controller.loadFavorites(),
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: controller.favoriteCountries.length,
              itemBuilder: (context, index) {
                final country = controller.favoriteCountries[index];
                return CountryCardWidget(
                  country: country,
                  onTap: () => _navigateToCountryDetail(country),
                );
              },
            ),
          );
        }),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.explore),
          label: const Text('Explore Countries'),
        ),
      ),
    );
  }

  /// Build empty state when no favorites
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 100,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            'No Favorite Countries Yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Start exploring and add countries to your favorites\nby tapping the heart icon!',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.explore),
            label: const Text('Explore Countries'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  /// Show dialog to confirm clearing all favorites
  void _showClearDialog(BuildContext context, CountryController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Favorites'),
        content: const Text(
          'Are you sure you want to remove all countries from your favorites? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.clearAllFavorites();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  /// Navigate to country detail screen
  void _navigateToCountryDetail(Country country) {
    Get.to(() => CountryDetailScreen(country: country));
  }
}
