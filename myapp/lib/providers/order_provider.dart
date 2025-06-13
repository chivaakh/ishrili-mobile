// providers/order_provider.dart - NOUVEAU FICHIER
import 'package:flutter/foundation.dart';
import '../models/order_model.dart';
import '../services/order_service.dart';

class OrderProvider with ChangeNotifier {
  final OrderService _orderService = OrderService();

  List<Order> _orders = [];
  Order? _selectedOrder;
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;
  String? _currentStatus;
  String? _currentSearch;
  String? _errorMessage;

  // Statistiques
  int _totalOrders = 0;
  int _pendingOrders = 0;
  int _confirmedOrders = 0;
  int _deliveredOrders = 0;
  double _totalRevenue = 0.0;

  // Getters
  List<Order> get orders => _orders;
  Order? get selectedOrder => _selectedOrder;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  String? get errorMessage => _errorMessage;
  
  // Stats getters
  int get totalOrders => _totalOrders;
  int get pendingOrders => _pendingOrders;
  int get confirmedOrders => _confirmedOrders;
  int get deliveredOrders => _deliveredOrders;
  double get totalRevenue => _totalRevenue;

  /// Charger les commandes
  Future<void> loadOrders({
    String? status,
    String? search,
    bool refresh = false,
  }) async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;

    if (refresh || status != _currentStatus || search != _currentSearch) {
      _orders.clear();
      _currentPage = 1;
      _hasMore = true;
      _currentStatus = status;
      _currentSearch = search;
    }

    notifyListeners();

    try {
      final response = await _orderService.getOrders(
        page: _currentPage,
        status: status,
        search: search,
      );

      final newOrders = response['results'] as List<Order>;
      
      if (_currentPage == 1) {
        _orders = newOrders;
      } else {
        _orders.addAll(newOrders);
      }

      _hasMore = response['hasMore'] ?? false;
      _currentPage++;

      // Mettre à jour les statistiques
      _updateLocalStats();

    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Erreur chargement commandes: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Mettre à jour le statut d'une commande
  Future<bool> updateOrderStatus(int orderId, String newStatus) async {
    try {
      _isLoading = true;
      notifyListeners();

      final updatedOrder = await _orderService.updateOrderStatus(orderId, newStatus);

      // Mettre à jour dans la liste locale
      final index = _orders.indexWhere((order) => order.id == orderId);
      if (index != -1) {
        _orders[index] = updatedOrder;
        
        // Mettre à jour les stats localement
        _updateLocalStats();
        notifyListeners();
      }
      
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Erreur mise à jour statut: $e');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Charger les statistiques
  Future<void> loadOrderStats() async {
    try {
      // Pour l'instant, calculer à partir des commandes locales
      _updateLocalStats();
      
      // TODO: Connecter à l'API pour les vraies stats
      // final stats = await _orderService.getOrderStats();
      // _totalOrders = stats['total_orders'] ?? 0;
      // etc...
      
      notifyListeners();
    } catch (e) {
      debugPrint('Erreur chargement stats: $e');
    }
  }

  /// Mettre à jour les statistiques locales
  void _updateLocalStats() {
    _totalOrders = _orders.length;
    _pendingOrders = _orders.where((o) => o.statut == 'en_attente').length;
    _confirmedOrders = _orders.where((o) => o.statut == 'confirme').length;
    _deliveredOrders = _orders.where((o) => o.statut == 'livre').length;
    _totalRevenue = _orders.fold(0.0, (sum, order) => sum + order.montantTotal);
  }

  /// Sélectionner une commande
  void selectOrder(Order order) {
    _selectedOrder = order;
    notifyListeners();
  }

  /// Rafraîchir les commandes
  Future<void> refreshOrders() async {
    await loadOrders(
      status: _currentStatus,
      search: _currentSearch,
      refresh: true,
    );
  }

  /// Clear les erreurs
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}