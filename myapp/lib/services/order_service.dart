// services/order_service.dart - NOUVEAU FICHIER
import '../models/order_model.dart';
import 'api_service.dart';

class OrderService {
  final ApiService _apiService = ApiService();

  /// Récupérer toutes les commandes avec pagination
  Future<Map<String, dynamic>> getOrders({
    int page = 1,
    String? status,
    String? search,
  }) async {
    String endpoint = '/commandes/';
    
    List<String> params = [];
    params.add('page=$page');
    if (status != null && status.isNotEmpty) params.add('statut=$status');
    if (search != null && search.isNotEmpty) params.add('search=$search');
    
    if (params.isNotEmpty) {
      endpoint += '?${params.join('&')}';
    }
    
    try {
      final response = await _apiService.get(endpoint);
      
      return {
        'results': (response['results'] as List? ?? [])
            .map((json) => Order.fromJson(json))
            .toList(),
        'count': response['count'] ?? 0,
        'next': response['next'],
        'previous': response['previous'],
        'hasMore': response['next'] != null,
      };
    } catch (e) {
      throw Exception('Erreur lors du chargement des commandes: $e');
    }
  }

  /// Récupérer une commande par son ID
  Future<Order> getOrder(int orderId) async {
    try {
      final response = await _apiService.get('/commandes/$orderId/');
      return Order.fromJson(response);
    } catch (e) {
      throw Exception('Erreur lors du chargement de la commande: $e');
    }
  }

  /// Mettre à jour le statut d'une commande
  Future<Order> updateOrderStatus(int orderId, String newStatus) async {
    try {
      final response = await _apiService.put('/commandes/$orderId/', {
        'statut': newStatus,
      });
      return Order.fromJson(response);
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du statut: $e');
    }
  }

  /// Obtenir les statistiques des commandes
  Future<Map<String, dynamic>> getOrderStats() async {
    try {
      final response = await _apiService.get('/commandes/stats/');
      return response;
    } catch (e) {
      throw Exception('Erreur lors du chargement des statistiques: $e');
    }
  }
}