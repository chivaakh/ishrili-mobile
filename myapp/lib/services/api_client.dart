// lib/services/api_client.dart

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:path_provider/path_provider.dart';

class ApiClient {
  /// Le singleton Dio
  static late final Dio instance;

  /// À appeler une seule fois avant runApp()
  static Future<void> init() async {
    // 1) récupère le dossier local pour stocker les cookies
    final dir = await getApplicationDocumentsDirectory();
    final cookiePath = '${dir.path}/.cookies/';
    final cj = PersistCookieJar(storage: FileStorage(cookiePath));

    // 2) instancie Dio avec le CookieManager

instance = Dio(BaseOptions(
  baseUrl: Platform.isAndroid
      ? 'http://10.0.2.2:8000'
      : 'http://127.0.0.1:8000', // ← pour Linux Desktop, Mac, Windows
  connectTimeout: const Duration(milliseconds: 5000),
  receiveTimeout: const Duration(milliseconds: 3000),
))
  ..interceptors.add(CookieManager(cj));

  }
}
