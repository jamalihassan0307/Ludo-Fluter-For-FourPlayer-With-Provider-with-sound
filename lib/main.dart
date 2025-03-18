import 'package:flutter/material.dart';
// import 'package:flutter/scheduler.dart';
import 'package:ludo_flutter/screens/login_screen.dart';
import 'package:ludo_flutter/screens/walkthrough_screen.dart';
import 'package:provider/provider.dart';
// import 'package:ludo_flutter/main_screen.dart';
import 'package:ludo_flutter/home_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ludo_flutter/ludo_provider.dart';
// import 'package:ludo_flutter/screens/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ludo_flutter/providers/user_provider.dart';

// import 'ludo_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => UserProvider()),
          ChangeNotifierProvider(create: (context) => LudoProvider()),
        ],
        child: MaterialApp(
            title: 'Ludo Game',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primarySwatch: Colors.blue,
              fontFamily: 'Poppins',
            ),
            home: StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                return FutureBuilder<bool>(
                  future: _checkFirstLaunch(),
                  builder: (context, prefSnapshot) {
                    if (prefSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final isFirstLaunch = prefSnapshot.data ?? true;

                    if (isFirstLaunch) {
                      return const WalkthroughScreen();
                    }

                    if (snapshot.hasData) {
                      return const HomePage();
                    }
                    return const LoginScreen();
                  },
                );
              },
            )));
  }

  Future<bool> _checkFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool('walkthroughCompleted') ?? false);
  }
}
