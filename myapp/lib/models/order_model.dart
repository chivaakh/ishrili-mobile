import 'order_detail_model.dart';

class Order {
  final int id;
  final int clientId;
  final DateTime dateCommande;
  final double montantTotal;
  final String statut;
  final List<OrderDetail> details;

  Order({
    required this.id,
    required this.clientId,
    required this.dateCommande,
    required this.montantTotal,
    required this.statut,
    this.details = const [],
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      clientId: json['client'],
      dateCommande: DateTime.parse(json['date_commande']),
      montantTotal: double.parse(json['montant_total'].toString()),
      statut: json['statut'],
      details: (json['details'] as List?)
          ?.map((detail) => OrderDetail.fromJson(detail))
          .toList() ?? [],
    );
  }
}