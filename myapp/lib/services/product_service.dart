// services/product_service.dart - VERSION CORRIGÉE SANS ERREURS ✅
import 'dart:io';
import 'package:flutter/foundation.dart'; // ← AJOUTÉ pour debugPrint
import '../models/product_model.dart';
import '../models/product_image_model.dart';
import '../models/product_specification_model.dart';
import 'api_service.dart';

class ProductService {
  final ApiService _apiService = ApiService();

  // 📦 GESTION DES PRODUITS
  
  /// Récupérer tous les produits avec pagination
  Future<Map<String, dynamic>> getProducts({
    int page = 1,
    int? categoryId,
    String? search,
  }) async {
    String endpoint = '/produits/';
    
    List<String> params = [];
    params.add('page=$page');
    if (categoryId != null) params.add('category=$categoryId');
    if (search != null && search.isNotEmpty) params.add('search=$search');
    
    if (params.isNotEmpty) {
      endpoint += '?${params.join('&')}';
    }
    
    try {
      final response = await _apiService.get(endpoint);
      
      // Adaptation au format de pagination Django REST
      return {
        'results': (response['results'] as List? ?? [])
            .map((json) => Product.fromJson(json))
            .toList(),
        'count': response['count'] ?? 0,
        'next': response['next'],
        'previous': response['previous'],
        'hasMore': response['next'] != null,
      };
    } catch (e) {
      throw Exception('Erreur lors du chargement des produits: $e');
    }
  }

  /// Récupérer un produit par son ID
  Future<Product> getProduct(int productId) async {
    try {
      final response = await _apiService.get('/produits/$productId/');
      return Product.fromJson(response);
    } catch (e) {
      throw Exception('Erreur lors du chargement du produit: $e');
    }
  }

  /// Créer un nouveau produit complet (pour vendeurs)
  Future<Product> createProduct({
    required String nom,
    required String description,
    required String reference,
    int? categoryId,
    List<Map<String, dynamic>> images = const [],
    List<Map<String, dynamic>> specifications = const [],
  }) async {
    try {
      final productData = {
        'nom': nom,
        'description': description,
        'reference': reference,
        'images': images,
        'specifications': specifications,
        if (categoryId != null) 'categorie': categoryId,
      };

      final response = await _apiService.post('/produits/', productData);
      return Product.fromJson(response);
    } catch (e) {
      throw Exception('Erreur lors de la création du produit: $e');
    }
  }

  /// ✅ NOUVELLE MÉTHODE : Supprimer un produit
  Future<bool> deleteProduct(int productId) async {
    try {
      await _apiService.delete('/produits/$productId/');
      return true;
    } catch (e) {
      throw Exception('Erreur lors de la suppression du produit: $e');
    }
  }

  /// ✅ NOUVELLE MÉTHODE : Mettre à jour un produit
  Future<Product> updateProduct(int productId, {
    String? nom,
    String? description,
    String? reference,
    int? categoryId,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      if (nom != null) updateData['nom'] = nom;
      if (description != null) updateData['description'] = description;
      if (reference != null) updateData['reference'] = reference;
      if (categoryId != null) updateData['categorie'] = categoryId;

      final response = await _apiService.put('/produits/$productId/', updateData);
      return Product.fromJson(response);
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du produit: $e');
    }
  }

  /// ✅ Upload d'image avec debug amélioré (UNIQUE)
  Future<String> uploadImage(File imageFile) async {
    try {
      debugPrint('📸 Upload image: ${imageFile.path}');
      final response = await _apiService.uploadImage('/upload-image/', imageFile);
      
      final imageUrl = response['url'];
      debugPrint('🔗 URL reçue: $imageUrl');
      
      return imageUrl;
    } catch (e) {
      debugPrint('❌ Erreur upload: $e');
      throw Exception('Erreur lors de l\'upload de l\'image: $e');
    }
  }

  /// Ajouter une image à un produit existant
  Future<ProductImage> addImageToProduct(int productId, {
    required String imageUrl,
    bool isPrincipal = false,
    int ordre = 0,
  }) async {
    try {
      final response = await _apiService.post('/produits/$productId/add_image/', {
        'url_image': imageUrl,
        'est_principale': isPrincipal,
        'ordre': ordre,
      });
      return ProductImage.fromJson(response);
    } catch (e) {
      throw Exception('Erreur lors de l\'ajout de l\'image: $e');
    }
  }

  /// Ajouter une spécification à un produit existant
  Future<ProductSpecification> addSpecificationToProduct(int productId, {
    required String nom,
    required String description,
    required double prix,
    double? prixPromo,
    int quantiteStock = 0,
    bool estDefaut = false,
    String referenceSpecification = '',
  }) async {
    try {
      final response = await _apiService.post('/produits/$productId/add_specification/', {
        'nom': nom,
        'description': description,
        'prix': prix,
        'prix_promo': prixPromo,
        'quantite_stock': quantiteStock,
        'est_defaut': estDefaut,
        'reference_specification': referenceSpecification,
      });
      return ProductSpecification.fromJson(response);
    } catch (e) {
      throw Exception('Erreur lors de l\'ajout de la spécification: $e');
    }
  }

  /// Récupérer les images d'un produit
  Future<List<ProductImage>> getProductImages(int productId) async {
    try {
      final response = await _apiService.get('/produits/$productId/images/');
      return (response as List? ?? [])
          .map((json) => ProductImage.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors du chargement des images: $e');
    }
  }

  /// Récupérer les spécifications d'un produit
  Future<List<ProductSpecification>> getProductSpecifications(int productId) async {
    try {
      final response = await _apiService.get('/produits/$productId/specifications/');
      return (response as List? ?? [])
          .map((json) => ProductSpecification.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors du chargement des spécifications: $e');
    }
  }
}