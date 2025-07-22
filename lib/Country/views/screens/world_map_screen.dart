import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/country_controller.dart';
import '../../models/country_model.dart';
import 'country_detail_screen.dart';

/// Interactive world map screen for visual country exploration
class WorldMapScreen extends StatefulWidget {
  const WorldMapScreen({Key? key}) : super(key: key);

  @override
  State<WorldMapScreen> createState() => _WorldMapScreenState();
}

class _WorldMapScreenState extends State<WorldMapScreen> {
  final controller = Get.find<CountryController>();
  String selectedRegion = 'All';
  List<Country> filteredCountries = [];

  @override
  void initState() {
    super.initState();
    filteredCountries = controller.countries;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('World Map'),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            onSelected: _filterByRegion,
            itemBuilder: (context) => controller.availableRegions
                .map(
                  (region) => PopupMenuItem(
                    value: region,
                    child: Row(
                      children: [
                        Icon(
                          selectedRegion == region ? Icons.check : Icons.public,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(region),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Region info bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            child: Row(
              children: [
                Icon(Icons.location_on, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  selectedRegion == 'All'
                      ? 'Showing all ${filteredCountries.length} countries'
                      : 'Showing ${filteredCountries.length} countries in $selectedRegion',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ),

          // Map view (simulated with region cards)
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // World regions as interactive cards
                  if (selectedRegion == 'All') ...[
                    _buildRegionCard('Africa', Icons.landscape, Colors.orange),
                    _buildRegionCard('Americas', Icons.terrain, Colors.green),
                    _buildRegionCard('Asia', Icons.waves, Colors.blue),
                    _buildRegionCard('Europe', Icons.castle, Colors.purple),
                    _buildRegionCard('Oceania', Icons.water, Colors.teal),
                  ] else ...[
                    // Show countries in selected region
                    _buildCountriesGrid(),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: selectedRegion != 'All'
          ? FloatingActionButton(
              onPressed: () => _filterByRegion('All'),
              child: const Icon(Icons.public),
              tooltip: 'Show All Regions',
            )
          : null,
    );
  }

  /// Build region card for map navigation
  Widget _buildRegionCard(String region, IconData icon, Color color) {
    final regionCountries = controller.countries
        .where((c) => c.region == region)
        .toList();

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _filterByRegion(region),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      region,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${regionCountries.length} countries',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Total population: ${_calculateTotalPopulation(regionCountries)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: color, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  /// Build countries grid for selected region
  Widget _buildCountriesGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: filteredCountries.length,
      itemBuilder: (context, index) {
        final country = filteredCountries[index];
        return _buildCountryMapCard(country);
      },
    );
  }

  /// Build country card for map view
  Widget _buildCountryMapCard(Country country) {
    return Card(
      child: InkWell(
        onTap: () => Get.to(() => CountryDetailScreen(country: country)),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Country flag
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      country.flags.png,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.flag, size: 32),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Country name
              Expanded(
                flex: 1,
                child: Text(
                  country.name.common,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // Population
              Text(
                _formatPopulation(country.population),
                style: TextStyle(fontSize: 10, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Filter countries by region
  void _filterByRegion(String region) {
    setState(() {
      selectedRegion = region;
      if (region == 'All') {
        filteredCountries = controller.countries;
      } else {
        filteredCountries = controller.countries
            .where((country) => country.region == region)
            .toList();
      }
    });
  }

  /// Calculate total population for a list of countries
  String _calculateTotalPopulation(List<Country> countries) {
    final total = countries.fold<int>(
      0,
      (sum, country) => sum + country.population,
    );
    return _formatPopulation(total);
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
}
