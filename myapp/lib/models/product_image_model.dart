// models/product_image_model.dart
class ProductImage {
  final int id;
  final int produitId;
  final String urlImage;
  final bool estPrincipale;
  final int ordre;
  final DateTime dateAjout;

  ProductImage({
    required this.id,
    required this.produitId,
    required this.urlImage,
    required this.estPrincipale,
    required this.ordre,
    required this.dateAjout,
  });

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    return ProductImage(
      id: json['id'],
      produitId: json['produit'],
      urlImage: json['url_image'],
      estPrincipale: json['est_principale'] ?? false,
      ordre: json['ordre'] ?? 0,
      dateAjout: DateTime.parse(json['date_ajout']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'produit': produitId,
      'url_image': urlImage,
      'est_principale': estPrincipale,
      'ordre': ordre,
      'date_ajout': dateAjout.toIso8601String(),
    };
  }
}
