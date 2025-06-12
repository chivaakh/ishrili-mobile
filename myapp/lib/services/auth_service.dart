import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import '../../services/api_client.dart';
// ignore: depend_on_referenced_packages
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final Dio _dio;
  final CookieJar _cookieJar;

  AuthService._internal(this._dio, this._cookieJar);


factory AuthService() {
  final dio = ApiClient.instance;  // utilise l'instance globale
  final cj = CookieJar(); // ou utilise PersistCookieJar comme dans ApiClient
  dio.interceptors.add(CookieManager(cj));
  return AuthService._internal(dio, cj);
}



  Future<void> login(String identifiant, String motDePasse) async {
    final res = await _dio.post(
      '/api/login/',
      data: {
        'identifiant': identifiant,
        'mot_de_passe': motDePasse,
      },
    );
    if (res.statusCode != 200) {
      throw Exception(res.data['error'] ?? 'Échec de la connexion');
    }
  }

  Future<bool> isLoggedIn() async {
    final uri = Uri.parse(_dio.options.baseUrl);
    final cookies = await _cookieJar.loadForRequest(uri);
    return cookies.any((c) => c.name == 'sessionid');
  }

  Future<void> logout() async {
    _cookieJar.deleteAll(); // sync
  }

  Future<void> signup({
    required String prenom,
    String? nom,
    String? email,
    required String telephone,
    required String motDePasse,
  }) async {
    final res = await _dio.post('/api/signup/', data: {
      'prenom': prenom,
      'nom': nom ?? '',
      'email': email ?? '',
      'telephone': telephone,
      'mot_de_passe': motDePasse,
    });
    if (res.statusCode != 201) throw Exception(res.data);
  }

  Future<void> requestPasswordReset(String email) async {
    final res = await _dio.post(
      '/api/request-password-reset/',
      data: {'email': email},
    );
    if (res.statusCode != 200) {
      throw Exception(res.data['error'] ?? 'Erreur reset');
    }
  }

  Future<void> resetPassword(String token, String nouveauMdp) async {
    final res = await _dio.post(
      '/api/reset-password/$token/',
      data: {'mot_de_passe': nouveauMdp},
    );
    if (res.statusCode != 200) {
      throw Exception(res.data['error'] ?? 'Erreur reset');
    }
  }
  Future<void> googleLogin() async {
    final googleUser = await GoogleSignIn(scopes: ['email']).signIn();
    if (googleUser == null) {
      throw Exception('Connexion Google annulée');
    }
    final googleAuth = await googleUser.authentication;
    final idToken = googleAuth.idToken;
    if (idToken == null) {
      throw Exception('Impossible de récupérer le token Google');
    }

    final res = await _dio.post('/api/login/google/', data: {
      'token': idToken,
    });

    if (res.statusCode != 200) {
      // Afficher l'erreur renvoyée par le serveur
      throw Exception(res.data['error'] ?? res.data.toString());
    }
  }
  Future<void> googleLoginWithToken(String idToken) async {
    final res = await ApiClient.instance.post(
      '/api/login/google/',
      data: {'token': idToken},
    );
    if (res.statusCode != 200) {
      throw Exception(res.data['error'] ?? res.data.toString());
    }
  }
  Future<void> signupWithDetails(Map<String, dynamic> userData) async {
  final res = await _dio.post(
    '/api/signup-with-details/',
    data: userData,
  );
  
  if (res.statusCode != 201) {
    throw Exception(res.data['error'] ?? 'Erreur lors de l\'inscription');
  }
}

}
