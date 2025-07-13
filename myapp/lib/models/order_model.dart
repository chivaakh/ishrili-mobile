// models/order_model.dart - VERSION CORRIGÉE UTILISANT VOTRE OrderDetail EXISTANT
import 'package:flutter/material.dart';
import '../config/api_config.dart';
import 'order_detail_model.dart'; // ✅ IMPORT DE VOTRE MODÈLE EXISTANT
import 'product_specification_model.dart';

class Order {
  final int id;
  final int clientId;
  final DateTime dateCommande;
  final double montantTotal;
  final String statut;
  final List<OrderDetail> details;
  final String? clientNom;
  final String? clientPrenom;
  final int nombreArticles;

  Order({
    required this.id,
    required this.clientId,
    required this.dateCommande,
    required this.montantTotal,
    required this.statut,
    required this.details,
    this.clientNom,
    this.clientPrenom,
    required this.nombreArticles,
  });

  // Nom complet du client avec fallback intelligent
  String get clientNomComplet {
    if (clientPrenom != null && clientNom != null) {
      return '$clientPrenom $clientNom';
    } else if (clientNom != null) {
      return clientNom!;
    } else if (clientPrenom != null) {
      return clientPrenom!;
    }
    return 'Client #$clientId';
  }

  // Montant formaté avec devise
  String get montantFormate => '${montantTotal.toStringAsFixed(0)} MRU';

  // Nombre total d'articles dans la commande
  int get totalArticles => details.fold(0, (sum, detail) => sum + detail.quantite);

  // Vérifier si la commande peut être modifiée
  bool get peutEtreModifiee => ['en_attente', 'confirmee'].contains(statut);

  // Vérifier si la commande est terminée
  bool get estTerminee => ['livree', 'annulee'].contains(statut);

  // Obtenir la couleur du statut
  Color get couleurStatut {
    switch (statut) {
      case 'en_attente':
        return const Color(0xFFFF9800); // Orange
      case 'confirmee':
        return const Color(0xFF2196F3); // Bleu
      case 'expediee':
        return const Color(0xFF9C27B0); // Violet
      case 'livree':
        return const Color(0xFF4CAF50); // Vert
      case 'annulee':
        return const Color(0xFFF44336); // Rouge
      default:
        return const Color(0xFF9E9E9E); // Gris
    }
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    // 🔥 PARSING SÉCURISÉ DES DÉTAILS UTILISANT VOTRE MODÈLE EXISTANT
    List<OrderDetail> orderDetails = [];
    
    try {
      final detailsData = json['details'];
      
      if (detailsData != null) {
        if (detailsData is List) {
          // Parcourir chaque élément de la liste des détails
          for (int i = 0; i < detailsData.length; i++) {
            final detail = detailsData[i];
            
            try {
              if (detail is Map<String, dynamic>) {
                // ✅ CAS NORMAL : Utiliser votre OrderDetail.fromJson existant
                final orderDetail = OrderDetail.fromJson(detail);
                orderDetails.add(orderDetail);
                print('✅ Détail $i parsé comme Map : ID=${orderDetail.id}');
                
              } else if (detail is int) {
                // 🔧 CAS PROBLÉMATIQUE : Créer un détail minimal avec juste l'ID
                print('⚠️ Détail $i reçu comme ID simple : $detail');
                
                // Créer un Map minimal pour votre OrderDetail.fromJson
                final detailMinimal = {
                  'id': detail,
                  'commande': _parseInt(json['id']), // ID de la commande courante
                  'specification': detail, // Utiliser l'ID comme spec ID
                  'quantite': 1,
                  'prix_unitaire': 0.0,
                  'specification_nom': 'Spécification #$detail',
                  'produit_nom': 'Produit #$detail',
                  'produit_image': null,
                };
                
                final orderDetail = OrderDetail.fromJson(detailMinimal);
                orderDetails.add(orderDetail);
                print('🔧 Détail minimal créé pour ID : $detail');
                
              } else if (detail is String) {
                // CAS OÙ L'ID EST UNE STRING
                try {
                  final detailId = int.parse(detail);
                  final detailMinimal = {
                    'id': detailId,
                    'commande': _parseInt(json['id']),
                    'specification': detailId,
                    'quantite': 1,
                    'prix_unitaire': 0.0,
                    'specification_nom': 'Spécification #$detailId',
                    'produit_nom': 'Produit #$detailId',
                    'produit_image': null,
                  };
                  
                  final orderDetail = OrderDetail.fromJson(detailMinimal);
                  orderDetails.add(orderDetail);
                  print('🔧 Détail minimal créé pour ID string : $detail');
                } catch (e) {
                  print('❌ Impossible de parser l\'ID string : $detail');
                }
                
              } else {
                print('❌ Type de détail non supporté à l\'index $i: ${detail.runtimeType} = $detail');
              }
              
            } catch (e, stackTrace) {
              print('❌ Erreur parsing détail à l\'index $i: $e');
              print('📍 StackTrace: $stackTrace');
              print('📦 Données du détail: $detail');
              
              // Essayer de créer un détail minimal même en cas d'erreur
              try {
                if (detail is num) {
                  final detailMinimal = {
                    'id': detail.toInt(),
                    'commande': _parseInt(json['id']),
                    'specification': detail.toInt(),
                    'quantite': 1,
                    'prix_unitaire': 0.0,
                    'specification_nom': 'Spécification #${detail.toInt()}',
                    'produit_nom': 'Produit #${detail.toInt()}',
                    'produit_image': null,
                  };
                  
                  orderDetails.add(OrderDetail.fromJson(detailMinimal));
                  print('🔧 Détail de secours créé avec ID: ${detail.toInt()}');
                }
              } catch (e2) {
                print('❌ Impossible de créer un détail de secours: $e2');
              }
            }
          }
        } else {
          print('⚠️ Details n\'est pas une liste mais un ${detailsData.runtimeType}: $detailsData');
          
          // Si ce n'est pas une liste, essayer de le traiter comme un seul élément
          try {
            if (detailsData is Map<String, dynamic>) {
              orderDetails.add(OrderDetail.fromJson(detailsData));
            } else if (detailsData is num) {
              final detailMinimal = {
                'id': detailsData.toInt(),
                'commande': _parseInt(json['id']),
                'specification': detailsData.toInt(),
                'quantite': 1,
                'prix_unitaire': 0.0,
                'specification_nom': 'Spécification #${detailsData.toInt()}',
                'produit_nom': 'Produit #${detailsData.toInt()}',
                'produit_image': null,
              };
              orderDetails.add(OrderDetail.fromJson(detailMinimal));
            }
          } catch (e) {
            print('❌ Erreur parsing détail unique: $e');
          }
        }
      } else {
        print('⚠️ Aucun détail trouvé pour la commande');
      }
      
    } catch (e, stackTrace) {
      print('❌ Erreur globale parsing details commande: $e');
      print('📍 StackTrace: $stackTrace');
      print('📦 Données details brutes: ${json['details']}');
    }

    return Order(
      id: _parseInt(json['id']),
      clientId: _parseInt(json['client_id'] ?? json['client']),
      dateCommande: _parseDate(json['date_commande']),
      montantTotal: _parseDouble(json['montant_total']),
      statut: json['statut']?.toString() ?? 'en_attente',
      details: orderDetails,
      clientNom: json['client_nom']?.toString(),
      clientPrenom: json['client_prenom']?.toString(),
      nombreArticles: orderDetails.fold(0, (sum, detail) => sum + detail.quantite),
    );
  }

