import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  String? _userId;
  String? _userEmail;
  String? _userName;
  bool _isLoading = false;

  bool get isAuthenticated => _isAuthenticated;
  String? get userId => _userId;
  String? get userEmail => _userEmail;
  String? get userName => _userName;
  bool get isLoading => _isLoading;

  AuthProvider() {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final email = prefs.getString('user_email');
    final name = prefs.getString('user_name');

    if (token != null && token.isNotEmpty) {
      _isAuthenticated = true;
      _userEmail = email;
      _userName = name;
      notifyListeners();
    }
  }

  Future<void> login(String email, String password) async {
    _setLoading(true);
    
    try {
      // TODO: Implement Firebase authentication
      // For now, simulate login
      await Future.delayed(const Duration(seconds: 2));
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', 'dummy_token');
      await prefs.setString('user_email', email);
      await prefs.setString('user_name', email.split('@').first);
      
      _isAuthenticated = true;
      _userEmail = email;
      _userName = email.split('@').first;
      
    } catch (e) {
      throw Exception('Login failed: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> register(String name, String email, String password) async {
    _setLoading(true);
    
    try {
      // TODO: Implement Firebase registration
      // For now, simulate registration
      await Future.delayed(const Duration(seconds: 2));
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', 'dummy_token');
      await prefs.setString('user_email', email);
      await prefs.setString('user_name', name);
      
      _isAuthenticated = true;
      _userEmail = email;
      _userName = name;
      
    } catch (e) {
      throw Exception('Registration failed: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('user_email');
      await prefs.remove('user_name');
      
      _isAuthenticated = false;
      _userEmail = null;
      _userName = null;
      
    } catch (e) {
      throw Exception('Logout failed: $e');
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
} 