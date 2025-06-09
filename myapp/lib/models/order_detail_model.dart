import 'product_specification_model.dart';

class OrderDetail {
  final int id;
  final int commandeId;
  final ProductSpecification specification;
  final int quantite;
  final double prixUnitaire;

  OrderDetail({
    required this.id,
    required this.commandeId,
    required this.specification,
    required this.quantite,
    required this.prixUnitaire,
  });

  factory OrderDetail.fromJson(Map<String, dynamic> json) {
    return OrderDetail(
      id: json['id'],
      commandeId: json['commande'],
      specification: ProductSpecification.fromJson(json['specification']),
      quantite: json['quantite'],
      prixUnitaire: double.parse(json['prix_unitaire'].toString()),
    );
  }

  double get total => prixUnitaire * quantite;
}