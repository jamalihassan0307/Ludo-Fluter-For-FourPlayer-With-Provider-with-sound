class AppConstants {
  static const String appName = 'Ludo Flutter';
  static const String appVersion = '1.0.0';
  
  // Route Names
  static const String splashRoute = '/splash';
  static const String onboardingRoute = '/onboarding';
  static const String loginRoute = '/login';
  static const String homeRoute = '/home';
  static const String gameRoute = '/game';

  // Asset Paths
  static const String logoPath = "assets/logo.jpg";
  static const List<String> walkthroughImages = [
    "assets/walkthrough/logo_gaming.jpg",
    "assets/walkthrough/game.png",
    "assets/walkthrough/two_dies.webp",
  ];

  // Walkthrough Texts
  static const List<String> walkthroughTitles = [
    "Welcome to Ludo Game",
    "Play with Friends",
    "Roll the Dice"
  ];

  static const List<String> walkthroughDescriptions = [
    "Experience the classic board game in a modern way",
    "Challenge your friends or play against computer",
    "Roll the dice and make strategic moves to win"
  ];

  // Animation Durations
  static const Duration splashDuration = Duration(seconds: 3);
  static const Duration animationDuration = Duration(milliseconds: 800);
} 