// lib/providers/auth_provider.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
    ],
  );

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
    _auth.authStateChanges().listen((User? user) {
      if (user == null) {
        // User is signed out
        _isAuthenticated = false;
        _userId = null;
        _userEmail = null;
        _userName = null;
      } else {
        // User is signed in
        _isAuthenticated = true;
        _userId = user.uid;
        _userEmail = user.email;
        _userName = user.displayName ?? user.email?.split('@').first;
      }
      notifyListeners();
    });
  }

  Future<void> login(String email, String password) async {
    _setLoading(true);
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', userCredential.user!.uid);
      // The authStateChanges listener will handle updating the UI
    } on FirebaseAuthException catch (e) {
      throw Exception(_getFirebaseErrorMessage(e.code));
    } finally {
      _setLoading(false);
    }
  }

  Future<void> register(String name, String email, String password) async {
    _setLoading(true);
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await userCredential.user!.updateDisplayName(name);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', userCredential.user!.uid);
      // The authStateChanges listener will handle updating the UI
    } on FirebaseAuthException catch (e) {
      throw Exception(_getFirebaseErrorMessage(e.code));
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signInWithGoogle() async {
    _setLoading(true);
    try {
      print('Starting Google Sign-In process...');
      
      // Check if user is already signed in
      if (await _googleSignIn.isSignedIn()) {
        print('User already signed in, signing out first...');
        await _googleSignIn.signOut();
      }
      
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        print('User canceled Google Sign-In');
        _setLoading(false);
        return;
      }

      print('Google user obtained: ${googleUser.email}');
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      print('Google authentication tokens obtained');
      
      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        print('Failed to get authentication tokens');
        throw Exception('Failed to get Google authentication tokens');
      }
      
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      print('Attempting to sign in with Firebase...');
      final userCredential = await _auth.signInWithCredential(credential);
      print('Firebase sign-in successful: ${userCredential.user?.email}');

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', userCredential.user!.uid);

      // The authStateChanges listener will handle updating the UI
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Exception: ${e.code} - ${e.message}');
      String errorMessage = _getFirebaseErrorMessage(e.code);
      
      // Handle Google-specific Firebase errors
      switch (e.code) {
        case 'account-exists-with-different-credential':
          errorMessage = 'An account already exists with the same email address but different sign-in credentials.';
          break;
        case 'invalid-credential':
          errorMessage = 'The provided credential is invalid or expired.';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Google sign-in is not enabled. Please contact support.';
          break;
        case 'user-disabled':
          errorMessage = 'This user account has been disabled.';
          break;
        case 'user-not-found':
          errorMessage = 'No user found with these credentials.';
          break;
        case 'network-request-failed':
          errorMessage = 'Network error. Please check your internet connection.';
          break;
        default:
          errorMessage = 'Authentication failed: ${e.message}';
      }
      
      throw Exception(errorMessage);
    } catch (e) {
      print('Google Sign-In Exception: $e');
      String errorMessage = 'Google Sign-in failed';
      
      if (e.toString().contains('network')) {
        errorMessage = 'Network error. Please check your internet connection.';
      } else if (e.toString().contains('cancelled')) {
        errorMessage = 'Sign-in was cancelled.';
      } else if (e.toString().contains('developer') || e.toString().contains('ApiException: 10')) {
        errorMessage = 'Configuration error: Please verify your Firebase project settings, SHA-1 fingerprint, and package name.';
      } else if (e.toString().contains('sign_in_failed')) {
        errorMessage = 'Sign-in failed. Please check your internet connection and try again.';
      } else {
        errorMessage = 'Google Sign-in failed: $e';
      }
      
      throw Exception(errorMessage);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('user_email');
      await prefs.remove('user_name');

      // The authStateChanges listener will handle updating the UI
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

  String _getFirebaseErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided for that user.';
      case 'email-already-in-use':
        return 'The email address is already in use by another account.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      case 'weak-password':
        return 'The password provided is too weak.';
      default:
        return 'An unknown error occurred. Please try again.';
    }
  }
}