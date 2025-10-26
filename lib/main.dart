import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:joy_way/screens/foundation_of_home.dart';
import 'package:joy_way/services/mapbox_services/mapbox_config.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart'; // <-- thêm
import 'package:joy_way/AuthWrapper.dart';
import 'package:joy_way/screens/authentication/foundation_of_auth.dart';
import 'config/theme.dart';
import 'firebase_options.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  MapboxOptions.setAccessToken(MapboxConfig.accessToken);
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
    appleProvider: AppleProvider.debug,
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
