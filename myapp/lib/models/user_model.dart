// models/user_model.dart
class User {
  final int id;
  final String email;
  final String telephone;
  final String role;
  final bool estActif;
  final DateTime dateInscription;
  final DateTime? derniereConnexion;

  User({
    required this.id,
    required this.email,
    required this.telephone,
    required this.role,
    required this.estActif,
    required this.dateInscription,
    this.derniereConnexion,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      telephone: json['telephone'],
      role: json['role'],
      estActif: json['est_actif'] ?? true,
      dateInscription: DateTime.parse(json['date_inscription']),
      derniereConnexion: json['derniere_connexion'] != null 
          ? DateTime.parse(json['derniere_connexion']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'telephone': telephone,
      'role': role,
      'est_actif': estActif,
      'date_inscription': dateInscription.toIso8601String(),
      'derniere_connexion': derniereConnexion?.toIso8601String(),
    };
  }
}
