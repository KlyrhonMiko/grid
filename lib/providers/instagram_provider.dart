import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';
import '../models/instagram_user.dart';
import '../models/instagram_post.dart';
import '../services/instagram_service.dart';

class InstagramProvider extends ChangeNotifier {
  static const _tokenKey = 'instagram_access_token';

  String? _accessToken;
  InstagramUser? _user;
  List<InstagramPost> _posts = [];
  bool _isLoading = false;
  bool _initializing = true;
  String? _error;

  String? get accessToken => _accessToken;
  InstagramUser? get user => _user;
  List<InstagramPost> get posts => _posts;
  bool get isLoading => _isLoading;
  bool get initializing => _initializing;
  String? get error => _error;
  bool get isConnected => _accessToken != null && _user != null;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString(_tokenKey);

    if (_accessToken != null) {
      try {
        await _loadUserData();
      } catch (_) {
        await disconnect();
      }
    }

    _initializing = false;
    notifyListeners();
  }

  Future<void> handleAuthCode(String code) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final shortToken = await InstagramService.exchangeCodeForToken(
        code: code,
        clientId: InstagramConfig.clientId,
        clientSecret: InstagramConfig.clientSecret,
        redirectUri: InstagramConfig.redirectUri,
      );

      String token;
      try {
        token = await InstagramService.getLongLivedToken(
          shortLivedToken: shortToken,
          clientSecret: InstagramConfig.clientSecret,
        );
      } catch (_) {
        token = shortToken;
      }

      _accessToken = token;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);

      await _loadUserData();
    } catch (e) {
      _error = 'Failed to connect: $e';
      _accessToken = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadUserData() async {
    final service = InstagramService(_accessToken!);
    _user = await service.getProfile();
    _posts = await service.getMedia();
  }

  Future<void> refresh() async {
    if (_accessToken == null) return;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _loadUserData();
    } catch (e) {
      _error = 'Failed to refresh: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> disconnect() async {
    _accessToken = null;
    _user = null;
    _posts = [];
    _error = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
