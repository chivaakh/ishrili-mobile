// models/user_model.dart - VERSION CORRIGÉE ✅
class User {
  final int id;
  final String email;
  final String telephone;
  final String role;
  final bool estActif;
  final DateTime dateInscription;
  final DateTime? derniereConnexion;
  
  // ✅ AJOUT: Champs pour le nom (optionnels selon votre API)
  final String? prenom;
  final String? nomFamille;
  final String? username;

  User({
    required this.id,
    required this.email,
    required this.telephone,
    required this.role,
    required this.estActif,
    required this.dateInscription,
    this.derniereConnexion,
    this.prenom,
    this.nomFamille,
    this.username,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      email: json['email'] ?? '',
      telephone: json['telephone'] ?? '',
      role: json['role'] ?? '',
      estActif: json['est_actif'] ?? true,
      
      // ✅ PARSING SÉCURISÉ des dates
      dateInscription: _parseDate(json['date_inscription']),
      derniereConnexion: json['derniere_connexion'] != null 
          ? _parseDate(json['derniere_connexion'])
          : null,
          
      // ✅ AJOUT: Parsing des champs nom
      prenom: json['prenom'] ?? json['first_name'],
      nomFamille: json['nom_famille'] ?? json['last_name'],
      username: json['username'] ?? json['nom_utilisateur'],
    );
  }

  // ✅ MÉTHODE HELPER: Parse date de manière sécurisée
  static DateTime _parseDate(dynamic dateData) {
    if (dateData == null) return DateTime.now();
    
    if (dateData is String) {
      try {
        return DateTime.parse(dateData);
      } catch (e) {
        return DateTime.now();
      }
    }
    
    return DateTime.now();
  }

  // ✅ GETTER NOM REQUIS pour Vendor
  String get nom {
    if (prenom != null && nomFamille != null) {
      return '$prenom $nomFamille'.trim();
    } else if (username != null && username!.isNotEmpty) {
      return username!;
    } else if (prenom != null && prenom!.isNotEmpty) {
      return prenom!;
    } else {
      // Fallback: utiliser le début de l'email
      return email.split('@').first;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'telephone': telephone,
      'role': role,
      'est_actif': estActif,
      'date_inscription': dateInscription.toIso8601String(),
      if (derniereConnexion != null) 
        'derniere_connexion': derniereConnexion!.toIso8601String(),
      if (prenom != null) 'prenom': prenom,
      if (nomFamille != null) 'nom_famille': nomFamille,
      if (username != null) 'username': username,
    };
  }
}