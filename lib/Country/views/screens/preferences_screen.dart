import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/theme_controller.dart';
import '../../controllers/country_controller.dart';

/// User preferences and settings screen
class PreferencesScreen extends StatelessWidget {
  const PreferencesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final countryController = Get.find<CountryController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings & Preferences'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Theme Section
            _buildSectionHeader('Theme & Appearance'),
            _buildThemeSettings(themeController),

            const SizedBox(height: 32),

            // App Settings Section
            _buildSectionHeader('App Settings'),
            _buildAppSettings(countryController),

            const SizedBox(height: 32),

            // Data Management Section
            _buildSectionHeader('Data Management'),
            _buildDataSettings(countryController),

            const SizedBox(height: 32),

            // About Section
            _buildSectionHeader('About'),
            _buildAboutSection(),
          ],
        ),
      ),
    );
  }

  /// Build section header
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }

  /// Build theme settings section
  Widget _buildThemeSettings(ThemeController themeController) {
    return Column(
      children: [
        // Dark mode toggle
        Card(
          child: Obx(
            () => SwitchListTile(
              title: const Text('Dark Mode'),
              subtitle: Text(
                themeController.isDarkMode
                    ? 'Using dark theme'
                    : 'Using light theme',
              ),
              value: themeController.isDarkMode,
              onChanged: (_) => themeController.toggleDarkMode(),
              secondary: Icon(
                themeController.isDarkMode ? Icons.dark_mode : Icons.light_mode,
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Theme color selection
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Theme Color',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Obx(
                  () => Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: themeController.availableThemes.map((themeName) {
                      final color = themeController.getThemeColor(themeName);
                      final isSelected =
                          themeController.selectedTheme == themeName;

                      return GestureDetector(
                        onTap: () => themeController.changeTheme(themeName),
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: isSelected
                                ? Border.all(color: Colors.white, width: 3)
                                : null,
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: color.withOpacity(0.5),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    ),
                                  ]
                                : null,
                          ),
                          child: isSelected
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 30,
                                )
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 8),
                Obx(
                  () => Text(
                    themeController.getThemeDisplayName(
                      themeController.selectedTheme,
                    ),
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Font size slider
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Font Size',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Obx(
                  () => Column(
                    children: [
                      Slider(
                        value: themeController.fontSize,
                        min: 0.8,
                        max: 1.4,
                        divisions: 6,
                        label: '${(themeController.fontSize * 100).round()}%',
                        onChanged: themeController.changeFontSize,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Small',
                            style: TextStyle(
                              fontSize: 12 * themeController.fontSize,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            'Normal',
                            style: TextStyle(
                              fontSize: 14 * themeController.fontSize,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            'Large',
                            style: TextStyle(
                              fontSize: 16 * themeController.fontSize,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Build app settings section
  Widget _buildAppSettings(CountryController countryController) {
    return Column(
      children: [
        Card(
          child: ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Default View'),
            subtitle: const Text('Countries list view'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Navigate to view preferences
            },
          ),
        ),

        Card(
          child: ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notifications'),
            subtitle: const Text('App notifications and updates'),
            trailing: Switch(
              value: true,
              onChanged: (value) {
                // Handle notification toggle
              },
            ),
          ),
        ),

        Card(
          child: ListTile(
            leading: const Icon(Icons.offline_pin),
            title: const Text('Offline Mode'),
            subtitle: const Text('Cache data for offline use'),
            trailing: Switch(
              value: true,
              onChanged: (value) {
                // Handle offline mode toggle
              },
            ),
          ),
        ),
      ],
    );
  }

  /// Build data settings section
  Widget _buildDataSettings(CountryController countryController) {
    return Column(
      children: [
        Card(
          child: ListTile(
            leading: const Icon(Icons.refresh, color: Colors.blue),
            title: const Text('Refresh Data'),
            subtitle: const Text('Update countries information'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () async {
              Get.snackbar(
                'Refreshing',
                'Updating countries data...',
                snackPosition: SnackPosition.BOTTOM,
              );
              await countryController.refreshCountries();
              Get.snackbar(
                'Success',
                'Countries data updated successfully',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
            },
          ),
        ),

        Card(
          child: ListTile(
            leading: const Icon(Icons.clear_all, color: Colors.orange),
            title: const Text('Clear Search History'),
            subtitle: const Text('Remove all search history'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Get.dialog(
                AlertDialog(
                  title: const Text('Clear Search History'),
                  content: const Text(
                    'Are you sure you want to clear all search history?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () async {
                        // Clear search history
                        Get.back();
                        Get.snackbar(
                          'Cleared',
                          'Search history cleared successfully',
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      },
                      child: const Text('Clear'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        Card(
          child: ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text('Clear All Data'),
            subtitle: const Text('Reset app to initial state'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Get.dialog(
                AlertDialog(
                  title: const Text('Clear All Data'),
                  content: const Text(
                    'This will remove all favorites, settings, and cached data. '
                    'This action cannot be undone.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () async {
                        // Clear all data
                        Get.back();
                        Get.snackbar(
                          'Cleared',
                          'All app data cleared successfully',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                        );
                      },
                      child: const Text(
                        'Clear All',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Build about section
  Widget _buildAboutSection() {
    return Column(
      children: [
        Card(
          child: ListTile(
            leading: const Icon(Icons.info),
            title: const Text('App Version'),
            subtitle: const Text('1.0.0'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          ),
        ),

        Card(
          child: ListTile(
            leading: const Icon(Icons.code),
            title: const Text('Developer'),
            subtitle: const Text('Country Explorer Team'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          ),
        ),

        Card(
          child: ListTile(
            leading: const Icon(Icons.api),
            title: const Text('Data Source'),
            subtitle: const Text('REST Countries API'),
            trailing: const Icon(Icons.launch, size: 16),
            onTap: () {
              // Open REST Countries API website
            },
          ),
        ),

        Card(
          child: ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Help & Support'),
            subtitle: const Text('Get help and report issues'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Navigate to help screen
            },
          ),
        ),

        Card(
          child: ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Privacy Policy'),
            subtitle: const Text('How we handle your data'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Navigate to privacy policy
            },
          ),
        ),
      ],
    );
  }
}
