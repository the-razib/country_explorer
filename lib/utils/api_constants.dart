/// API constants for REST Countries API
class ApiConstants {
  // Base URL for REST Countries API
  static const String baseUrl = 'https://restcountries.com/v3.1';
  
  // Endpoints
  static const String allCountries = '$baseUrl/all';
  static const String countryByName = '$baseUrl/name';
  static const String countryByCode = '$baseUrl/alpha';
  static const String countryByRegion = '$baseUrl/region';
  static const String countryByCurrency = '$baseUrl/currency';
  static const String countryByLanguage = '$baseUrl/lang';
  
  // Field selections for API optimization
  static const String basicFields = 'name,capital,population,region,subregion,flags';
  static const String detailFields = 'name,capital,population,region,subregion,area,borders,languages,currencies,timezones,flags,coatOfArms,car,continents,gini,fifa,independent,unMember,latlng';
  
  // HTTP request timeouts
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 15);
  
  // Available regions for filtering
  static const List<String> regions = [
    'All',
    'Africa',
    'Americas', 
    'Asia',
    'Europe',
    'Oceania',
  ];
  
  // Available sort options
  static const List<String> sortOptions = [
    'Name A-Z',
    'Name Z-A',
    'Population High-Low',
    'Population Low-High',
    'Area Large-Small',
    'Area Small-Large',
  ];
}
