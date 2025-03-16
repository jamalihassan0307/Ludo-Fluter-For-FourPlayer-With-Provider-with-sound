import 'package:flutter/material.dart';
import '../data/repositories/user_repository.dart';
import '../data/models/user_model.dart';

class ProfileViewModel extends ChangeNotifier {
  final UserRepository _userRepository = UserRepository();
  UserModel? _userProfile;
  bool _isLoading = false;

  UserModel? get userProfile => _userProfile;
  bool get isLoading => _isLoading;

  Future<void> loadUserProfile(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _userProfile = await _userRepository.getUser(userId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }
} 