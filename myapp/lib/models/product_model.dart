// models/product_model.dart
import 'category_model.dart';
import 'vendor_model.dart';
import 'product_image_model.dart';
import 'product_specification_model.dart';

class Product {
  final int id;
  final String reference;
  final String nom;
  final String description;
  final Category? categorie;
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
      reference: json['reference'],
      nom: json['nom'],
      description: json['description'],
      categorie: json['categorie'] != null 
          ? Category.fromJson(json['categorie']) 
          : null,
      commercant: json['commercant'] != null 
          ? Vendor.fromJson(json['commercant']) 
          : null,
      images: (json['images'] as List?)
          ?.map((img) => ProductImage.fromJson(img))
          .toList() ?? [],
      specifications: (json['specifications'] as List?)
          ?.map((spec) => ProductSpecification.fromJson(spec))
          .toList() ?? [],
    );
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