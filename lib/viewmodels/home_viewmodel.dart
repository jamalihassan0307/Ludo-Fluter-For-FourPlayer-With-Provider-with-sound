import 'package:flutter/material.dart';
import '../data/repositories/user_repository.dart';
import '../data/models/user_model.dart';
import '../core/services/navigation_service.dart';
import '../core/constants/app_constants.dart';
import '../core/services/storage_service.dart';

class HomeViewModel extends ChangeNotifier {
  final UserRepository _userRepository = UserRepository();
  List<UserModel> _onlinePlayers = [];
  bool _isLoading = false;

  List<UserModel> get onlinePlayers => _onlinePlayers;
  bool get isLoading => _isLoading;

  Future<void> updateUserStats(String userId, {bool won = false}) async {
    await _userRepository.updateStats(userId, won: won);
  }

  Future<void> startNewGame() async {
    // Clear any existing game state
    await StorageService.clearGameState();
    NavigationService.navigateTo(AppConstants.gameModeRoute);
  }

  void joinGame() {
    // Will implement in multiplayer feature
    // For now, show coming soon
  }

  void openSettings() {
    NavigationService.navigateTo(AppConstants.settingsRoute);
  }

  void continueGame() {
    final savedGame = StorageService.getGameState();
    if (savedGame != null) {
      NavigationService.navigateTo(AppConstants.gameRoute);
    }
  }

  bool get hasSavedGame => StorageService.getGameState() != null;
} 