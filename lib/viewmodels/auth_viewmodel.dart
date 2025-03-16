import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../core/services/navigation_service.dart';
import '../core/constants/app_constants.dart';
import '../data/repositories/auth_repository.dart';
import '../data/models/user_model.dart';
import '../core/services/storage_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  bool _isLoading = false;
  bool _isLogin = true;
  String? _error;

  bool get isLoading => _isLoading;
  bool get isLogin => _isLogin;
  String? get error => _error;

  void toggleAuthMode() {
    _isLogin = !_isLogin;
    _error = null;
    notifyListeners();
  }

  Future<void> signInWithEmail(String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _authRepository.signInWithEmail(email, password);

      // Save user after successful login
      await StorageService.saveUser(UserModel(
        id: 'user_id',
        name: 'User Name',
        email: email,
      ));

      NavigationService.replaceTo(AppConstants.homeRoute);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signUpWithEmail(String email, String password, String name) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _authRepository.signUpWithEmail(email, password, name);
      NavigationService.replaceTo(AppConstants.homeRoute);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        await _authRepository.createUserFromGoogle(userCredential.user!);
        NavigationService.replaceTo(AppConstants.homeRoute);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
