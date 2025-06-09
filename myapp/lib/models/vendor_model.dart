// models/vendor_model.dart
import 'user_model.dart';  // ← AJOUTEZ CETTE LIGNE

class Vendor {
  final int id;
  final User utilisateur;
  final String nomBoutique;
  final String descriptionBoutique;
  final String adresseCommerciale;
  final String ville;
  final String codePostal;
  final String pays;
  final bool estVerifie;
  final double noteMoyenne;
  final double commissionRate;

  Vendor({
    required this.id,
    required this.utilisateur,
    required this.nomBoutique,
    required this.descriptionBoutique,
    required this.adresseCommerciale,
    required this.ville,
    required this.codePostal,
    required this.pays,
    required this.estVerifie,
    required this.noteMoyenne,
    required this.commissionRate,
  });

  factory Vendor.fromJson(Map<String, dynamic> json) {
    return Vendor(
      id: json['id'],
      utilisateur: User.fromJson(json['utilisateur']),
      nomBoutique: json['nom_boutique'],
      descriptionBoutique: json['description_boutique'],
      adresseCommerciale: json['adresse_commerciale'],
      ville: json['ville'],
      codePostal: json['code_postal'],
      pays: json['pays'],
      estVerifie: json['est_verifie'] ?? false,
      noteMoyenne: double.parse(json['note_moyenne'].toString()),
      commissionRate: double.parse(json['commission_rate'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'utilisateur': utilisateur.toJson(),
      'nom_boutique': nomBoutique,
      'description_boutique': descriptionBoutique,
      'adresse_commerciale': adresseCommerciale,
      'ville': ville,
      'code_postal': codePostal,
      'pays': pays,
      'est_verifie': estVerifie,
      'note_moyenne': noteMoyenne,
      'commission_rate': commissionRate,
    };
  }
}