  // 🔥 HELPERS DE PARSING SÉCURISÉS
  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    try {
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) return int.parse(value);
      return 0;
    } catch (e) {
      print('❌ Erreur parsing int: $value');
      return 0;
    }
  }

  static DateTime _parseDate(dynamic dateValue) {
    if (dateValue == null) return DateTime.now();
    try {
      return DateTime.parse(dateValue.toString());
    } catch (e) {
      print('❌ Erreur parsing date: $dateValue');
      return DateTime.now();
    }
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    try {
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.parse(value);
      return (value as num).toDouble();
    } catch (e) {
      print('❌ Erreur parsing montant: $value');
      return 0.0;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'client_id': clientId,
      'date_commande': dateCommande.toIso8601String(),
      'montant_total': montantTotal,
      'statut': statut,
      'details': details.map((detail) => detail.toJson()).toList(),
      'client_nom': clientNom,
      'client_prenom': clientPrenom,
      'nombre_articles': nombreArticles,
    };
  }
}

// Modèle pour l'historique des commandes
class OrderStatusHistory {
  final int id;
  final String? ancienStatut;
  final String nouveauStatut;
  final DateTime dateModification;
  final String? commentaire;

  OrderStatusHistory({
    required this.id,
    this.ancienStatut,
    required this.nouveauStatut,
    required this.dateModification,
    this.commentaire,
  });

  // Label lisible pour l'ancien statut
  String get ancienStatutLabel {
    return _getStatusLabel(ancienStatut);
  }

  // Label lisible pour le nouveau statut
  String get nouveauStatutLabel {
    return _getStatusLabel(nouveauStatut);
  }

  // Description du changement
  String get descriptionChangement {
    if (ancienStatut == null) {
      return 'Commande créée avec le statut "${nouveauStatutLabel}"';
    }
    return 'Statut changé de "${ancienStatutLabel}" à "${nouveauStatutLabel}"';
  }

  // Temps écoulé depuis ce changement
  String get tempsEcoule {
    final now = DateTime.now();
    final difference = now.difference(dateModification);

    if (difference.inMinutes < 60) {
      return 'Il y a ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Il y a ${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return 'Il y a ${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}';
    } else {
      return '${dateModification.day}/${dateModification.month}/${dateModification.year}';
    }
  }

  String _getStatusLabel(String? status) {
    if (status == null) return 'Aucun';
    
    switch (status) {
      case 'en_attente':
        return 'En attente';
      case 'confirmee':
        return 'Confirmée';
      case 'expediee':
        return 'Expédiée';
      case 'livree':
        return 'Livrée';
      case 'annulee':
        return 'Annulée';
      default:
        return status;
    }
  }

  factory OrderStatusHistory.fromJson(Map<String, dynamic> json) {
    return OrderStatusHistory(
      id: Order._parseInt(json['id']),
      ancienStatut: json['ancien_statut']?.toString(),
      nouveauStatut: json['nouveau_statut']?.toString() ?? '',
      dateModification: Order._parseDate(json['date_modification']),
      commentaire: json['commentaire']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ancien_statut': ancienStatut,
      'nouveau_statut': nouveauStatut,
      'date_modification': dateModification.toIso8601String(),
      'commentaire': commentaire,
    };
  }
}

// Énumération pour les statuts de commande
enum OrderStatus {
  enAttente('en_attente', 'En attente', Color(0xFFFF9800)),
  confirmee('confirmee', 'Confirmée', Color(0xFF2196F3)),
  expediee('expediee', 'Expédiée', Color(0xFF9C27B0)),
  livree('livree', 'Livrée', Color(0xFF4CAF50)),
  annulee('annulee', 'Annulée', Color(0xFFF44336));

  const OrderStatus(this.value, this.label, this.color);

  final String value;
  final String label;
  final Color color;

  static OrderStatus fromString(String value) {
    return OrderStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => OrderStatus.enAttente,
    );
  }
}