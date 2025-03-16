import 'package:flutter/material.dart';
import '../data/repositories/user_repository.dart';
import '../data/models/user_model.dart';

class HomeViewModel extends ChangeNotifier {
  final UserRepository _userRepository = UserRepository();
  List<UserModel> _onlinePlayers = [];
  bool _isLoading = false;

  List<UserModel> get onlinePlayers => _onlinePlayers;
  bool get isLoading => _isLoading;

  Future<void> updateUserStats(String userId, {bool won = false}) async {
    await _userRepository.updateStats(userId, won: won);
  }
} 