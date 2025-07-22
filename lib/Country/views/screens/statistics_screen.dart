import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../controllers/country_controller.dart';
import '../../models/country_model.dart';
import 'country_detail_screen.dart';

/// Statistics and data visualization dashboard
class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({Key? key}) : super(key: key);

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen>
    with SingleTickerProviderStateMixin {
  final controller = Get.find<CountryController>();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics Dashboard'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.pie_chart), text: 'Regions'),
            Tab(icon: Icon(Icons.bar_chart), text: 'Population'),
            Tab(icon: Icon(Icons.show_chart), text: 'Geography'),
            Tab(icon: Icon(Icons.emoji_events), text: 'Records'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRegionStatistics(),
          _buildPopulationStatistics(),
          _buildGeographyStatistics(),
          _buildRecordsStatistics(),
        ],
      ),
    );
  }

  /// Build region statistics tab
  Widget _buildRegionStatistics() {
    final regionCounts = controller.getCountriesByRegionCount();
    final total = regionCounts.values.fold<int>(0, (sum, count) => sum + count);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.public, size: 48, color: Colors.blue),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Countries',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      Text(
                        total.toString(),
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Pie chart
          const Text(
            'Countries by Region',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 300,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: PieChart(
                  PieChartData(
                    sections: _buildPieChartSections(regionCounts),
                    centerSpaceRadius: 40,
                    sectionsSpace: 2,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Legend
          _buildRegionLegend(regionCounts),
          const SizedBox(height: 24),

          // Region details
          const Text(
            'Region Details',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...regionCounts.entries.map(
            (entry) => _buildRegionCard(entry.key, entry.value, total),
          ),
        ],
      ),
    );
  }

  /// Build population statistics tab
  Widget _buildPopulationStatistics() {
    final countries = controller.countries;
    countries.sort((a, b) => b.population.compareTo(a.population));

    final top10 = countries.take(10).toList();
    final totalPopulation = countries.fold<int>(
      0,
      (sum, country) => sum + country.population,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Total population card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.people, size: 48, color: Colors.green),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'World Population',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      Text(
                        _formatPopulation(totalPopulation),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Top 10 most populous countries
          const Text(
            'Most Populous Countries',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 300,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: top10.first.population.toDouble() * 1.1,
                    barTouchData: BarTouchData(enabled: false),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            if (value.toInt() < top10.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  top10[value.toInt()].name.common.length > 8
                                      ? '${top10[value.toInt()].name.common.substring(0, 8)}...'
                                      : top10[value.toInt()].name.common,
                                  style: const TextStyle(fontSize: 10),
                                ),
                              );
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              _formatPopulationShort(value.toInt()),
                              style: const TextStyle(fontSize: 10),
                            );
                          },
                          reservedSize: 40,
                        ),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: top10.asMap().entries.map((entry) {
                      return BarChartGroupData(
                        x: entry.key,
                        barRods: [
                          BarChartRodData(
                            toY: entry.value.population.toDouble(),
                            color: Colors
                                .blue[300 + (entry.key * 50).clamp(0, 400)],
                            width: 20,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Population ranges
          _buildPopulationRanges(countries),
        ],
      ),
    );
  }

  /// Build geography statistics tab
  Widget _buildGeographyStatistics() {
    final countries = controller.countries
        .where((c) => c.area != null)
        .toList();
    countries.sort((a, b) => b.area!.compareTo(a.area!));

    final largest10 = countries.take(10).toList();
    final smallest10 = countries.reversed.take(10).toList().reversed.toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Geography overview
          Row(
            children: [
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.landscape,
                          size: 40,
                          color: Colors.orange,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Largest',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          largest10.first.name.common,
                          style: const TextStyle(fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          '${largest10.first.area!.toStringAsFixed(0)} km²',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.crop_free,
                          size: 40,
                          color: Colors.purple,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Smallest',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          smallest10.first.name.common,
                          style: const TextStyle(fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          '${smallest10.first.area!.toStringAsFixed(1)} km²',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Largest countries
          const Text(
            'Largest Countries by Area',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...largest10
              .take(5)
              .map(
                (country) => Card(
                  child: ListTile(
                    leading: SizedBox(
                      width: 40,
                      height: 30,
                      child: Image.network(
                        country.flags.png,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.flag, size: 20),
                      ),
                    ),
                    title: Text(country.name.common),
                    subtitle: Text('${country.area!.toStringAsFixed(0)} km²'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () =>
                        Get.to(() => CountryDetailScreen(country: country)),
                  ),
                ),
              ),

          const SizedBox(height: 24),

          // Smallest countries
          const Text(
            'Smallest Countries by Area',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...smallest10
              .take(5)
              .map(
                (country) => Card(
                  child: ListTile(
                    leading: SizedBox(
                      width: 40,
                      height: 30,
                      child: Image.network(
                        country.flags.png,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.flag, size: 20),
                      ),
                    ),
                    title: Text(country.name.common),
                    subtitle: Text('${country.area!.toStringAsFixed(2)} km²'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () =>
                        Get.to(() => CountryDetailScreen(country: country)),
                  ),
                ),
              ),
        ],
      ),
    );
  }

  /// Build records statistics tab
  Widget _buildRecordsStatistics() {
    final countries = controller.countries;

    // Find records
    final mostPopulated = countries.reduce(
      (a, b) => a.population > b.population ? a : b,
    );
    final leastPopulated = countries.reduce(
      (a, b) => a.population < b.population ? a : b,
    );
    final mostBorders = countries.reduce(
      (a, b) => a.borders.length > b.borders.length ? a : b,
    );
    final mostLanguages = countries.reduce(
      (a, b) => a.languages.length > b.languages.length ? a : b,
    );
    final mostTimezones = countries.reduce(
      (a, b) => a.timezones.length > b.timezones.length ? a : b,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'World Records',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          _buildRecordCard(
            'Most Populated',
            mostPopulated.name.common,
            _formatPopulation(mostPopulated.population),
            Icons.people,
            Colors.blue,
            mostPopulated,
          ),

          _buildRecordCard(
            'Least Populated',
            leastPopulated.name.common,
            _formatPopulation(leastPopulated.population),
            Icons.person,
            Colors.green,
            leastPopulated,
          ),

          _buildRecordCard(
            'Most Borders',
            mostBorders.name.common,
            '${mostBorders.borders.length} borders',
            Icons.location_on,
            Colors.orange,
            mostBorders,
          ),

          _buildRecordCard(
            'Most Languages',
            mostLanguages.name.common,
            '${mostLanguages.languages.length} languages',
            Icons.translate,
            Colors.purple,
            mostLanguages,
          ),

          _buildRecordCard(
            'Most Timezones',
            mostTimezones.name.common,
            '${mostTimezones.timezones.length} timezones',
            Icons.access_time,
            Colors.red,
            mostTimezones,
          ),

          const SizedBox(height: 24),

          // Fun facts
          const Text(
            'Fun Facts',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          _buildFunFactCard(
            'Independent Countries',
            '${countries.where((c) => c.independent).length}',
            'out of ${countries.length} total countries',
            Icons.flag,
          ),

          _buildFunFactCard(
            'UN Members',
            '${countries.where((c) => c.unMember).length}',
            'countries are UN members',
            Icons.public,
          ),

          _buildFunFactCard(
            'Unique Currencies',
            '${countries.expand((c) => c.currencies.keys).toSet().length}',
            'different currencies worldwide',
            Icons.monetization_on,
          ),
        ],
      ),
    );
  }

  /// Build pie chart sections
  List<PieChartSectionData> _buildPieChartSections(
    Map<String, int> regionCounts,
  ) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
    ];

    int index = 0;
    return regionCounts.entries.map((entry) {
      final color = colors[index % colors.length];
      index++;

      return PieChartSectionData(
        color: color,
        value: entry.value.toDouble(),
        title: '${entry.value}',
        radius: 80,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  /// Build region legend
  Widget _buildRegionLegend(Map<String, int> regionCounts) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
    ];

    int index = 0;
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: regionCounts.entries.map((entry) {
        final color = colors[index % colors.length];
        index++;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(entry.key),
          ],
        );
      }).toList(),
    );
  }

  /// Build region card
  Widget _buildRegionCard(String region, int count, int total) {
    final percentage = (count / total * 100).toStringAsFixed(1);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(region),
        subtitle: Text('$percentage% of all countries'),
        trailing: Text(
          count.toString(),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  /// Build population ranges
  Widget _buildPopulationRanges(List<Country> countries) {
    final ranges = {
      'Under 1M': countries.where((c) => c.population < 1000000).length,
      '1M - 10M': countries
          .where((c) => c.population >= 1000000 && c.population < 10000000)
          .length,
      '10M - 100M': countries
          .where((c) => c.population >= 10000000 && c.population < 100000000)
          .length,
      'Over 100M': countries.where((c) => c.population >= 100000000).length,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Population Ranges',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...ranges.entries.map(
          (entry) => Card(
            child: ListTile(
              title: Text(entry.key),
              trailing: Text(
                '${entry.value} countries',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Build record card
  Widget _buildRecordCard(
    String title,
    String country,
    String value,
    IconData icon,
    Color color,
    Country countryData,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => Get.to(() => CountryDetailScreen(country: countryData)),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    Text(
                      country,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 14,
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  /// Build fun fact card
  Widget _buildFunFactCard(
    String title,
    String number,
    String description,
    IconData icon,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 32, color: Colors.blue),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  RichText(
                    text: TextSpan(
                      style: DefaultTextStyle.of(context).style,
                      children: [
                        TextSpan(
                          text: number,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        TextSpan(
                          text: ' $description',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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

  /// Format population short
  String _formatPopulationShort(int population) {
    if (population >= 1000000000) {
      return '${(population / 1000000000).toStringAsFixed(0)}B';
    } else if (population >= 1000000) {
      return '${(population / 1000000).toStringAsFixed(0)}M';
    } else {
      return '${(population / 1000).toStringAsFixed(0)}K';
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
