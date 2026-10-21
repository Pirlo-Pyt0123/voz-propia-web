import 'dart:convert';
import 'dart:typed_data';

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

  Future<Map<String, dynamic>> updateMe({String? name, String? email}) async {
    final res = await http.patch(
      _uri('/users/me'),
      headers: _authHeaders,
      body: jsonEncode({
        if (name != null) 'name': name,
        if (email != null) 'email': email,
      }),
    );
    return _decode(res) as Map<String, dynamic>;
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final res = await http.post(
      _uri('/users/me/change-password'),
      headers: _authHeaders,
      body: jsonEncode({
        'current_password': currentPassword,
        'new_password': newPassword,
      }),
    );
    _decode(res);
  }

  Future<void> deleteAccount() async {
    final res = await http.delete(_uri('/users/me'), headers: _authHeaders);
    _decode(res);
  }

  Future<List<dynamic>> listAdminUsers() async {
    final res = await http.get(_uri('/admin/users'), headers: _authHeaders);
    return _decode(res) as List<dynamic>;
  }

  Future<void> deleteAdminUser(int userId) async {
    final res = await http.delete(_uri('/admin/users/$userId'), headers: _authHeaders);
    _decode(res);
  }

  Future<Map<String, dynamic>> getAdminStats() async {
    final res = await http.get(_uri('/admin/stats'), headers: _authHeaders);
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

  Future<Map<String, dynamic>> getVoiceProfile(int profileId) async {
    final res = await http.get(_uri('/voice-profiles/$profileId'), headers: _authHeaders);
    return _decode(res) as Map<String, dynamic>;
  }

  Future<void> deleteVoiceProfile(int profileId) async {
    final res = await http.delete(_uri('/voice-profiles/$profileId'), headers: _authHeaders);
    _decode(res);
  }

  Future<List<dynamic>> listRecordings(int profileId) async {
    final res = await http.get(_uri('/voice-profiles/$profileId/recordings'), headers: _authHeaders);
    return _decode(res) as List<dynamic>;
  }

  Future<Map<String, dynamic>> uploadRecording({
    required int profileId,
    required String phraseText,
    required Uint8List bytes,
    required String filename,
  }) async {
    final request = http.MultipartRequest('POST', _uri('/voice-profiles/$profileId/recordings'));
    if (_accessToken != null) {
      request.headers['Authorization'] = 'Bearer $_accessToken';
    }
    request.fields['phrase_text'] = phraseText;
    request.files.add(http.MultipartFile.fromBytes('file', bytes, filename: filename));

    final streamedRes = await request.send();
    final res = await http.Response.fromStream(streamedRes);
    return _decode(res) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> trainVoiceProfile(int profileId) async {
    final res = await http.post(_uri('/voice-profiles/$profileId/train'), headers: _authHeaders);
    return _decode(res) as Map<String, dynamic>;
  }

  Future<String> synthesizePhrase(int profileId, String text) async {
    final res = await http.post(
      _uri('/voice-profiles/$profileId/synthesize'),
      headers: _authHeaders,
      body: jsonEncode({'input_text': text}),
    );
    final data = _decode(res) as Map<String, dynamic>;
    return data['task_id'] as String;
  }

  Future<Map<String, dynamic>> getSynthesisStatus(String taskId) async {
    final res = await http.get(_uri('/synthesis/$taskId/status'), headers: _authHeaders);
    return _decode(res) as Map<String, dynamic>;
  }

  Future<List<dynamic>> listPhrases(int profileId) async {
    final res = await http.get(_uri('/voice-profiles/$profileId/phrases'), headers: _authHeaders);
    return _decode(res) as List<dynamic>;
  }

  Future<void> deletePhrase(int profileId, int phraseId) async {
    final res = await http.delete(
      _uri('/voice-profiles/$profileId/phrases/$phraseId'),
      headers: _authHeaders,
    );
    _decode(res);
  }

  Future<void> deleteAllPhrases(int profileId) async {
    final res = await http.delete(
      _uri('/voice-profiles/$profileId/phrases'),
      headers: _authHeaders,
    );
    _decode(res);
  }

  Future<void> ratePhrase(int profileId, int phraseId, int rating) async {
    final res = await http.put(
      _uri('/voice-profiles/$profileId/phrases/$phraseId/rating'),
      headers: _authHeaders,
      body: jsonEncode({'rating': rating}),
    );
    _decode(res);
  }

  /// Baja los bytes de un audio protegido (grabación o frase sintetizada);
  /// `path` es la ruta relativa del endpoint, p. ej.
  /// '/voice-profiles/1/phrases/3/audio'.
  Future<Uint8List> fetchAudioBytes(String path) async {
    final res = await http.get(_uri(path), headers: _authHeaders);
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw ApiException('No se pudo cargar el audio (${res.statusCode}).');
    }
    return res.bodyBytes;
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
