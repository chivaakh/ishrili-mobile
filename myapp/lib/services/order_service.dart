// services/order_service.dart - SOLUTION COMPLÈTE CÔTÉ CLIENT
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class OrderService {
  // 🔥 SOLUTION PAGINATION : Récupérer toutes les pages automatiquement
  Future<Map<String, dynamic>> getOrders({String? status}) async {
    try {
      List<dynamic> allOrders = [];
      String? nextUrl = '${ApiConfig.baseUrl}/commandes/';
      int pageNumber = 1;
      
      print('🌐 DÉBUT RÉCUPÉRATION TOUTES LES COMMANDES');
      print('🔍 FILTRE DEMANDÉ: "${status ?? 'Toutes'}"');
      
      // Boucle pour récupérer toutes les pages
      while (nextUrl != null) {
        final response = await http.get(
          Uri.parse(nextUrl),
          headers: {'Content-Type': 'application/json'},
        ).timeout(ApiConfig.timeout);

        print('📄 Page $pageNumber - Status Code: ${response.statusCode}');

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          
          List<dynamic> pageOrders = [];
          if (data is Map && data['results'] != null) {
            pageOrders = data['results'] as List;
            nextUrl = data['next']; // URL de la page suivante
          } else if (data is List) {
            pageOrders = data;
            nextUrl = null; // Pas de pagination
          } else {
            nextUrl = null;
          }
          
          allOrders.addAll(pageOrders);
          print('📦 Page $pageNumber: ${pageOrders.length} commandes (+${allOrders.length} total)');
          
          pageNumber++;
          
          // Protection contre les boucles infinies
          if (pageNumber > 50) {
            print('⚠️ Limite de 50 pages atteinte, arrêt de la récupération');
            break;
          }
        } else {
          print('❌ Erreur page $pageNumber: ${response.statusCode}');
          break;
        }
      }

      print('📦 TOTAL COMMANDES RÉCUPÉRÉES: ${allOrders.length}');
      
      // Analyse des statuts reçus
      if (allOrders.isNotEmpty) {
        print('📦 ANALYSE DES STATUTS (5 premiers):');
        for (var order in allOrders.take(5)) {
          print('   📦 Commande #${order['id']}: "${order['statut']}" - ${order['client_nom'] ?? 'Client ${order['client']}'}');
        }
        if (allOrders.length > 5) {
          print('   📦 ... et ${allOrders.length - 5} autres commandes');
        }
      }
      
      // 🔥 FILTRAGE CÔTÉ CLIENT
      List<dynamic> filteredOrders = allOrders;
      if (status != null && status.isNotEmpty) {
        filteredOrders = allOrders.where((order) {
          final orderStatus = order['statut']?.toString() ?? '';
          return orderStatus == status;
        }).toList();
        
        print('🔍 FILTRE APPLIQUÉ: "$status"');
        print('🔍 COMMANDES CORRESPONDANTES: ${filteredOrders.length}');
        
        if (filteredOrders.isEmpty) {
          print('❌ AUCUNE COMMANDE AVEC LE STATUT "$status"');
          final availableStatuses = allOrders.map((o) => o['statut']).toSet();
          print('❌ Statuts disponibles: ${availableStatuses.join(', ')}');
        }
      }
      
      return {
        'success': true,
        'data': filteredOrders,
        'total': allOrders.length,
        'filtered': filteredOrders.length,
      };
    } catch (e) {
      print('❌ ERREUR DANS getOrders: $e');
      return {
        'success': false,
        'message': 'Erreur de connexion: $e',
      };
    }
  }

  // 🔥 COMMANDES D'AUJOURD'HUI : Utiliser l'endpoint dédié
  Future<Map<String, dynamic>> getTodaysOrders() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/commandes/commandes_du_jour/'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(ApiConfig.timeout);

      print('🌐 REQUEST TODAY: ${ApiConfig.baseUrl}/commandes/commandes_du_jour/');
      print('📊 Status Code Today: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        List<dynamic> ordersData = [];
        if (data is Map && data['results'] != null) {
          ordersData = data['results'] as List;
        } else if (data is List) {
          ordersData = data;
        }

        print('📦 Commandes d\'aujourd\'hui reçues: ${ordersData.length}');
        
        return {
          'success': true,
          'data': ordersData,
          'count': ordersData.length,
        };
      } else {
        return {
          'success': false,
          'message': 'Erreur ${response.statusCode}: ${response.reasonPhrase}',
        };
      }
    } catch (e) {
      print('❌ ERREUR getTodaysOrders: $e');
      return {
        'success': false,
        'message': 'Erreur de connexion: $e',
      };
    }
  }

  // 🔥 RÉCUPÉRATION DES IMAGES : Nouvel endpoint pour les images d'un produit
  Future<List<Map<String, dynamic>>> getProductImages(int produitId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/produits/$produitId/images/'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          return List<Map<String, dynamic>>.from(data);
        } else if (data is Map && data['results'] != null) {
          return List<Map<String, dynamic>>.from(data['results']);
        }
      }
    } catch (e) {
      print('❌ Erreur récupération images produit $produitId: $e');
    }
    
    return []; // Retourner liste vide si erreur
  }

  // 🔥 ENRICHISSEMENT DES COMMANDES : Ajouter les images aux détails
  Future<Map<String, dynamic>> getOrdersWithImages({String? status}) async {
    try {
      // 1. Récupérer les commandes
      final ordersResult = await getOrders(status: status);
      
      if (!ordersResult['success']) {
        return ordersResult;
      }
      
      List<dynamic> orders = ordersResult['data'];
      
      // 2. Pour chaque commande, enrichir les détails avec les images
      for (var order in orders) {
        if (order['details'] != null) {
          for (var detail in order['details']) {
            if (detail['specification'] != null && detail['specification']['produit_id'] != null) {
              final produitId = detail['specification']['produit_id'];
              
              // Récupérer les images du produit
              final images = await getProductImages(produitId);
              detail['images'] = images;
              
              print('🖼️ Produit $produitId: ${images.length} images ajoutées');
            }
          }
        }
      }
      
      return {
        'success': true,
        'data': orders,
        'total': ordersResult['total'],
        'filtered': ordersResult['filtered'],
      };
    } catch (e) {
      print('❌ Erreur enrichissement avec images: $e');
      return {
        'success': false,
        'message': 'Erreur enrichissement: $e',
      };
    }
  }

  // TRACKING D'UNE COMMANDE
  Future<Map<String, dynamic>> getOrderTracking(int orderId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/commandes/$orderId/tracking/'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(ApiConfig.timeout);

      print('🌐 REQUEST TRACKING: ${ApiConfig.baseUrl}/commandes/$orderId/tracking/');
      print('📊 Status Code Tracking: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('📦 Historique de tracking reçu: ${data.length} entrées');
        
        return {
          'success': true,
          'data': data,
        };
      } else {
        return {
          'success': false,
          'message': 'Historique non disponible',
        };
      }
    } catch (e) {
      print('❌ ERREUR getOrderTracking: $e');
      return {
        'success': false,
        'message': 'Erreur de connexion: $e',
      };
    }
  }

  // RÉCUPÉRER UNE COMMANDE PAR ID
  Future<Map<String, dynamic>> getOrderById(int orderId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/commandes/$orderId/'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': json.decode(response.body),
        };
      } else {
        return {
          'success': false,
          'message': 'Commande non trouvée',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur de connexion: $e',
      };
    }
  }

  // METTRE À JOUR LE STATUT D'UNE COMMANDE
  Future<Map<String, dynamic>> updateOrderStatus(int orderId, String newStatus) async {
    try {
      final Map<String, dynamic> updateData = {
        'statut': newStatus,
      };

      // Ajouter les timestamps selon le nouveau statut
      switch (newStatus) {
        case 'confirmee':
          updateData['date_confirmation'] = DateTime.now().toIso8601String();
          break;
        case 'expediee':
          updateData['date_expedition'] = DateTime.now().toIso8601String();
          break;
        case 'livree':
          updateData['date_livraison'] = DateTime.now().toIso8601String();
          break;
        case 'annulee':
          updateData['date_annulation'] = DateTime.now().toIso8601String();
          break;
      }

      print('🔄 MISE À JOUR COMMANDE #$orderId:');
      print('   📍 Nouveau statut: "$newStatus"');

      final response = await http.patch(
        Uri.parse('${ApiConfig.baseUrl}/commandes/$orderId/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(updateData),
      ).timeout(ApiConfig.timeout);

      print('📊 Status Code Update: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('✅ COMMANDE MISE À JOUR: "${responseData['statut']}"');
        
        return {
          'success': true,
          'data': responseData,
        };
      } else {
        return {
          'success': false,
          'message': 'Erreur lors de la mise à jour: ${response.reasonPhrase}',
        };
      }
    } catch (e) {
      print('❌ ERREUR MISE À JOUR: $e');
      return {
        'success': false,
        'message': 'Erreur de connexion: $e',
      };
    }
  }

  // STATISTIQUES DES COMMANDES
  Future<Map<String, dynamic>> getOrderStats() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/commandes/statistics/'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': json.decode(response.body),
        };
      } else {
        return {
          'success': false,
          'message': 'Erreur lors du chargement des statistiques',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur de connexion: $e',
      };
    }
  }

  // MÉTHODES RACCOURCIES
  Future<Map<String, dynamic>> confirmOrder(int orderId) async {
    return updateOrderStatus(orderId, 'confirmee');
  }

  Future<Map<String, dynamic>> shipOrder(int orderId) async {
    return updateOrderStatus(orderId, 'expediee');
  }

  Future<Map<String, dynamic>> deliverOrder(int orderId) async {
    return updateOrderStatus(orderId, 'livree');
  }

  Future<Map<String, dynamic>> cancelOrder(int orderId) async {
    return updateOrderStatus(orderId, 'annulee');
  }
}