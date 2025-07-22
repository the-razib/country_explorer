import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/country_model.dart';
import '../../controllers/country_controller.dart';
import '../../controllers/achievement_controller.dart';

/// Detailed view screen for a specific country
class CountryDetailScreen extends StatelessWidget {
  final Country country;

  const CountryDetailScreen({Key? key, required this.country})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CountryController>();
    final achievementController = Get.find<AchievementController>();

    // Track country view for achievements
    achievementController.recordCountryView(country.name.common);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context, controller),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBasicInfo(context),
                  const SizedBox(height: 24),
                  _buildGeographySection(context),
                  const SizedBox(height: 24),
                  _buildCurrencySection(context),
                  const SizedBox(height: 24),
                  _buildLanguageSection(context),
                  const SizedBox(height: 24),
                  _buildBordersSection(context, controller),
                  const SizedBox(height: 24),
                  _buildActionButtons(context),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build the sliver app bar with country flag
  Widget _buildSliverAppBar(
    BuildContext context,
    CountryController controller,
  ) {
    return SliverAppBar(
      expandedHeight: 300.0,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          country.name.common,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                offset: Offset(1, 1),
                blurRadius: 2,
                color: Colors.black54,
              ),
            ],
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: country.flags.png,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.grey[300],
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[300],
                child: const Icon(Icons.error),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        Obx(
          () => IconButton(
            icon: Icon(
              controller.isFavorite(country)
                  ? Icons.favorite
                  : Icons.favorite_border,
              color: controller.isFavorite(country) ? Colors.red : Colors.white,
            ),
            onPressed: () => controller.toggleFavorite(country),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: () => _shareCountry(),
        ),
      ],
    );
  }

  /// Build basic country information
  Widget _buildBasicInfo(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Basic Information',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Official Name', country.name.official),
            _buildInfoRow(
              'Capital',
              country.capital.isNotEmpty ? country.capital.join(', ') : 'N/A',
            ),
            _buildInfoRow('Region', country.region),
            _buildInfoRow('Subregion', country.subregion),
            _buildInfoRow('Population', country.formattedPopulation),
            if (country.area != null)
              _buildInfoRow('Area', '${country.area!.toStringAsFixed(0)} km²'),
          ],
        ),
      ),
    );
  }

  /// Build geography section
  Widget _buildGeographySection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Geography',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (country.latlng != null && country.latlng!.length >= 2)
              _buildInfoRow(
                'Coordinates',
                '${country.latlng![0].toStringAsFixed(4)}, ${country.latlng![1].toStringAsFixed(4)}',
              ),
            if (country.timezones.isNotEmpty)
              _buildInfoRow('Timezones', country.timezones.join(', ')),
          ],
        ),
      ),
    );
  }

  /// Build currency section
  Widget _buildCurrencySection(BuildContext context) {
    if (country.currencies.isEmpty) return const SizedBox();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Currencies',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...country.currencies.entries
                .map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            entry.key,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${entry.value.name} (${entry.value.symbol})',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ],
        ),
      ),
    );
  }

  /// Build language section
  Widget _buildLanguageSection(BuildContext context) {
    if (country.languages.isEmpty) return const SizedBox();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Languages',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: country.languages.entries
                  .map(
                    (language) => Chip(
                      label: Text(language.value),
                      backgroundColor: Theme.of(
                        context,
                      ).primaryColor.withOpacity(0.1),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  /// Build borders section
  Widget _buildBordersSection(
    BuildContext context,
    CountryController controller,
  ) {
    if (country.borders.isEmpty) return const SizedBox();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Border Countries',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: country.borders
                  .map(
                    (border) => ActionChip(
                      label: Text(border),
                      onPressed: () => _onBorderCountryTap(border, controller),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  /// Build action buttons
  Widget _buildActionButtons(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Actions',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _openGoogleMaps(),
                    icon: const Icon(Icons.map),
                    label: const Text('View on Map'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _openWikipedia(),
                    icon: const Icon(Icons.info_outline),
                    label: const Text('Wikipedia'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Build information row widget
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  /// Handle border country tap
  void _onBorderCountryTap(
    String borderCode,
    CountryController controller,
  ) async {
    try {
      final borderCountry = await controller.getCountryByCode(borderCode);
      if (borderCountry != null) {
        Get.to(() => CountryDetailScreen(country: borderCountry));
      } else {
        Get.snackbar(
          'Not Found',
          'Could not find information for country code: $borderCode',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (error) {
      Get.snackbar(
        'Error',
        'Failed to load border country information',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Open Google Maps for the country
  void _openGoogleMaps() async {
    if (country.latlng != null && country.latlng!.length >= 2) {
      final lat = country.latlng![0];
      final lng = country.latlng![1];
      final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';

      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      } else {
        Get.snackbar(
          'Error',
          'Could not open maps',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

  /// Open Wikipedia for the country
  void _openWikipedia() async {
    final countryName = country.name.common.replaceAll(' ', '_');
    final url = 'https://en.wikipedia.org/wiki/$countryName';

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      Get.snackbar(
        'Error',
        'Could not open Wikipedia',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Share country information
  void _shareCountry() {
    // For now, just show a snackbar
    Get.snackbar(
      'Share',
      'Sharing functionality will be available soon!',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
