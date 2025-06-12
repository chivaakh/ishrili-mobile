import 'package:flutter/material.dart';
import '../services/auth_service.dart';

/// Provider pour gérer l'état d'authentification via session Django
class AuthProvider extends ChangeNotifier {
  final AuthService _auth = AuthService();
  bool _loggedIn = false;

  bool get loggedIn => _loggedIn;

  /// Vérifie si un cookie de session existe et met à jour l'état
  Future<void> checkLogin() async {
    _loggedIn = await _auth.isLoggedIn();
    notifyListeners();
  }

  /// Appelle le login, puis vérifie l'état
  Future<void> login(String identifiant, String motDePasse) async {
    await _auth.login(identifiant, motDePasse);
    await checkLogin();
  }

  /// Déconnexion : supprime les cookies et met à jour l'état
  Future<void> logout() async {
    await _auth.logout();
    _loggedIn = false;
    notifyListeners();
  }
}
