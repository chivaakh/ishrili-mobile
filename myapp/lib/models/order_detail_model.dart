// models/order_detail_model.dart - COMPATIBLE AVEC VOTRE API RÉELLE
import 'product_specification_model.dart';
import '../config/api_config.dart';

class OrderDetail {
  final int id;
  final int commandeId;
  final ProductSpecification specification;
  final int quantite;
  final double prixUnitaire;
  
  // ✅ NOUVEAUX CHAMPS selon votre API
  final String? specificationNom;
  final String? produitNom;
  final String? produitImage;

  OrderDetail({
    required this.id,
    required this.commandeId,
    required this.specification,
    required this.quantite,
    required this.prixUnitaire,
    this.specificationNom,
    this.produitNom,
    this.produitImage,
  });

  factory OrderDetail.fromJson(Map<String, dynamic> json) {
    try {
      print('🔍 Parsing OrderDetail: ${json['id']}');
      
      return OrderDetail(
        id: _parseInt(json['id']),
        commandeId: _parseInt(json['commande']), // Peut être null dans votre API
        quantite: _parseInt(json['quantite']),
        prixUnitaire: _parseDouble(json['prix_unitaire']),
        
        // ✅ ADAPTATION: Créer une ProductSpecification à partir des données API
        specification: _createSpecificationFromApiData(json),
        
        // ✅ NOUVEAUX CHAMPS de votre API
        specificationNom: json['specification_nom']?.toString(),
        produitNom: json['produit_nom']?.toString(),
        produitImage: json['produit_image']?.toString(),
      );
    } catch (e) {
      print('❌ Erreur parsing OrderDetail ${json['id']}: $e');
      print('❌ JSON problématique: $json');
      rethrow;
    }
  }

  // ✅ MÉTHODES HELPER POUR PARSING SÉCURISÉ
  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is double) return value.toInt();
    return 0;
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  // ✅ CRÉER ProductSpecification à partir des données de votre API
  static ProductSpecification _createSpecificationFromApiData(Map<String, dynamic> json) {
    return ProductSpecification(
      id: _parseInt(json['specification']),
      produitId: 0, // Pas disponible directement dans votre API
      nom: json['specification_nom']?.toString() ?? 'Spécification',
      description: json['produit_nom']?.toString() ?? 'Description',
      prix: _parseDouble(json['prix_unitaire']),
      prixPromo: null,
      quantiteStock: 0, // Pas disponible dans les détails de commande
      estDefaut: true,
      referenceSpecification: 'REF-${json['specification'] ?? 0}',
    );
  }

  double get total => prixUnitaire * quantite;

  // ✅ Getter pour le nom du produit (compatible avec vos écrans)
  String get nomProduit => produitNom ?? specificationNom ?? 'Produit inconnu';

  // 🖼️ GETTERS POUR LES IMAGES - SIMPLES ET DIRECTS

  // URL d'image de fallback basée sur le nom du produit
  String get imageUrlFallback {
    final nom = nomProduit.toLowerCase();
    
    const baseUrl = 'https://images.unsplash.com/photo-';
    const suffix = '?w=400&h=400&fit=crop&auto=format';
    
    if (nom.contains('iphone') || nom.contains('apple')) {
      return '${baseUrl}1510557880182-3d4d3cba35a5$suffix';
    } else if (nom.contains('macbook') || nom.contains('laptop')) {
      return '${baseUrl}1517336714731-489689fd1ca8$suffix';
    } else if (nom.contains('ipad') || nom.contains('tablet')) {
      return '${baseUrl}1544244015-0df4b3ffc6b0$suffix';
    } else if (nom.contains('galaxy') || nom.contains('samsung')) {
      return '${baseUrl}1511707171634-5f897ff02aa9$suffix';
    } else if (nom.contains('chaise') || nom.contains('chair')) {
      return '${baseUrl}1586023492125-27b2c045efd7$suffix';
    } else if (nom.contains('casque') || nom.contains('headphone') || nom.contains('wh-')) {
      return '${baseUrl}1505740420928-5e560c06d30e$suffix';
    } else if (nom.contains('jordan') || nom.contains('shoe') || nom.contains('chaussure')) {
      return '${baseUrl}1549298916-b41d501d3772$suffix';
    } else if (nom.contains('polo') || nom.contains('shirt') || nom.contains('t-shirt')) {
      return '${baseUrl}1521572163474-6864f9cf17ab$suffix';
    } else if (nom.contains('128gb') || nom.contains('256gb') || nom.contains('512gb')) {
      return '${baseUrl}1560472354-b33ff0c44a43$suffix';
    }
    
    return '${baseUrl}1560472354-b33ff0c44a43$suffix';
  }

  // ✅ URL D'IMAGE PRINCIPALE - RETOURNE DIRECTEMENT L'URL COMPLÈTE
  String? get imagePrincipale {
    // Priorité à l'image de votre API
    if (produitImage != null && produitImage!.isNotEmpty) {
      // Si l'image commence par http, l'utiliser directement
      if (produitImage!.startsWith('http')) {
        // 🔧 FIX: Si l'API retourne localhost, le remplacer par 10.0.2.2
        if (produitImage!.contains('localhost')) {
          final fixedUrl = produitImage!.replaceAll('localhost', '10.0.2.2');
          print('🔧 URL corrigée: localhost → 10.0.2.2');
          return fixedUrl;
        }
        return produitImage;
      }
      
      // Sinon, construire l'URL complète avec votre ApiConfig
      try {
        final baseUrl = ApiConfig.mediaUrl;
        
        // Construction intelligente de l'URL
        if (baseUrl.endsWith('/') && produitImage!.startsWith('/')) {
          return '$baseUrl${produitImage!.substring(1)}';
        } else if (!baseUrl.endsWith('/') && !produitImage!.startsWith('/')) {
          return '$baseUrl$produitImage';
        } else {
          return '$baseUrl$produitImage';
        }
      } catch (e) {
        print('❌ Erreur construction URL image: $e');
        return imageUrlFallback;
      }
    }
    
    // Fallback vers image placeholder
    return imageUrlFallback;
  }

  // ✅ MÉTHODE toJson pour compatibilité
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'commande': commandeId,
      'specification': specification.id,
      'quantite': quantite,
      'prix_unitaire': prixUnitaire,
      'specification_nom': specificationNom,
      'produit_nom': produitNom,
      'produit_image': produitImage,
    };
  }
}