import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_config.dart';
import 'api_exception.dart';

/// Cliente HTTP para el backend de Voz Propia. Guarda los tokens JWT en
/// SharedPreferences y arma los headers de autenticación.
class ApiClient {
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';

  String? _accessToken;
  // Guardado para el flujo de POST /auth/refresh, que todavía no está
  // conectado en esta primera versión del front.
  // ignore: unused_field
  String? _refreshToken;

  bool get isAuthenticated => _accessToken != null;

  Future<void> loadTokens() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString(_accessTokenKey);
    _refreshToken = prefs.getString(_refreshTokenKey);
  }

  Future<void> _saveTokens(String access, String refresh) async {
    _accessToken = access;
    _refreshToken = refresh;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, access);
    await prefs.setString(_refreshTokenKey, refresh);
  }

  Future<void> clearTokens() async {
    _accessToken = null;
    _refreshToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
  }

  Uri _uri(String path) => Uri.parse('${ApiConfig.baseUrl}$path');

  Map<String, String> get _authHeaders => {
        'Content-Type': 'application/json',
        if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
      };

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final res = await http.post(
      _uri('/auth/register'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );
    return _decode(res) as Map<String, dynamic>;
  }

  Future<void> login({required String email, required String password}) async {
    final res = await http.post(
      _uri('/auth/login'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    final data = _decode(res) as Map<String, dynamic>;
    await _saveTokens(data['access_token'] as String, data['refresh_token'] as String);
  }

  Future<Map<String, dynamic>> getMe() async {
    final res = await http.get(_uri('/users/me'), headers: _authHeaders);
    return _decode(res) as Map<String, dynamic>;
  }

  Future<List<dynamic>> listVoiceProfiles() async {
    final res = await http.get(_uri('/voice-profiles'), headers: _authHeaders);
    return _decode(res) as List<dynamic>;
  }

  Future<Map<String, dynamic>> createVoiceProfile(String profileName) async {
    final res = await http.post(
      _uri('/voice-profiles'),
      headers: _authHeaders,
      body: jsonEncode({'profile_name': profileName}),
    );
    return _decode(res) as Map<String, dynamic>;
  }

  dynamic _decode(http.Response res) {
    final rawBody = res.body.isEmpty ? '{}' : res.body;
    final decoded = jsonDecode(rawBody);

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return decoded;
    }

    final detail = (decoded is Map && decoded['detail'] != null)
        ? decoded['detail'].toString()
        : 'Error inesperado (${res.statusCode}).';
    throw ApiException(detail);
  }
}
