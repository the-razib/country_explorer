import 'package:get/get.dart';

/// Achievement data model
class Achievement {
  final String id;
  final String title;
  final String description;
  final String iconName;
  final int requiredCount;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.iconName,
    required this.requiredCount,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  Achievement copyWith({
    String? id,
    String? title,
    String? description,
    String? iconName,
    int? requiredCount,
    bool? isUnlocked,
    DateTime? unlockedAt,
  }) {
    return Achievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      iconName: iconName ?? this.iconName,
      requiredCount: requiredCount ?? this.requiredCount,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'iconName': iconName,
      'requiredCount': requiredCount,
      'isUnlocked': isUnlocked,
      'unlockedAt': unlockedAt?.millisecondsSinceEpoch,
    };
  }

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      iconName: json['iconName'],
      requiredCount: json['requiredCount'],
      isUnlocked: json['isUnlocked'] ?? false,
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['unlockedAt'])
          : null,
    );
  }
}

/// Achievement controller for managing user achievements
class AchievementController extends GetxController {
  // Observable achievements list
  final _achievements = <Achievement>[].obs;
  final _unlockedCount = 0.obs;

  // User statistics
  final _countriesViewed = <String>{}.obs;
  final _favoritesAdded = 0.obs;
  final _quizesCompleted = 0.obs;
  final _comparisonsPerformed = 0.obs;
  final _searchesPerformed = 0.obs;
  final _statisticsViewed = 0.obs;

  // Getters
  List<Achievement> get achievements => _achievements;
  int get unlockedCount => _unlockedCount.value;
  List<Achievement> get unlockedAchievements =>
      _achievements.where((a) => a.isUnlocked).toList();
  double get completionPercentage => _achievements.isEmpty
      ? 0.0
      : (_unlockedCount.value / _achievements.length);

  @override
  void onInit() {
    super.onInit();
    _initializeAchievements();
    _loadUserProgress();
  }

  /// Initialize default achievements
  void _initializeAchievements() {
    _achievements.addAll([
      Achievement(
        id: 'first_country',
        title: 'Explorer',
        description: 'View your first country details',
        iconName: 'explore',
        requiredCount: 1,
      ),
      Achievement(
        id: 'country_collector',
        title: 'Country Collector',
        description: 'View details of 10 different countries',
        iconName: 'collections',
        requiredCount: 10,
      ),
      Achievement(
        id: 'world_traveler',
        title: 'World Traveler',
        description: 'View details of 50 different countries',
        iconName: 'flight',
        requiredCount: 50,
      ),
      Achievement(
        id: 'geography_master',
        title: 'Geography Master',
        description: 'View all 250 countries',
        iconName: 'public',
        requiredCount: 250,
      ),
      Achievement(
        id: 'first_favorite',
        title: 'Favorite Finder',
        description: 'Add your first country to favorites',
        iconName: 'favorite',
        requiredCount: 1,
      ),
      Achievement(
        id: 'favorite_collector',
        title: 'Favorite Collector',
        description: 'Add 10 countries to favorites',
        iconName: 'favorite_border',
        requiredCount: 10,
      ),
      Achievement(
        id: 'quiz_novice',
        title: 'Quiz Novice',
        description: 'Complete your first quiz',
        iconName: 'quiz',
        requiredCount: 1,
      ),
      Achievement(
        id: 'quiz_expert',
        title: 'Quiz Expert',
        description: 'Complete 10 quizzes',
        iconName: 'school',
        requiredCount: 10,
      ),
      Achievement(
        id: 'comparison_analyst',
        title: 'Comparison Analyst',
        description: 'Compare 5 pairs of countries',
        iconName: 'compare_arrows',
        requiredCount: 5,
      ),
      Achievement(
        id: 'search_enthusiast',
        title: 'Search Enthusiast',
        description: 'Perform 25 searches',
        iconName: 'search',
        requiredCount: 25,
      ),
      Achievement(
        id: 'data_scientist',
        title: 'Data Scientist',
        description: 'View statistics dashboard 5 times',
        iconName: 'analytics',
        requiredCount: 5,
      ),
      Achievement(
        id: 'dedication',
        title: 'Dedication',
        description: 'Use the app for 7 consecutive days',
        iconName: 'event_available',
        requiredCount: 7,
      ),
    ]);

    _unlockedCount.value = _achievements.where((a) => a.isUnlocked).length;
  }

  /// Load user progress from storage
  Future<void> _loadUserProgress() async {
    try {
      // Load achievements state
      final achievementsData = await _getAchievementsFromStorage();
      if (achievementsData.isNotEmpty) {
        for (int i = 0; i < _achievements.length; i++) {
          final achievementData = achievementsData.firstWhere(
            (data) => data['id'] == _achievements[i].id,
            orElse: () => <String, dynamic>{},
          );

          if (achievementData.isNotEmpty) {
            _achievements[i] = Achievement.fromJson(achievementData);
          }
        }
        _unlockedCount.value = _achievements.where((a) => a.isUnlocked).length;
      }

      // Load user statistics
      _countriesViewed.addAll(await _getCountriesViewedFromStorage());
      _favoritesAdded.value = await _getFavoritesCountFromStorage();
      _quizesCompleted.value = await _getQuizCountFromStorage();
      _comparisonsPerformed.value = await _getComparisonCountFromStorage();
      _searchesPerformed.value = await _getSearchCountFromStorage();
      _statisticsViewed.value = await _getStatisticsCountFromStorage();
    } catch (e) {
      // Handle loading error silently
    }
  }

