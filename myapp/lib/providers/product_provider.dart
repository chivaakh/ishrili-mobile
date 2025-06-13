// providers/product_provider.dart - VERSION COMPLÈTE CORRIGÉE
import 'package:flutter/foundation.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';

class ProductProvider with ChangeNotifier {
  final ProductService _productService = ProductService();

  List<Product> _products = [];
  Product? _selectedProduct;
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;
  String? _currentSearch;
  int? _selectedCategoryId;
  String? _errorMessage;

  // Getters
  List<Product> get products => _products;
  Product? get selectedProduct => _selectedProduct;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  String? get errorMessage => _errorMessage;
  int get currentPage => _currentPage;

  // ✅ Charger les produits
  Future<void> loadProducts({
    String? search,
    int? categoryId,
    bool refresh = false,
  }) async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;

    if (refresh || search != _currentSearch || categoryId != _selectedCategoryId) {
      _products.clear();
      _currentPage = 1;
      _hasMore = true;
      _currentSearch = search;
      _selectedCategoryId = categoryId;
    }

    notifyListeners();

    try {
      final response = await _productService.getProducts(
        page: _currentPage,
        categoryId: categoryId,
        search: search,
      );

      final newProducts = response['results'] as List<Product>;
      
      if (_currentPage == 1) {
        _products = newProducts;
      } else {
        _products.addAll(newProducts);
      }

      _hasMore = response['hasMore'] ?? false;
      _currentPage++;

    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Erreur chargement produits: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ✅ CRÉER UN PRODUIT avec categoryId corrigé
  Future<bool> createProduct({
    required String nom,
    required String description,
    required String reference,
    required List<Map<String, dynamic>> specifications,
    List<Map<String, dynamic>> images = const [],
    int? categoryId, // ← PARAMÈTRE AJOUTÉ
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newProduct = await _productService.createProduct(
        nom: nom,
        description: description,
        reference: reference,
        categoryId: categoryId, // ← PARAMÈTRE PASSÉ
        images: images,
        specifications: specifications,
      );

      // Ajouter en début de liste
      _products.insert(0, newProduct);
      notifyListeners();
      
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Erreur création produit: $e');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ✅ NOUVELLE MÉTHODE : Mettre à jour un produit
  Future<bool> updateProduct({
    required int productId,
    String? nom,
    String? description,
    String? reference,
    int? categoryId,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Appel du service
      final updatedProduct = await _productService.updateProduct(
        productId,
        nom: nom,
        description: description,
        reference: reference,
      );

      // Mettre à jour le produit dans la liste locale
      final index = _products.indexWhere((product) => product.id == productId);
      if (index != -1) {
        _products[index] = updatedProduct;
      }

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Erreur mise à jour produit: $e');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ✅ Supprimer un produit
  Future<bool> deleteProduct(int productId) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Supprimer via API
      await _productService.deleteProduct(productId);

      // Supprimer localement
      _products.removeWhere((product) => product.id == productId);
      notifyListeners();
      
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Erreur suppression produit: $e');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ✅ Upload d'image
  Future<String?> uploadProductImage(dynamic imageFile) async {
    try {
      return await _productService.uploadImage(imageFile);
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Erreur upload image: $e');
      notifyListeners();
      return null;
    }
  }

  // Rafraîchir les produits
  Future<void> refreshProducts() async {
    await loadProducts(
      search: _currentSearch,
      categoryId: _selectedCategoryId,
      refresh: true,
    );
  }

  // Clear les erreurs
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}