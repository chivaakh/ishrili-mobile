// models/product_specification_model.dart
class ProductSpecification {
  final int id;
  final int produitId;
  final String nom;
  final String description;
  final double prix;
  final double? prixPromo;
  final int quantiteStock;
  final bool estDefaut;
  final String referenceSpecification;

  ProductSpecification({
    required this.id,
    required this.produitId,
    required this.nom,
    required this.description,
    required this.prix,
    this.prixPromo,
    required this.quantiteStock,
    required this.estDefaut,
    required this.referenceSpecification,
  });

  factory ProductSpecification.fromJson(Map<String, dynamic> json) {
    return ProductSpecification(
      id: json['id'],
      produitId: json['produit'],
      nom: json['nom'],
      description: json['description'],
      prix: double.parse(json['prix'].toString()),
      prixPromo: json['prix_promo'] != null 
          ? double.parse(json['prix_promo'].toString()) 
          : null,
      quantiteStock: json['quantite_stock'],
      estDefaut: json['est_defaut'] ?? false,
      referenceSpecification: json['reference_specification'],
    );
  }

  // Prix final (promo si disponible, sinon prix normal)
  double get finalPrice => prixPromo ?? prix;
  
  // Y a-t-il une promotion ?
  bool get hasPromo => prixPromo != null && prixPromo! < prix;
  
  // Stock disponible ?
  bool get inStock => quantiteStock > 0;
}
