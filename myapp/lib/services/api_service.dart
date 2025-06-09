// services/api_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Headers par défaut
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Headers avec authentification
  Future<Map<String, String>> get _authHeaders async {
    final token = await _getToken();
    return {
      ..._headers,
      if (token != null) 'Authorization': 'Token $token',
    };
  }

  // Récupération du token stocké
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Sauvegarde du token
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  // Suppression du token (déconnexion)
  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // GET Request
  Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}$endpoint'),
        headers: await _authHeaders,
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  // POST Request
  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}$endpoint'),
        headers: await _authHeaders,
        body: jsonEncode(data),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  // PUT Request
  Future<Map<String, dynamic>> put(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}$endpoint'),
        headers: await _authHeaders,
        body: jsonEncode(data),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  // DELETE Request
  Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}$endpoint'),
        headers: await _authHeaders,
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  // Upload d'image
  Future<Map<String, dynamic>> uploadImage(String endpoint, File imageFile) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}$endpoint'),
      );
      
      // Ajouter les headers d'authentification
      final headers = await _authHeaders;
      request.headers.addAll(headers);
      
      // Ajouter le fichier
      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Erreur upload: $e');
    }
  }

  // Gestion des réponses
  Map<String, dynamic> _handleResponse(http.Response response) {
    final data = jsonDecode(response.body);
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else if (response.statusCode == 401) {
      clearToken(); // Token expiré
      throw Exception('Session expirée. Veuillez vous reconnecter.');
    } else {
      throw Exception(data['message'] ?? 'Erreur serveur');
    }
  }
}