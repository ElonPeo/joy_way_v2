import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:joy_way/AuthWrapper.dart';
import 'package:joy_way/screens/authentication/foundation_of_auth.dart';
import 'package:joy_way/screens/home/foundation_of_home.dart';
import 'config/theme.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Auth App',
      theme: AppTheme.themeData,
      home: const AuthWrapper(),
      routes: {
        '/auth': (context) => const FoundationOfAuth(),
        '/home': (context) => const FoundationOfHome(),
      },
    );
  }

}
