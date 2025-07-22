import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../controllers/country_controller.dart';
import '../../models/country_model.dart';

/// Screen for comparing multiple countries side by side
class CountryComparisonScreen extends StatefulWidget {
  final List<Country> initialCountries;
  
  const CountryComparisonScreen({
    Key? key,
    this.initialCountries = const [],
  }) : super(key: key);

  @override
  State<CountryComparisonScreen> createState() => _CountryComparisonScreenState();
}

class _CountryComparisonScreenState extends State<CountryComparisonScreen> {
  List<Country> selectedCountries = [];
  final controller = Get.find<CountryController>();

  @override
  void initState() {
    super.initState();
    selectedCountries = List.from(widget.initialCountries);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Compare Countries'),
        centerTitle: true,
        actions: [
          if (selectedCountries.length < 4)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _showCountrySelector,
              tooltip: 'Add Country',
            ),
          if (selectedCountries.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_all),
              onPressed: _clearAll,
              tooltip: 'Clear All',
            ),
        ],
      ),
      body: selectedCountries.isEmpty
          ? _buildEmptyState()
          : _buildComparisonView(),
    );
  }

  /// Build empty state when no countries selected
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.compare_arrows,
            size: 100,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            'No Countries to Compare',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Add countries to compare their statistics\nand learn interesting facts!',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _showCountrySelector,
            icon: const Icon(Icons.add),
            label: const Text('Add Country'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  /// Build comparison view with countries data
  Widget _buildComparisonView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Country headers
          _buildCountryHeaders(),
          const SizedBox(height: 16),
          
          // Comparison sections
          _buildComparisonSection('Basic Info', _buildBasicInfoRows()),
          const SizedBox(height: 16),
          _buildComparisonSection('Geography', _buildGeographyRows()),
          const SizedBox(height: 16),
          _buildComparisonSection('Demographics', _buildDemographicsRows()),
          const SizedBox(height: 16),
          _buildComparisonSection('Economics', _buildEconomicsRows()),
        ],
      ),
    );
  }

  /// Build country headers with flags and names
  Widget _buildCountryHeaders() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const SizedBox(width: 120), // Space for labels
            ...selectedCountries.map((country) => Expanded(
              child: Column(
                children: [
                  // Country flag
                  Container(
                    height: 60,
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
                      child: CachedNetworkImage(
                        imageUrl: country.flags.png,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[300],
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Country name
                  Text(
                    country.name.common,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // Remove button
                  IconButton(
                    icon: const Icon(Icons.close, size: 16),
                    onPressed: () => _removeCountry(country),
                    tooltip: 'Remove',
                  ),
                ],
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }

  /// Build comparison section with title and data rows
  Widget _buildComparisonSection(String title, List<Widget> rows) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...rows,
          ],
        ),
      ),
    );
  }

  /// Build basic information comparison rows
  List<Widget> _buildBasicInfoRows() {
    return [
      _buildComparisonRow('Capital', selectedCountries.map((c) => 
        c.capital.isNotEmpty ? c.capital.first : 'N/A').toList()),
      _buildComparisonRow('Region', selectedCountries.map((c) => c.region).toList()),
      _buildComparisonRow('Subregion', selectedCountries.map((c) => c.subregion).toList()),
    ];
  }

  /// Build geography comparison rows
  List<Widget> _buildGeographyRows() {
    return [
      _buildComparisonRow('Area (km²)', selectedCountries.map((c) => 
        c.area != null ? c.area!.toStringAsFixed(0) : 'N/A').toList()),
      _buildComparisonRow('Timezones', selectedCountries.map((c) => 
        c.timezones.length.toString()).toList()),
      _buildComparisonRow('Borders', selectedCountries.map((c) => 
        c.borders.length.toString()).toList()),
    ];
  }

  /// Build demographics comparison rows
  List<Widget> _buildDemographicsRows() {
    return [
      _buildComparisonRow('Population', selectedCountries.map((c) => 
        c.formattedPopulation).toList()),
      _buildComparisonRow('Languages', selectedCountries.map((c) => 
        c.languages.length.toString()).toList()),
      _buildComparisonRow('Independent', selectedCountries.map((c) => 
        c.independent ? 'Yes' : 'No').toList()),
    ];
  }

  /// Build economics comparison rows
  List<Widget> _buildEconomicsRows() {
    return [
      _buildComparisonRow('Currencies', selectedCountries.map((c) => 
        c.currencies.length.toString()).toList()),
      _buildComparisonRow('UN Member', selectedCountries.map((c) => 
        c.unMember ? 'Yes' : 'No').toList()),
      _buildComparisonRow('FIFA Code', selectedCountries.map((c) => 
        c.fifa ?? 'N/A').toList()),
    ];
  }

  /// Build a single comparison row
  Widget _buildComparisonRow(String label, List<String> values) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
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
          ...values.map((value) => Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          )).toList(),
        ],
      ),
    );
  }

  /// Show country selector dialog
  void _showCountrySelector() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Country'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: Obx(() => ListView.builder(
            itemCount: controller.countries.length,
            itemBuilder: (context, index) {
              final country = controller.countries[index];
              final isSelected = selectedCountries.any((c) => 
                c.name.common == country.name.common);
              
              if (isSelected) return const SizedBox();
              
              return ListTile(
                leading: SizedBox(
                  width: 40,
                  height: 30,
                  child: CachedNetworkImage(
                    imageUrl: country.flags.png,
                    fit: BoxFit.cover,
                  ),
                ),
                title: Text(country.name.common),
                subtitle: Text(country.region),
                onTap: () {
                  _addCountry(country);
                  Navigator.pop(context);
                },
              );
            },
          )),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  /// Add country to comparison
  void _addCountry(Country country) {
    if (selectedCountries.length < 4 && 
        !selectedCountries.any((c) => c.name.common == country.name.common)) {
      setState(() {
        selectedCountries.add(country);
      });
    }
  }

  /// Remove country from comparison
  void _removeCountry(Country country) {
    setState(() {
      selectedCountries.removeWhere((c) => c.name.common == country.name.common);
    });
  }

  /// Clear all selected countries
  void _clearAll() {
    setState(() {
      selectedCountries.clear();
    });
  }
}
