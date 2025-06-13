// providers/category_provider.dart - CONFLIT RÉSOLU
import 'package:flutter/foundation.dart';
import '../models/category_model.dart' as models; // ← AJOUT du préfixe
import '../services/category_service.dart';

class CategoryProvider with ChangeNotifier {
  final CategoryService _categoryService = CategoryService();

  List<models.Category> _categories = []; // ← Utilisation du préfixe
  models.Category? _selectedCategory;     // ← Utilisation du préfixe
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<models.Category> get categories => _categories;
  models.Category? get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Charger toutes les catégories
  Future<void> loadCategories() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _categories = await _categoryService.getCategories();
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Erreur chargement catégories: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sélectionner une catégorie
  void selectCategory(models.Category? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  // Créer une nouvelle catégorie
  Future<bool> createCategory({
    required String nom,
    required String description,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final newCategory = await _categoryService.createCategory(
        nom: nom,
        description: description,
      );

      _categories.add(newCategory);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Erreur création catégorie: $e');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear les erreurs
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}