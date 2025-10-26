import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:joy_way/models/user/user_app.dart';
import 'package:joy_way/screens/profile_screen/profile_screen.dart';
import '../../config/general_specifications.dart';
import '../../services/firebase_services/profile_services/profile_fire_storage_image.dart';
import '../../services/firebase_services/profile_services/profile_firestore.dart';
import 'bottom_bar.dart';
import 'home_screen/home_screen.dart';
import 'journey_screen/journey_screen.dart';
import 'message_screen/messages_screen.dart';
import 'notify_screen/notify_screen.dart';

class FoundationOfHome extends StatefulWidget {
  const FoundationOfHome({super.key});
  @override
  State<FoundationOfHome> createState() => _FoundationOfHomeState();
}

class _FoundationOfHomeState extends State<FoundationOfHome> {
  int _index = 0;


  @override
  void initState() {
    super.initState();

  }


  Widget _buildChild(GeneralSpecifications specs) {
    switch (_index) {
      case 0:
        return const HomeScreen(
        );
      case 1:
        return const NotifyScreen();
      case 2:
        return const JourneyScreen();
      case 3:
        return const MessagesScreen();
      case 4:
        return const ProfileScreen(

        );
      default:
        return const HomeScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    final specs = GeneralSpecifications(context);
    final child = _buildChild(specs);
    return Scaffold(
      backgroundColor: const Color.fromRGBO(245, 245, 245, 1),
      extendBody: true,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, anim) =>
            FadeTransition(opacity: anim, child: child),
        child: KeyedSubtree(
          key: ValueKey<int>(_index),
          child: child,
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: BottomBar(
          page: _index,
          onPage: (i) => setState(() => _index = i),
        ),
      ),
    );
  }
}
