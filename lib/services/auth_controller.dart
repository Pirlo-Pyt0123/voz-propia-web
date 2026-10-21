import 'package:flutter/foundation.dart';

import '../models/user.dart';
import '../models/voice_profile.dart';
import 'api_client.dart';
import 'api_exception.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

/// Estado global de sesión + datos básicos del dashboard, expuesto vía
/// provider a toda la app.
class AuthController extends ChangeNotifier {
  final ApiClient api = ApiClient();

  AuthStatus status = AuthStatus.unknown;
  AppUser? currentUser;
  List<VoiceProfile> voiceProfiles = [];
  bool loadingProfiles = false;
  String? lastError;

  Future<void> bootstrap() async {
    await api.loadTokens();
    if (api.isAuthenticated) {
      try {
        await _loadCurrentUser();
        status = AuthStatus.authenticated;
      } catch (_) {
        await api.clearTokens();
        status = AuthStatus.unauthenticated;
      }
    } else {
      status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<void> _loadCurrentUser() async {
    final data = await api.getMe();
    currentUser = AppUser.fromJson(data);
  }

  Future<void> login(String email, String password) async {
    await api.login(email: email, password: password);
    await _loadCurrentUser();
    status = AuthStatus.authenticated;
    notifyListeners();
    await refreshVoiceProfiles();
  }

  Future<void> register(String name, String email, String password) async {
    await api.register(name: name, email: email, password: password);
  }

  Future<void> refreshVoiceProfiles() async {
    loadingProfiles = true;
    notifyListeners();
    try {
      final raw = await api.listVoiceProfiles();
      voiceProfiles = raw.map((e) => VoiceProfile.fromJson(e as Map<String, dynamic>)).toList();
      lastError = null;
    } on ApiException catch (e) {
      lastError = e.message;
    } finally {
      loadingProfiles = false;
      notifyListeners();
    }
  }

  Future<void> createVoiceProfile(String name) async {
    await api.createVoiceProfile(name);
    await refreshVoiceProfiles();
  }

  Future<void> deleteVoiceProfile(int profileId) async {
    await api.deleteVoiceProfile(profileId);
    await refreshVoiceProfiles();
  }

  Future<void> updateProfile({String? name, String? email}) async {
    final data = await api.updateMe(name: name, email: email);
    currentUser = AppUser.fromJson(data);
    notifyListeners();
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await api.changePassword(currentPassword: currentPassword, newPassword: newPassword);
  }

  Future<void> deleteAccount() async {
    await api.deleteAccount();
    await logout();
  }

  Future<void> logout() async {
    await api.clearTokens();
    currentUser = null;
    voiceProfiles = [];
    status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
