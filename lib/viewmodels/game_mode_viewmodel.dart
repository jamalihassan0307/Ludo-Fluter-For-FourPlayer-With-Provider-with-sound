import 'package:flutter/material.dart';
import '../core/services/navigation_service.dart';
import '../core/constants/app_constants.dart';
import '../core/services/storage_service.dart';

class GameModeViewModel extends ChangeNotifier {
  void startLocalMultiplayer() {
    NavigationService.navigateTo(AppConstants.gameRoute);
  }

  void startComputerGame() {
    // Set game mode as computer in storage
    StorageService.getSettingsBox().put('gameMode', 'computer');
    NavigationService.navigateTo(AppConstants.gameRoute);
  }

  void startOnlineMultiplayer() {
    // Show coming soon dialog
  }
} 