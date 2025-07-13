// providers/order_provider.dart - VERSION COMPLÈTE MISE À JOUR
import 'package:flutter/foundation.dart';
import '../models/order_model.dart';
import '../services/order_service.dart';

class OrderProvider with ChangeNotifier {
  final OrderService _orderService = OrderService();

  List<Order> _allOrders = [];        // Toutes les commandes
  List<Order> _filteredOrders = [];   // Commandes filtrées
  List<Order> _todaysOrders = [];     // 🔥 NOUVEAU : Commandes d'aujourd'hui
  Order? _selectedOrder;
  bool _isLoading = false;
  String? _errorMessage;
  String? _currentStatusFilter;

  // Statistiques
  int _totalOrders = 0;
  int _pendingOrders = 0;
  int _confirmedOrders = 0;
  double _totalRevenue = 0.0;

  // Getters
  List<Order> get orders => _filteredOrders;
  List<Order> get allOrders => _allOrders;
  List<Order> get todaysOrders => _todaysOrders;  // 🔥 NOUVEAU
  Order? get selectedOrder => _selectedOrder;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get currentStatusFilter => _currentStatusFilter;
  
  // Statistiques
  int get totalOrders => _totalOrders;
  int get pendingOrders => _pendingOrders;
  int get confirmedOrders => _confirmedOrders;
  double get totalRevenue => _totalRevenue;

  // 🔥 NOUVELLE MÉTHODE : Charger les commandes d'aujourd'hui
  Future<void> loadTodaysOrders() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _orderService.getTodaysOrders();
      
