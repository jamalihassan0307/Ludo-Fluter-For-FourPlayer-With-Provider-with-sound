import 'package:flutter/material.dart';
import 'package:ludo_flutter/core/constants/app_constants.dart';
// import 'package:flutter/scheduler.dart';
import 'package:ludo_flutter/core/services/navigation_service.dart';
import 'package:ludo_flutter/ui/shared/themes.dart';
import 'package:ludo_flutter/ui/views/auth/auth_view.dart';
import 'package:ludo_flutter/ui/views/game/game_mode_view.dart';
import 'package:ludo_flutter/ui/views/game/game_view.dart';
import 'package:ludo_flutter/ui/views/home/home_view.dart';
import 'package:ludo_flutter/ui/views/lobby/lobby_view.dart';
import 'package:provider/provider.dart';
// import 'package:ludo_flutter/main_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:ludo_flutter/core/services/storage_service.dart';
import 'ui/views/splash/splash_view.dart';
import 'ui/views/onboarding/onboarding_view.dart';
import 'viewmodels/splash_viewmodel.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/onboarding_viewmodel.dart';
import 'viewmodels/lobby_viewmodel.dart';
import 'ludo_provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/services/game_history_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize Hive
  await Hive.initFlutter();
  await GameHistoryService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SplashViewModel()),
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => OnboardingViewModel()),
        ChangeNotifierProvider(create: (_) => LobbyViewModel()),
        ChangeNotifierProvider(create: (_) => LudoProvider()),
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
      theme: AppTheme.lightTheme,
      home: const SplashView(),
      routes: {
        AppConstants.splashRoute: (context) => const SplashView(),
        AppConstants.onboardingRoute: (context) => const OnboardingView(),
        AppConstants.loginRoute: (context) => const AuthView(),
        AppConstants.homeRoute: (context) => const HomeView(),
        AppConstants.gameModeRoute: (context) => const GameModeView(),
        AppConstants.lobbyRoute: (context) => const LobbyView(),
        AppConstants.gameRoute: (context) => const GameView(),
        // AppConstants.gameRoute: (context) => const MainScreen(),
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
