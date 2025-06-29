// services/api_service.dart - VERSION FINALE CORRIGÉE ✅
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart' as http_parser; // ✅ AJOUT pour MediaType
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import '../config/api_config.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Headers par défaut SANS authentification obligatoire
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Headers avec authentification OPTIONNELLE
  Future<Map<String, String>> get _authHeaders async {
    final token = await _getToken();
    return {
      ..._headers,
      // ✅ ONLY add auth header if token exists
      if (token != null && token.isNotEmpty) 'Authorization': 'Token $token',
    };
  }

  // Récupération du token stocké
  Future<String?> _getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('auth_token');
    } catch (e) {
      debugPrint('⚠️ Erreur récupération token: $e');
      return null;
    }
  }

  // Suppression du token (déconnexion)
  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // GET Request
  Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      debugPrint('🌐 GET: ${ApiConfig.baseUrl}$endpoint');
      
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}$endpoint'),
        headers: await _authHeaders,
      ).timeout(ApiConfig.timeout);
      
      return _handleResponse(response);
    } catch (e) {
      debugPrint('❌ Erreur GET: $e');
      throw Exception('Erreur réseau: $e');
    }
  }

  // POST Request
  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data) async {
    try {
      debugPrint('🌐 POST: ${ApiConfig.baseUrl}$endpoint');
      debugPrint('📋 Data: $data');
      
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}$endpoint'),
        headers: await _authHeaders,
        body: jsonEncode(data),
      ).timeout(ApiConfig.timeout);
      
      return _handleResponse(response);
    } catch (e) {
      debugPrint('❌ Erreur POST: $e');
      throw Exception('Erreur réseau: $e');
    }
  }

  // PUT Request
  Future<Map<String, dynamic>> put(String endpoint, Map<String, dynamic> data) async {
    try {
      debugPrint('🌐 PUT: ${ApiConfig.baseUrl}$endpoint');
      
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}$endpoint'),
        headers: await _authHeaders,
        body: jsonEncode(data),
      ).timeout(ApiConfig.timeout);
      
      return _handleResponse(response);
    } catch (e) {
      debugPrint('❌ Erreur PUT: $e');
      throw Exception('Erreur réseau: $e');
    }
  }

  // DELETE Request
  Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      debugPrint('🌐 DELETE: ${ApiConfig.baseUrl}$endpoint');
      
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}$endpoint'),
        headers: await _authHeaders,
      ).timeout(ApiConfig.timeout);
      
      return _handleResponse(response);
    } catch (e) {
      debugPrint('❌ Erreur DELETE: $e');
      throw Exception('Erreur réseau: $e');
    }
  }

  // ✅ UPLOAD IMAGE CORRIGÉ AVEC VALIDATION
  Future<Map<String, dynamic>> uploadImage(String endpoint, File imageFile) async {
    try {
      debugPrint('📸 Upload image vers: ${ApiConfig.baseUrl}$endpoint');
      debugPrint('📁 Fichier: ${imageFile.path}');
      
      // ✅ Vérifier que le fichier existe
      if (!await imageFile.exists()) {
        throw Exception('Le fichier image n\'existe pas');
      }
      
      // ✅ Obtenir la taille du fichier
      final fileSize = await imageFile.length();
      debugPrint('📏 Taille: $fileSize bytes');
      
      // ✅ Vérifier l'extension du fichier
      final fileExtension = path.extension(imageFile.path).toLowerCase();
      debugPrint('📄 Extension: $fileExtension');
      
      // ✅ Vérifier que c'est une image supportée
      final supportedExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp'];
      if (!supportedExtensions.contains(fileExtension)) {
        throw Exception('Format d\'image non supporté: $fileExtension');
      }
      
      // ✅ Déterminer le bon MIME type
      String mimeType;
      switch (fileExtension) {
        case '.jpg':
        case '.jpeg':
          mimeType = 'image/jpeg';
          break;
        case '.png':
          mimeType = 'image/png';
          break;
        case '.gif':
          mimeType = 'image/gif';
          break;
        case '.bmp':
          mimeType = 'image/bmp';
          break;
        case '.webp':
          mimeType = 'image/webp';
          break;
        default:
          mimeType = 'image/jpeg';
      }
      
      debugPrint('🎨 MIME Type: $mimeType');
      
      // ✅ Créer la requête multipart
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}$endpoint'),
      );
      
      // ✅ Headers OPTIONNELS avec token si disponible
      final token = await _getToken();
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Token $token';
        debugPrint('🔑 Token ajouté');
      } else {
        debugPrint('🔓 Pas de token - requête sans auth');
      }
      
      // ✅ Ajouter le fichier avec le bon nom de champ ET le bon MIME type
      final multipartFile = http.MultipartFile(
        'image', // ✅ Nom du champ attendu par l'API
        imageFile.readAsBytes().asStream(),
        await imageFile.length(),
        filename: path.basename(imageFile.path),
        contentType: http_parser.MediaType.parse(mimeType), // ✅ CORRECTION: Forcer le bon MIME type
      );
      
      request.files.add(multipartFile);
      debugPrint('📎 Fichier ajouté: ${multipartFile.filename}');
      debugPrint('📎 Taille: ${multipartFile.length} bytes');
      debugPrint('📎 Type: ${multipartFile.contentType}');
      
      debugPrint('⏳ Envoi de la requête...');
      
      // ✅ Envoyer la requête avec timeout
      final streamedResponse = await request.send().timeout(ApiConfig.timeout);
      final response = await http.Response.fromStream(streamedResponse);
      
      debugPrint('📡 Réponse reçue: ${response.statusCode}');
      debugPrint('📄 Corps: ${response.body}');
      
      return _handleResponse(response);
      
    } catch (e) {
      debugPrint('❌ Exception upload image: $e');
      if (e is Exception) {
        rethrow;
      } else {
        throw Exception('Erreur lors de l\'upload: $e');
      }
    }
  }

  // ✅ Gestion des réponses AMÉLIORÉE
  Map<String, dynamic> _handleResponse(http.Response response) {
    debugPrint('📊 Status Code: ${response.statusCode}');
    debugPrint('📄 Response Body: ${response.body}');
    
    try {
      final data = jsonDecode(response.body);
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        debugPrint('✅ Succès');
        return data;
      } else if (response.statusCode == 401) {
        debugPrint('🔐 Erreur 401 - Non autorisé');
        clearToken(); // Token expiré
        throw Exception('Session expirée. Veuillez vous reconnecter.');
      } else if (response.statusCode == 403) {
        debugPrint('🚫 Erreur 403 - Interdit');
        throw Exception('Accès interdit.');
      } else if (response.statusCode == 404) {
        debugPrint('🔍 Erreur 404 - Non trouvé');
        throw Exception('Ressource non trouvée.');
      } else {
        debugPrint('❌ Erreur ${response.statusCode}');
        final errorMessage = data['error'] ?? data['message'] ?? 'Erreur serveur';
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (e.toString().contains('Session expirée')) {
        rethrow;
      }
      debugPrint('❌ Erreur parsing JSON: $e');
      throw Exception('Erreur de communication avec le serveur');
    }
  }
}