      if (response['success'] == true) {
        final ordersData = response['data'] as List;
        print('📦 Commandes d\'aujourd\'hui reçues: ${ordersData.length}');
        
        final List<Order> todaysOrdersList = [];
        
        for (var orderJson in ordersData) {
          try {
            final order = Order.fromJson(orderJson);
            todaysOrdersList.add(order);
            print('✅ Commande ${order.id} d\'aujourd\'hui parsée - Statut: "${order.statut}"');
          } catch (e) {
            print('❌ Erreur parsing commande d\'aujourd\'hui: $e');
          }
        }
        
        _todaysOrders = todaysOrdersList;
        print('🎉 ${_todaysOrders.length} commandes d\'aujourd\'hui chargées');
        
      } else {
        _errorMessage = response['message'] ?? 'Erreur lors du chargement';
      }
    } catch (e) {
      _errorMessage = 'Erreur de connexion: $e';
      print('❌ Erreur chargement commandes d\'aujourd\'hui: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Charger les commandes avec filtrage côté client
  Future<void> loadOrders({String? status, bool refresh = false}) async {
    if (_isLoading && !refresh) return;

    print('🎯 PROVIDER loadOrders appelé avec status: "$status"');
    print('🎯 AVANT FILTRAGE - Provider orders: ${_filteredOrders.length}');

    _isLoading = true;
    _errorMessage = null;
    _currentStatusFilter = status;
    
    if (refresh) {
      _allOrders.clear();
      _filteredOrders.clear();
    }
    
    notifyListeners();

    try {
      final response = await _orderService.getOrders(status: status);
      
      if (response['success'] == true) {
        final ordersData = response['data'] as List;
        print('📦 Tentative de parsing de ${ordersData.length} commandes');
        
        final List<Order> successfullyParsedOrders = [];
        
        for (int i = 0; i < ordersData.length; i++) {
          try {
            final orderJson = ordersData[i];
            print('📦 Parsing commande ${i + 1}/${ordersData.length} (ID: ${orderJson['id']})');
            
            final order = Order.fromJson(orderJson);
            successfullyParsedOrders.add(order);
            print('✅ Commande ${order.id} parsée avec succès - Statut: "${order.statut}"');
            
          } catch (e) {
            print('❌ Erreur parsing commande ${i + 1}: $e');
            continue;
          }
        }
        
        if (status == null) {
          _allOrders = successfullyParsedOrders;
          _filteredOrders = List.from(_allOrders);
        } else {
          _filteredOrders = successfullyParsedOrders;
          if (_allOrders.isEmpty) {
            _allOrders = successfullyParsedOrders;
          }
        }
        
        print('🎉 ${_filteredOrders.length} commandes chargées avec succès');
        print('🎯 APRÈS FILTRAGE - Provider orders: ${_filteredOrders.length}');
        
        print('🎯 COMMANDES DANS PROVIDER:');
        for (var order in _filteredOrders) {
          print('   📦 Commande #${order.id} - Statut: "${order.statut}"');
        }
        
        _calculateLocalStats();
        
      } else {
        _errorMessage = response['message'] ?? 'Erreur lors du chargement';
      }
    } catch (e) {
      _errorMessage = 'Erreur de connexion: $e';
      print('❌ Erreur générale dans loadOrders: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Filtrer les commandes déjà chargées
  void filterOrders(String? status) {
    print('🔍 FILTRAGE LOCAL: status="$status"');
    print('🔍 Commandes disponibles: ${_allOrders.length}');
    
    _currentStatusFilter = status;
    
    if (status == null || status.isEmpty) {
      _filteredOrders = List.from(_allOrders);
    } else {
      _filteredOrders = _allOrders.where((order) => order.statut == status).toList();
    }
    
    print('🔍 Commandes après filtrage: ${_filteredOrders.length}');
    for (var order in _filteredOrders) {
      print('   ✅ Commande #${order.id} - Statut: "${order.statut}"');
    }
    
    notifyListeners();
  }

  // Charger les statistiques
  Future<void> loadOrderStats() async {
    try {
      final response = await _orderService.getOrderStats();
      
      if (response['success'] == true) {
        final data = response['data'];
        _totalOrders = data['total_orders'] ?? _allOrders.length;
        _pendingOrders = data['pending_orders'] ?? _allOrders.where((o) => o.statut == 'en_attente').length;
        _confirmedOrders = data['confirmed_orders'] ?? _allOrders.where((o) => o.statut == 'confirmee').length;
        _totalRevenue = (data['total_revenue'] ?? 0.0).toDouble();
        notifyListeners();
      } else {
        _calculateLocalStats();
      }
    } catch (e) {
      print('❌ Erreur chargement statistiques: $e');
      _calculateLocalStats();
    }
  }

  // Mettre à jour le statut d'une commande
  Future<bool> updateOrderStatus(int orderId, String newStatus) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final response = await _orderService.updateOrderStatus(orderId, newStatus);
      
      if (response['success'] == true) {
        // Mettre à jour dans _allOrders
        final allOrderIndex = _allOrders.indexWhere((order) => order.id == orderId);
        if (allOrderIndex != -1) {
          try {
            _allOrders[allOrderIndex] = Order.fromJson(response['data']);
          } catch (e) {
            print('❌ Erreur parsing commande mise à jour: $e');
            final oldOrder = _allOrders[allOrderIndex];
            _allOrders[allOrderIndex] = Order(
              id: oldOrder.id,
              clientId: oldOrder.clientId,
              dateCommande: oldOrder.dateCommande,
              montantTotal: oldOrder.montantTotal,
              statut: newStatus,
              details: oldOrder.details,
              clientNom: oldOrder.clientNom,
              nombreArticles: oldOrder.nombreArticles,
            );
          }
        }
        
        // Mettre à jour dans _filteredOrders
        final filteredOrderIndex = _filteredOrders.indexWhere((order) => order.id == orderId);
        if (filteredOrderIndex != -1) {
          try {
            _filteredOrders[filteredOrderIndex] = Order.fromJson(response['data']);
          } catch (e) {
            final oldOrder = _filteredOrders[filteredOrderIndex];
            _filteredOrders[filteredOrderIndex] = Order(
              id: oldOrder.id,
              clientId: oldOrder.clientId,
              dateCommande: oldOrder.dateCommande,
              montantTotal: oldOrder.montantTotal,
              statut: newStatus,
              details: oldOrder.details,
              clientNom: oldOrder.clientNom,
              nombreArticles: oldOrder.nombreArticles,
            );
          }
        }

        // 🔥 NOUVEAU : Mettre à jour dans _todaysOrders si nécessaire
        final todaysOrderIndex = _todaysOrders.indexWhere((order) => order.id == orderId);
        if (todaysOrderIndex != -1) {
          try {
            _todaysOrders[todaysOrderIndex] = Order.fromJson(response['data']);
          } catch (e) {
            final oldOrder = _todaysOrders[todaysOrderIndex];
            _todaysOrders[todaysOrderIndex] = Order(
              id: oldOrder.id,
              clientId: oldOrder.clientId,
              dateCommande: oldOrder.dateCommande,
              montantTotal: oldOrder.montantTotal,
              statut: newStatus,
              details: oldOrder.details,
              clientNom: oldOrder.clientNom,
              nombreArticles: oldOrder.nombreArticles,
            );
          }
        }
        
        // Mettre à jour la commande sélectionnée si nécessaire
        if (_selectedOrder?.id == orderId) {
          try {
            _selectedOrder = Order.fromJson(response['data']);
          } catch (e) {
            if (_selectedOrder != null) {
              _selectedOrder = Order(
                id: _selectedOrder!.id,
                clientId: _selectedOrder!.clientId,
                dateCommande: _selectedOrder!.dateCommande,
                montantTotal: _selectedOrder!.montantTotal,
                statut: newStatus,
                details: _selectedOrder!.details,
                clientNom: _selectedOrder!.clientNom,
                nombreArticles: _selectedOrder!.nombreArticles,
              );
            }
          }
        }
        
        if (_currentStatusFilter != null) {
          filterOrders(_currentStatusFilter);
        }
        
        _calculateLocalStats();
        notifyListeners();
        return true;
      } else {
        _errorMessage = response['message'] ?? 'Erreur lors de la mise à jour';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Erreur de connexion: $e';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Rafraîchir les commandes
  Future<void> refreshOrders() async {
    await loadOrders(status: _currentStatusFilter, refresh: true);
  }

  // 🔥 NOUVELLE MÉTHODE : Rafraîchir les commandes d'aujourd'hui
  Future<void> refreshTodaysOrders() async {
    await loadTodaysOrders();
  }

  void selectOrder(Order? order) {
    _selectedOrder = order;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Calculs avec les vrais statuts
  void _calculateLocalStats() {
    final ordersToCalculate = _allOrders.isNotEmpty ? _allOrders : _filteredOrders;
    
    _totalOrders = ordersToCalculate.length;
    _pendingOrders = ordersToCalculate.where((order) => order.statut == 'en_attente').length;
    _confirmedOrders = ordersToCalculate.where((order) => order.statut == 'confirmee').length;
    _totalRevenue = ordersToCalculate
        .where((order) => order.statut != 'annulee')
        .fold(0.0, (sum, order) => sum + order.montantTotal);
        
    print('📊 Stats calculées: Total=${_totalOrders}, Pending=${_pendingOrders}, Confirmed=${_confirmedOrders}');
  }

  // Méthodes utilitaires avec les bons statuts
  List<Order> getOrdersByStatus(String status) {
    return _allOrders.where((order) => order.statut == status).toList();
  }

  // Commandes par statut avec les vrais statuts
  List<Order> get pendingOrdersList => 
      _allOrders.where((order) => order.statut == 'en_attente').toList();
  
  List<Order> get confirmedOrdersList => 
      _allOrders.where((order) => order.statut == 'confirmee').toList();
  
  List<Order> get shippedOrdersList => 
      _allOrders.where((order) => order.statut == 'expediee').toList();
  
  List<Order> get deliveredOrdersList => 
      _allOrders.where((order) => order.statut == 'livree').toList();
  
  List<Order> get cancelledOrdersList => 
      _allOrders.where((order) => order.statut == 'annulee').toList();
}