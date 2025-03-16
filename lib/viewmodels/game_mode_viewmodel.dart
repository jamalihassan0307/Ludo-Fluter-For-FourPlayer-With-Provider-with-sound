import 'package:flutter/material.dart';
import '../core/services/navigation_service.dart';
import '../core/constants/app_constants.dart';
import '../core/services/storage_service.dart';

class GameModeViewModel extends ChangeNotifier {
  void startLocalMultiplayer() {
    StorageService.getSettingsBox().put('gameMode', 'local');
    NavigationService.navigateTo(AppConstants.lobbyRoute);
  }

  void startComputerGame() {
    StorageService.getSettingsBox().put('gameMode', 'computer');
    NavigationService.navigateTo(AppConstants.lobbyRoute);
  }

  void startOnlineMultiplayer() {
    // Show coming soon dialog
  }
} 