import 'package:hive/hive.dart';

part 'country_model.g.dart';

@HiveType(typeId: 0)
class Country extends HiveObject {
  @HiveField(0)
  final CountryName name;
  
  @HiveField(1)
  final List<String> capital;
  
  @HiveField(2)
  final int population;
  
  @HiveField(3)
  final String region;
  
  @HiveField(4)
  final String subregion;
  
  @HiveField(5)
  final double? area;
  
  @HiveField(6)
  final List<String> borders;
  
  @HiveField(7)
  final Map<String, String> languages;
  
  @HiveField(8)
  final Map<String, Currency> currencies;
  
  @HiveField(9)
  final List<String> timezones;
  
  @HiveField(10)
  final CountryFlags flags;
  
  @HiveField(11)
  final List<double>? latlng;
  
  @HiveField(12)
  final bool independent;
  
  @HiveField(13)
  final bool unMember;
  
  @HiveField(14)
  final String? fifa;

  Country({
    required this.name,
    required this.capital,
    required this.population,
    required this.region,
    required this.subregion,
    this.area,
    required this.borders,
    required this.languages,
    required this.currencies,
    required this.timezones,
    required this.flags,
    this.latlng,
    required this.independent,
    required this.unMember,
    this.fifa,
  });

  /// Create Country from JSON response
  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      name: CountryName.fromJson(json['name'] ?? {}),
      capital: List<String>.from(json['capital'] ?? []),
      population: json['population'] ?? 0,
      region: json['region'] ?? '',
      subregion: json['subregion'] ?? '',
      area: json['area']?.toDouble(),
      borders: List<String>.from(json['borders'] ?? []),
      languages: _parseLanguages(json['languages']),
      currencies: _parseCurrencies(json['currencies']),
      timezones: List<String>.from(json['timezones'] ?? []),
      flags: CountryFlags.fromJson(json['flags'] ?? {}),
      latlng: json['latlng'] != null ? List<double>.from(json['latlng']) : null,
      independent: json['independent'] ?? false,
      unMember: json['unMember'] ?? false,
      fifa: json['fifa'],
    );
  }

  /// Helper method to parse languages from API response
  static Map<String, String> _parseLanguages(dynamic languages) {
    if (languages == null) return {};
    return Map<String, String>.from(languages);
  }

  /// Helper method to parse currencies from API response
  static Map<String, Currency> _parseCurrencies(dynamic currencies) {
    if (currencies == null) return {};
    final Map<String, Currency> result = {};
    currencies.forEach((key, value) {
      result[key] = Currency.fromJson(value);
    });
    return result;
  }

  /// Get formatted population string
  String get formattedPopulation {
    if (population >= 1000000) {
      return '${(population / 1000000).toStringAsFixed(1)}M';
    } else if (population >= 1000) {
      return '${(population / 1000).toStringAsFixed(0)}K';
    }
    return population.toString();
  }

  /// Get formatted area string
  String get formattedArea {
    if (area == null) return 'Unknown';
    if (area! >= 1000000) {
      return '${(area! / 1000000).toStringAsFixed(1)}M km²';
    } else if (area! >= 1000) {
      return '${(area! / 1000).toStringAsFixed(0)}K km²';
    }
    return '${area!.toStringAsFixed(0)} km²';
  }

  /// Get main currency
  Currency? get mainCurrency {
    if (currencies.isEmpty) return null;
    return currencies.values.first;
  }

  /// Get main language
  String get mainLanguage {
    if (languages.isEmpty) return 'Unknown';
    return languages.values.first;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Country && 
           other.name.common == name.common &&
           other.name.official == name.official;
  }

  @override
  int get hashCode => name.common.hashCode ^ name.official.hashCode;

  @override
  String toString() => 'Country(${name.common})';
}

@HiveType(typeId: 1)
class CountryName extends HiveObject {
  @HiveField(0)
  final String common;
  
  @HiveField(1)
  final String official;

  CountryName({
    required this.common,
    required this.official,
  });

  factory CountryName.fromJson(Map<String, dynamic> json) {
    return CountryName(
      common: json['common'] ?? '',
      official: json['official'] ?? '',
    );
  }

  @override
  String toString() => common;
}

@HiveType(typeId: 2)
class Currency extends HiveObject {
  @HiveField(0)
  final String name;
  
  @HiveField(1)
  final String symbol;

  Currency({
    required this.name,
    required this.symbol,
  });

  factory Currency.fromJson(Map<String, dynamic> json) {
    return Currency(
      name: json['name'] ?? '',
      symbol: json['symbol'] ?? '',
    );
  }

  @override
  String toString() => '$symbol $name';
}

@HiveType(typeId: 3)
class CountryFlags extends HiveObject {
  @HiveField(0)
  final String png;
  
  @HiveField(1)
  final String svg;
  
  @HiveField(2)
  final String alt;

  CountryFlags({
    required this.png,
    required this.svg,
    required this.alt,
  });

  factory CountryFlags.fromJson(Map<String, dynamic> json) {
    return CountryFlags(
      png: json['png'] ?? '',
      svg: json['svg'] ?? '',
      alt: json['alt'] ?? '',
    );
  }

  @override
  String toString() => png;
}
