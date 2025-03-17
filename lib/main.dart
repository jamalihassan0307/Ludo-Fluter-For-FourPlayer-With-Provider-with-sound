import 'package:flutter/material.dart';
// import 'package:flutter/scheduler.dart';
import 'package:ludo_flutter/screens/complete_profile_screen.dart';
import 'package:provider/provider.dart';
// import 'package:ludo_flutter/main_screen.dart';
// import 'package:ludo_flutter/home_page.dart';
import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:ludo_flutter/ludo_provider.dart';
import 'package:ludo_flutter/screens/splash_screen.dart';

// import 'ludo_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => LudoProvider(),
        child: MaterialApp(
            title: 'Ludo Game',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primarySwatch: Colors.blue,
              fontFamily: 'Poppins',
            ),
            home: CompleteProfileScreen(
              email: "jamalihassan0307@gmail.com",
              isGoogleSignIn: true,
            )));
  }
}
