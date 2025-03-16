import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';
import '../core/services/navigation_service.dart';
import '../core/services/storage_service.dart';

class SplashViewModel extends ChangeNotifier {
  Future<void> initializeApp() async {
    await Future.delayed(AppConstants.splashDuration);

    if (StorageService.isUserLoggedIn()) {
      NavigationService.replaceTo(AppConstants.homeRoute);
    } else {
      NavigationService.replaceTo(AppConstants.onboardingRoute);
    }
  }
}
