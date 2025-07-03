// models/vendor_model.dart - VERSION FLEXIBLE ✅
import 'user_model.dart';

class Vendor {
  final int id;
  final User? utilisateur; // ← Rendu optionnel
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
    this.utilisateur, // ← Rendu optionnel
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

  // ✅ CONSTRUCTEUR BASIQUE pour les cas où on n'a que l'ID
  factory Vendor.fromId(int id) {
    return Vendor(
      id: id,
      utilisateur: null,
      nomBoutique: 'Boutique #$id',
      descriptionBoutique: '',
      adresseCommerciale: '',
      ville: '',
      codePostal: '',
      pays: '',
      estVerifie: false,
      noteMoyenne: 0.0,
      commissionRate: 0.0,
    );
  }

  factory Vendor.fromJson(Map<String, dynamic> json) {
    return Vendor(
      id: json['id'] ?? 0,
      
      // ✅ GESTION FLEXIBLE de l'utilisateur
      utilisateur: json['utilisateur'] != null 
          ? User.fromJson(json['utilisateur'])
          : null,
          
      nomBoutique: json['nom_boutique'] ?? '',
      descriptionBoutique: json['description_boutique'] ?? '',
      adresseCommerciale: json['adresse_commerciale'] ?? '',
      ville: json['ville'] ?? '',
      codePostal: json['code_postal'] ?? '',
      pays: json['pays'] ?? '',
      estVerifie: json['est_verifie'] ?? false,
      
      // ✅ PARSING SÉCURISÉ des nombres
      noteMoyenne: _parseDouble(json['note_moyenne']),
      commissionRate: _parseDouble(json['commission_rate']),
    );
  }

  // ✅ MÉTHODE HELPER pour parser les doubles
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (utilisateur != null) 'utilisateur': utilisateur!.toJson(),
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

  // ✅ GETTERS pour la compatibilité avec l'ancien code
  String get nom => utilisateur?.nom ?? nomBoutique;
  String get email => utilisateur?.email ?? '';
  String get telephone => utilisateur?.telephone ?? '';
}