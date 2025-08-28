import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:joy_way/screens/authentication/foudation_of_auth.dart';
import 'package:joy_way/screens/home/foundation_of_home.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool finishAnimation = false;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData && finishAnimation) {
          return FoundationOfHome(
              onFinishedAnimation: (value) {
                setState(() {
                  finishAnimation = value;
                });
              }
          );
        } else {
          return FoundationOfAuth(
            onFinishedAnimation: (value) {
              setState(() {
                finishAnimation = value;
              });
            }
          );
        }
      },
    );
  }
}
