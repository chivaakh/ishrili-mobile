// providers/product_provider.dart - Mettez à jour votre provider existant
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

  // Charger les produits
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