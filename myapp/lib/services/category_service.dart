// services/category_service.dart - CONFLIT RÉSOLU
import '../models/category_model.dart' as models; // ← AJOUT du préfixe
import 'api_service.dart';

class CategoryService {
  final ApiService _apiService = ApiService();

  /// Récupérer toutes les catégories
  Future<List<models.Category>> getCategories() async {
    try {
      final response = await _apiService.get('/categories/');
      
      // Si c'est une réponse paginée (avec 'results')
      if (response['results'] != null) {
        return (response['results'] as List)
            .map((json) => models.Category.fromJson(json))
            .toList();
      }
      
      // Si c'est une liste directe
      return (response as List)
          .map((json) => models.Category.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors du chargement des catégories: $e');
    }
  }

  /// Récupérer une catégorie par son ID
  Future<models.Category> getCategory(int categoryId) async {
    try {
      final response = await _apiService.get('/categories/$categoryId/');
      return models.Category.fromJson(response);
    } catch (e) {
      throw Exception('Erreur lors du chargement de la catégorie: $e');
    }
  }

  /// Créer une nouvelle catégorie
  Future<models.Category> createCategory({
    required String nom,
    required String description,
  }) async {
    try {
      final categoryData = {
        'nom': nom,
        'description': description,
      };

      final response = await _apiService.post('/categories/', categoryData);
      return models.Category.fromJson(response);
    } catch (e) {
      throw Exception('Erreur lors de la création de la catégorie: $e');
    }
  }

  /// Mettre à jour une catégorie
  Future<models.Category> updateCategory(int categoryId, {
    String? nom,
    String? description,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      if (nom != null) updateData['nom'] = nom;
      if (description != null) updateData['description'] = description;

      final response = await _apiService.put('/categories/$categoryId/', updateData);
      return models.Category.fromJson(response);
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour de la catégorie: $e');
    }
  }

  /// Supprimer une catégorie
  Future<bool> deleteCategory(int categoryId) async {
    try {
      await _apiService.delete('/categories/$categoryId/');
      return true;
    } catch (e) {
      throw Exception('Erreur lors de la suppression de la catégorie: $e');
    }
  }
}