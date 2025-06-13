// providers/vendor_provider.dart - Créez ce fichier
import 'package:flutter/foundation.dart';

class VendorProvider with ChangeNotifier {
  // Statistiques vendeur
  int _totalProducts = 0;
  int _totalOrders = 0;
  double _totalRevenue = 0.0;
  int _pendingOrders = 0;

  // Getters
  int get totalProducts => _totalProducts;
  int get totalOrders => _totalOrders;
  double get totalRevenue => _totalRevenue;
  int get pendingOrders => _pendingOrders;

  // Charger les statistiques
  Future<void> loadStatistics({required bool refresh}) async {
    // TODO: Connecter à votre API pour récupérer les vraies stats
    // Pour l'instant, on simule avec des données
    _totalProducts = 2; // Vos produits existants
    _totalOrders = 15;
    _totalRevenue = 2850.0;
    _pendingOrders = 3;
    notifyListeners();
  }

  // Aujourd'hui pour tests
  String get todayDate => DateTime.now().toString().split(' ')[0];
}