  /// Record country view
  Future<void> recordCountryView(String countryName) async {
    if (!_countriesViewed.contains(countryName)) {
      _countriesViewed.add(countryName);
      await _saveCountriesViewedToStorage();

      // Check achievements
      await _checkAchievement('first_country', 1);
      await _checkAchievement('country_collector', 10);
      await _checkAchievement('world_traveler', 50);
      await _checkAchievement('geography_master', 250);
    }
  }

  /// Record favorite addition
  Future<void> recordFavoriteAdded() async {
    _favoritesAdded.value++;
    await _saveFavoritesCountToStorage();

    // Check achievements
    await _checkAchievement('first_favorite', 1);
    await _checkAchievement('favorite_collector', 10);
  }

  /// Record favorite removal
  Future<void> recordFavoriteRemoved() async {
    if (_favoritesAdded.value > 0) {
      _favoritesAdded.value--;
      await _saveFavoritesCountToStorage();
    }
  }

  /// Record quiz completion
  Future<void> recordQuizCompleted() async {
    _quizesCompleted.value++;
    await _saveQuizCountToStorage();

    // Check achievements
    await _checkAchievement('quiz_novice', 1);
    await _checkAchievement('quiz_expert', 10);
  }

  /// Record comparison performed
  Future<void> recordComparison() async {
    _comparisonsPerformed.value++;
    await _saveComparisonCountToStorage();

    // Check achievements
    await _checkAchievement('comparison_analyst', 5);
  }

  /// Record search performed
  Future<void> recordSearch() async {
    _searchesPerformed.value++;
    await _saveSearchCountToStorage();

    // Check achievements
    await _checkAchievement('search_enthusiast', 25);
  }

  /// Record statistics view
  Future<void> recordStatisticsView() async {
    _statisticsViewed.value++;
    await _saveStatisticsCountToStorage();

    // Check achievements
    await _checkAchievement('data_scientist', 5);
  }

  /// Check and unlock achievement
  Future<void> _checkAchievement(String achievementId, int targetCount) async {
    final index = _achievements.indexWhere((a) => a.id == achievementId);
    if (index == -1 || _achievements[index].isUnlocked) return;

    int currentCount = 0;
    switch (achievementId) {
      case 'first_country':
      case 'country_collector':
      case 'world_traveler':
      case 'geography_master':
        currentCount = _countriesViewed.length;
        break;
      case 'first_favorite':
      case 'favorite_collector':
        currentCount = _favoritesAdded.value;
        break;
      case 'quiz_novice':
      case 'quiz_expert':
        currentCount = _quizesCompleted.value;
        break;
      case 'comparison_analyst':
        currentCount = _comparisonsPerformed.value;
        break;
      case 'search_enthusiast':
        currentCount = _searchesPerformed.value;
        break;
      case 'data_scientist':
        currentCount = _statisticsViewed.value;
        break;
    }

    if (currentCount >= targetCount) {
      _achievements[index] = _achievements[index].copyWith(
        isUnlocked: true,
        unlockedAt: DateTime.now(),
      );
      _unlockedCount.value++;

      // Save updated achievements
      await _saveAchievementsToStorage();

      // Show achievement notification
      _showAchievementNotification(_achievements[index]);
    }
  }

  /// Show achievement notification
  void _showAchievementNotification(Achievement achievement) {
    Get.snackbar(
      '🏆 Achievement Unlocked!',
      achievement.title,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Get.theme.primaryColor,
      colorText: Get.theme.colorScheme.onPrimary,
      duration: const Duration(seconds: 3),
    );
  }

  /// Reset all achievements (for testing)
  Future<void> resetAchievements() async {
    for (int i = 0; i < _achievements.length; i++) {
      _achievements[i] = _achievements[i].copyWith(
        isUnlocked: false,
        unlockedAt: null,
      );
    }
    _unlockedCount.value = 0;

    _countriesViewed.clear();
    _favoritesAdded.value = 0;
    _quizesCompleted.value = 0;
    _comparisonsPerformed.value = 0;
    _searchesPerformed.value = 0;
    _statisticsViewed.value = 0;

    await _saveAchievementsToStorage();
    await _saveAllStatsToStorage();
  }

  // Storage helper methods
  Future<List<Map<String, dynamic>>> _getAchievementsFromStorage() async {
    // For now, return empty list - will be implemented when storage service supports it
    return [];
  }

  Future<void> _saveAchievementsToStorage() async {
    // For now, do nothing - will be implemented when storage service supports it
  }

  Future<Set<String>> _getCountriesViewedFromStorage() async {
    // For now, return empty set - will be implemented when storage service supports it
    return <String>{};
  }

  Future<void> _saveCountriesViewedToStorage() async {
    // For now, do nothing - will be implemented when storage service supports it
  }

  Future<int> _getFavoritesCountFromStorage() async {
    return 0;
  }

  Future<void> _saveFavoritesCountToStorage() async {
    // For now, do nothing
  }

  Future<int> _getQuizCountFromStorage() async {
    return 0;
  }

  Future<void> _saveQuizCountToStorage() async {
    // For now, do nothing
  }

  Future<int> _getComparisonCountFromStorage() async {
    return 0;
  }

  Future<void> _saveComparisonCountToStorage() async {
    // For now, do nothing
  }

  Future<int> _getSearchCountFromStorage() async {
    return 0;
  }

  Future<void> _saveSearchCountToStorage() async {
    // For now, do nothing
  }

  Future<int> _getStatisticsCountFromStorage() async {
    return 0;
  }

  Future<void> _saveStatisticsCountToStorage() async {
    // For now, do nothing
  }

  Future<void> _saveAllStatsToStorage() async {
    await _saveCountriesViewedToStorage();
    await _saveFavoritesCountToStorage();
    await _saveQuizCountToStorage();
    await _saveComparisonCountToStorage();
    await _saveSearchCountToStorage();
    await _saveStatisticsCountToStorage();
  }
}
