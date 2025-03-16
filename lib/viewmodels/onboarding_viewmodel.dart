import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/services/navigation_service.dart';
import '../core/constants/app_constants.dart';

class OnboardingViewModel extends ChangeNotifier {
  int _currentPage = 0;
  bool _isLastPage = false;

  int get currentPage => _currentPage;
  bool get isLastPage => _isLastPage;

  void onPageChanged(int page) {
    _currentPage = page;
    _isLastPage = page == AppConstants.walkthroughImages.length - 1;
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);
    NavigationService.replaceTo(AppConstants.loginRoute);
  }

  void skipOnboarding() {
    completeOnboarding();
  }
} 