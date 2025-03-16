import 'package:flutter/material.dart';
import '../data/repositories/auth_repository.dart';
import '../data/models/user_model.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();
  UserModel? _currentUser;
  bool _isLoading = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;

  Future<bool> signInWithEmail(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentUser = await _authRepository.signInWithEmail(email, password);
      _isLoading = false;
      notifyListeners();
      return _currentUser != null;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await _authRepository.signOut();
    _currentUser = null;
    notifyListeners();
  }
} 