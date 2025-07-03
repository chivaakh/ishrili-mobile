// models/product_model.dart - VERSION CORRIGÉE ✅
import 'package:flutter/foundation.dart'; // ← AJOUT pour debugPrint
import 'category_model.dart' as models;
import 'vendor_model.dart';
import 'product_image_model.dart';
import 'product_specification_model.dart';

class Product {
  final int id;
  final String reference;
  final String nom;
  final String description;
  final models.Category? categorie;
  final Vendor? commercant;
  final List<ProductImage> images;
  final List<ProductSpecification> specifications;

  Product({
    required this.id,
    required this.reference,
    required this.nom,
    required this.description,
    this.categorie,
    this.commercant,
    this.images = const [],
    this.specifications = const [],
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      reference: json['reference'] ?? '',
      nom: json['nom'] ?? '',
      description: json['description'] ?? '',
      
      // ✅ CORRECTION: Gestion flexible des catégories
      categorie: _parseCategory(json['categorie']),
      
      // ✅ CORRECTION: Gestion flexible des commercants
      commercant: _parseVendor(json['commercant']),
      
      // ✅ CORRECTION: Gestion robuste des images
      images: _parseImages(json['images']),
      
      // ✅ CORRECTION: Gestion robuste des spécifications
      specifications: _parseSpecifications(json['specifications']),
    );
  }

  // ✅ MÉTHODE HELPER: Parse catégorie (peut être int, Map, ou null)
  static models.Category? _parseCategory(dynamic categoryData) {
    if (categoryData == null) return null;
    
    if (categoryData is Map<String, dynamic>) {
      try {
        return models.Category.fromJson(categoryData);
      } catch (e) {
        debugPrint('❌ Erreur parsing catégorie: $e');
        return null;
      }
    } else if (categoryData is int) {
      // Si c'est juste un ID, créer une catégorie basique
      return models.Category(
        id: categoryData,
        nom: 'Catégorie #$categoryData',
        description: '',
      );
    }
    
    return null;
  }

  // ✅ MÉTHODE HELPER: Parse vendor (peut être int, Map, ou null)
  static Vendor? _parseVendor(dynamic vendorData) {
    if (vendorData == null) return null;
    
    if (vendorData is Map<String, dynamic>) {
      try {
        return Vendor.fromJson(vendorData);
      } catch (e) {
        debugPrint('❌ Erreur parsing vendor: $e');
        return null;
      }
    } else if (vendorData is int) {
      // ✅ Créer un vendor basique avec juste l'ID
      try {
        return Vendor.fromId(vendorData);
      } catch (e) {
        debugPrint('❌ Erreur création vendor basique: $e');
        return null;
      }
    }
    
    return null;
  }

  // ✅ MÉTHODE HELPER: Parse images de manière robuste
  static List<ProductImage> _parseImages(dynamic imagesData) {
    if (imagesData == null) return [];
    
    if (imagesData is List) {
      return imagesData
          .where((img) => img != null && img is Map<String, dynamic>)
          .map((img) {
            try {
              return ProductImage.fromJson(img as Map<String, dynamic>);
            } catch (e) {
              debugPrint('❌ Erreur parsing image: $e');
              return null;
            }
          })
          .where((img) => img != null)
          .cast<ProductImage>()
          .toList();
    }
    
    return [];
  }

  // ✅ MÉTHODE HELPER: Parse spécifications de manière robuste
  static List<ProductSpecification> _parseSpecifications(dynamic specsData) {
    if (specsData == null) return [];
    
    if (specsData is List) {
      return specsData
          .where((spec) => spec != null && spec is Map<String, dynamic>)
          .map((spec) {
            try {
              return ProductSpecification.fromJson(spec as Map<String, dynamic>);
            } catch (e) {
              debugPrint('❌ Erreur parsing spécification: $e');
              return null;
            }
          })
          .where((spec) => spec != null)
          .cast<ProductSpecification>()
          .toList();
    }
    
    return [];
  }

  // Image principale
  String? get mainImage {
    final mainImgs = images.where((img) => img.estPrincipale);
    if (mainImgs.isNotEmpty) {
      return mainImgs.first.urlImage;
    }
    return images.isNotEmpty ? images.first.urlImage : null;
  }

  // Prix de base (première spécification)
  double? get basePrice {
    return specifications.isNotEmpty ? specifications.first.prix : null;
  }

  // Prix promotionnel si disponible
  double? get promoPrice {
    return specifications.isNotEmpty ? specifications.first.prixPromo : null;
  }

  // Prix effectif (promo si disponible, sinon normal)
  double? get effectivePrice {
    final defaultSpecs = specifications.where((spec) => spec.estDefaut);
    if (defaultSpecs.isNotEmpty) {
      return defaultSpecs.first.prixPromo ?? defaultSpecs.first.prix;
    }
    return specifications.isNotEmpty ? specifications.first.prix : null;
  }

  // Y a-t-il une promotion sur le produit ?
  bool get hasPromotion {
    return specifications.any((spec) => spec.prixPromo != null);
  }

  // Prix minimum du produit
  double? get minPrice {
    if (specifications.isEmpty) return null;
    return specifications
        .map((spec) => spec.prixPromo ?? spec.prix)
        .reduce((min, price) => price < min ? price : min);
  }

  // Prix maximum du produit
  double? get maxPrice {
    if (specifications.isEmpty) return null;
    return specifications
        .map((spec) => spec.prixPromo ?? spec.prix)
        .reduce((max, price) => price > max ? price : max);
  }

  // Produit en stock ?
  bool get inStock {
    return specifications.any((spec) => spec.quantiteStock > 0);
  }

  // Stock total
  int get totalStock {
    return specifications.fold(0, (total, spec) => total + spec.quantiteStock);
  }

  // Toutes les URLs d'images
  List<String> get allImageUrls {
    return images.map((img) => img.urlImage).toList();
  }
}