// config/api_config.dart
class ApiConfig {
  static const bool isDebug = true;
  
  static String get baseUrl {
    if (isDebug) {
      return 'http://10.0.2.2:8000/api';  // ← IMPORTANT : 10.0.2.2
    } else {
      return 'https://votre-domaine.com/api';
    }
  }

  static String get mediaUrl {
    if (isDebug) {
      return 'http://10.0.2.2:8000/media/';
    } else {
      return 'https://votre-domaine.com/media/';
    }
  }
  
  static const String products = '/produits/';
  static const String categories = '/categories/';
  static const String orders = '/commandes/';
  static const String notifications = '/notifications/';
  
  static const Duration timeout = Duration(seconds: 30);
}