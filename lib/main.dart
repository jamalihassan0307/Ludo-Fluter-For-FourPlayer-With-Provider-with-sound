import 'package:flutter/material.dart';
import 'package:ludo_flutter/core/constants/app_constants.dart';
// import 'package:flutter/scheduler.dart';
import 'package:ludo_flutter/core/services/navigation_service.dart';
import 'package:provider/provider.dart';
// import 'package:ludo_flutter/main_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:ludo_flutter/core/services/storage_service.dart';
import 'ui/views/splash/splash_view.dart';
import 'ui/views/onboarding/onboarding_view.dart';
import 'viewmodels/splash_viewmodel.dart';
import 'viewmodels/onboarding_viewmodel.dart';
import 'ui/views/auth/auth_view.dart';
import 'ui/views/home/home_view.dart';
import 'ui/views/game/game_mode_view.dart';

import 'ludo_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize Hive
  await StorageService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SplashViewModel()),
        ChangeNotifierProvider(create: (_) => OnboardingViewModel()),
        ChangeNotifierProvider(create: (_) => LudoProvider()..startGame()),
      ],
      child: const Root(),
    ),
  );
}

class Root extends StatelessWidget {
  const Root({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppConstants.appName,
      navigatorKey: NavigationService.navigatorKey,
      home: const SplashView(),
      routes: {
        AppConstants.splashRoute: (context) => const SplashView(),
        AppConstants.onboardingRoute: (context) => const OnboardingView(),
        AppConstants.loginRoute: (context) => const AuthView(),
        AppConstants.homeRoute: (context) => const HomeView(),
        AppConstants.gameModeRoute: (context) => const GameModeView(),
        AppConstants.gameRoute: (context) => const MainScreen(),
        // Add other routes as we create them
        // AppConstants.homeRoute: (context) => const HomeView(),
        // AppConstants.gameRoute: (context) => const GameView(),
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => const SplashView(),
        );
      },
    );
  }
}
