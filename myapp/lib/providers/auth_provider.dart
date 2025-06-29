import 'package:flutter/material.dart';
import '../services/auth_service.dart';

/// Provider pour gérer l'état d'authentification via session Django
class AuthProvider extends ChangeNotifier {
  final AuthService _auth = AuthService();
  bool _loggedIn = false;
  bool _isLoading = true; // ✅ Ajout de isLoading

  bool get loggedIn => _loggedIn;
  bool get isLoading => _isLoading; // ✅ Getter pour isLoading

  /// Vérifie si un cookie de session existe et met à jour l'état
  Future<void> checkLogin() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      print('🔍 DEBUG: Vérification du login...');
      _loggedIn = await _auth.isLoggedIn();
      print('🔍 DEBUG: loggedIn = $_loggedIn');
    } catch (e) {
      print('❌ DEBUG: Erreur checkLogin: $e');
      _loggedIn = false;
    }
    
    _isLoading = false;
    notifyListeners();
  }

  /// Appelle le login, puis vérifie l'état
  Future<void> login(String identifiant, String motDePasse) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _auth.login(identifiant, motDePasse);
      await checkLogin();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Déconnexion : supprime les cookies et met à jour l'état
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    
    await _auth.logout();
    _loggedIn = false;
    _isLoading = false;
    notifyListeners();
  }

  /// Méthode pour forcer la déconnexion (utile pour débugger)
  void forceLogout() {
    _loggedIn = false;
    print('🔍 DEBUG: Force logout - loggedIn = $_loggedIn');
    notifyListeners();
  }
}