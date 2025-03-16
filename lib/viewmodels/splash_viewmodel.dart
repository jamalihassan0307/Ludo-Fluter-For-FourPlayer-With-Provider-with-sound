import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';
import '../core/services/navigation_service.dart';
import '../core/services/storage_service.dart';

class SplashViewModel extends ChangeNotifier {
  Future<void> initializeApp() async {
    await Future.delayed(AppConstants.splashDuration);

    // Check if user has seen onboarding
    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

    // Check for saved game state
    final savedGameState = StorageService.getGameState();
    if (savedGameState != null) {
      // Handle saved game state
      print('Found saved game state: $savedGameState');
    }

    if (hasSeenOnboarding) {
      NavigationService.replaceTo(AppConstants.loginRoute);
    } else {
      NavigationService.replaceTo(AppConstants.onboardingRoute);
    }
  }
}
