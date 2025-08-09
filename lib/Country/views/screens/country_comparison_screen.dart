import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../controllers/country_controller.dart';
import '../../models/country_model.dart';

/// Modern screen for comparing multiple countries side by side
class CountryComparisonScreen extends StatefulWidget {
  final List<Country> initialCountries;

  const CountryComparisonScreen({super.key, this.initialCountries = const []});

  @override
  State<CountryComparisonScreen> createState() =>
      _CountryComparisonScreenState();
}

class _CountryComparisonScreenState extends State<CountryComparisonScreen>
    with TickerProviderStateMixin {
  List<Country> selectedCountries = [];
  final controller = Get.find<CountryController>();

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    selectedCountries = List.from(widget.initialCountries);

    /// Initialize animation controllers
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 400),
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

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    /// Start animations
    _fadeController.forward();
    _slideController.forward();
    _scaleController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
          ),
        ),
        child: SafeArea(
          child: SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  _buildModernSliverAppBar(),
                  SliverToBoxAdapter(
                    child: selectedCountries.isEmpty
                        ? _buildModernEmptyState()
                        : _buildModernComparisonView(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Build modern sliver app bar with glass-morphism effect
  Widget _buildModernSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120.0,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      actions: [
        if (selectedCountries.length < 4)
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: IconButton(
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              onPressed: _showModernCountrySelector,
              tooltip: 'Add Country',
            ),
          ),
        if (selectedCountries.isNotEmpty)
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: IconButton(
              icon: const Icon(Icons.clear_all_rounded, color: Colors.white),
              onPressed: _clearAll,
              tooltip: 'Clear All',
            ),
          ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'Country Comparison',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
            ),
          ),
        ),
      ),
    );
  }

  /// Build modern empty state with enhanced visuals
  Widget _buildModernEmptyState() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              /// Modern empty state icon
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.3),
                      Colors.white.withValues(alpha: 0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.compare_arrows_rounded,
                  size: 80,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),

              /// Title and description
              const Text(
                'Compare Countries',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Add countries to compare their statistics,\ngeography, and discover interesting facts!',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withValues(alpha: 0.8),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              /// Modern add button
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.white, Color(0xFFF8FAFC)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _showModernCountrySelector,
                    borderRadius: BorderRadius.circular(20),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.add_rounded,
                            color: Color(0xFF667EEA),
                            size: 24,
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Add First Country',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF667EEA),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build modern comparison view with enhanced design
  Widget _buildModernComparisonView() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          /// Modern country headers
          _buildModernCountryHeaders(),
          const SizedBox(height: 24),

          /// Comparison sections with staggered animations
          ..._buildModernComparisonSections(),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  /// Build modern country headers with flags and names
  Widget _buildModernCountryHeaders() {
    return Container(
      padding: const EdgeInsets.all(24),
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
          /// Section title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.flag_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              const Text(
                'Countries Overview',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          /// Countries grid
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: selectedCountries.map((country) {
              final index = selectedCountries.indexOf(country);
              return TweenAnimationBuilder<double>(
                duration: Duration(milliseconds: 600 + (index * 100)),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Opacity(
                      opacity: value,
                      child: _buildModernCountryCard(country),
                    ),
                  );
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// Build modern country card
  Widget _buildModernCountryCard(Country country) {
    return Container(
      width: (MediaQuery.of(context).size.width - 80) / 2,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
      ),
      child: Column(
        children: [
          /// Country flag
          Hero(
            tag: 'flag_${country.name.common}',
            child: Container(
              height: 60,
              width: 90,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: country.flags.png,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[300],
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          /// Country name
          Text(
            country.name.common,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: Color(0xFF1E293B),
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),

          /// Remove button
          Container(
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.close_rounded,
                color: Colors.red,
                size: 18,
              ),
              onPressed: () => _removeCountry(country),
              tooltip: 'Remove ${country.name.common}',
            ),
          ),
        ],
      ),
    );
  }

  /// Build modern comparison sections with animations
  List<Widget> _buildModernComparisonSections() {
    final sections = [
      {
        'title': 'Basic Information',
        'icon': Icons.info_rounded,
        'color': Colors.blue,
        'rows': _buildBasicInfoRows(),
      },
      {
        'title': 'Geography',
        'icon': Icons.public_rounded,
        'color': Colors.green,
        'rows': _buildGeographyRows(),
      },
      {
        'title': 'Demographics',
        'icon': Icons.people_rounded,
        'color': Colors.orange,
        'rows': _buildDemographicsRows(),
      },
      {
        'title': 'Economics',
        'icon': Icons.attach_money_rounded,
        'color': Colors.purple,
        'rows': _buildEconomicsRows(),
      },
    ];

    return sections.asMap().entries.map((entry) {
      final index = entry.key;
      final section = entry.value;

      return TweenAnimationBuilder<double>(
        duration: Duration(milliseconds: 800 + (index * 200)),
        tween: Tween(begin: 0.0, end: 1.0),
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(0, 30 * (1 - value)),
            child: Opacity(
              opacity: value,
              child: _buildModernComparisonSection(
                section['title'] as String,
                section['icon'] as IconData,
                section['color'] as Color,
                section['rows'] as List<Widget>,
              ),
            ),
          );
        },
      );
    }).toList();
  }

  /// Build modern comparison section with enhanced design
  Widget _buildModernComparisonSection(
    String title,
    IconData icon,
    Color color,
    List<Widget> rows,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
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
          /// Section header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          /// Comparison rows
          ...rows,
        ],
      ),
    );
  }

  /// Build modern comparison row
  Widget _buildModernComparisonRow(String label, List<String> values) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Label
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 12),

          /// Values
          Row(
            children: values.asMap().entries.map((entry) {
              final index = entry.key;
              final value = entry.value;

              return Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 12,
                  ),
                  margin: EdgeInsets.only(
                    right: index < values.length - 1 ? 8 : 0,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: Color(0xFF1E293B),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// Build basic information comparison rows
  List<Widget> _buildBasicInfoRows() {
    return [
      _buildModernComparisonRow(
        'Capital',
        selectedCountries
            .map((c) => c.capital.isNotEmpty ? c.capital.first : 'N/A')
            .toList(),
      ),
      _buildModernComparisonRow(
        'Region',
        selectedCountries.map((c) => c.region).toList(),
      ),
      _buildModernComparisonRow(
        'Subregion',
        selectedCountries
            .map((c) => c.subregion.isNotEmpty ? c.subregion : 'N/A')
            .toList(),
      ),
    ];
  }

  /// Build geography comparison rows
  List<Widget> _buildGeographyRows() {
    return [
      _buildModernComparisonRow(
        'Area (km²)',
        selectedCountries
            .map((c) => c.area != null ? c.area!.toStringAsFixed(0) : 'N/A')
            .toList(),
      ),
      _buildModernComparisonRow(
        'Timezones',
        selectedCountries.map((c) => c.timezones.length.toString()).toList(),
      ),
      _buildModernComparisonRow(
        'Borders',
        selectedCountries.map((c) => c.borders.length.toString()).toList(),
      ),
    ];
  }

  /// Build demographics comparison rows
  List<Widget> _buildDemographicsRows() {
    return [
      _buildModernComparisonRow(
        'Population',
        selectedCountries.map((c) => c.formattedPopulation).toList(),
      ),
      _buildModernComparisonRow(
        'Languages',
        selectedCountries.map((c) => c.languages.length.toString()).toList(),
      ),
      _buildModernComparisonRow(
        'Independent',
        selectedCountries.map((c) => c.independent ? 'Yes' : 'No').toList(),
      ),
    ];
  }

  /// Build economics comparison rows
  List<Widget> _buildEconomicsRows() {
    return [
      _buildModernComparisonRow(
        'Currencies',
        selectedCountries.map((c) => c.currencies.length.toString()).toList(),
      ),
      _buildModernComparisonRow(
        'UN Member',
        selectedCountries.map((c) => c.unMember ? 'Yes' : 'No').toList(),
      ),
      _buildModernComparisonRow(
        'FIFA Code',
        selectedCountries.map((c) => c.fifa ?? 'N/A').toList(),
      ),
    ];
  }

  /// Show modern country selector dialog
  void _showModernCountrySelector() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
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
                Icons.search_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Select Country',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E293B),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: Obx(
            () => ListView.builder(
              itemCount: controller.countries.length,
              itemBuilder: (context, index) {
                final country = controller.countries[index];
                final isSelected = selectedCountries.any(
                  (c) => c.name.common == country.name.common,
                );

                if (isSelected) return const SizedBox();

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                      width: 1,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: Container(
                      width: 48,
                      height: 32,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
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
                        ),
                      ),
                    ),
                    title: Text(
                      country.name.common,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    subtitle: Text(
                      country.region,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.add_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                    onTap: () {
                      _addCountry(country);
                      Navigator.pop(context);
                    },
                  ),
                );
              },
            ),
          ),
        ),
        actions: [
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
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

      /// Restart animations for new content
      _scaleController.reset();
      _scaleController.forward();
    }
  }

  /// Remove country from comparison
  void _removeCountry(Country country) {
    setState(() {
      selectedCountries.removeWhere(
        (c) => c.name.common == country.name.common,
      );
    });
  }

  /// Clear all selected countries
  void _clearAll() {
    setState(() {
      selectedCountries.clear();
    });
  }
}
