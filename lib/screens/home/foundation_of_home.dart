import 'package:flutter/material.dart';
import 'package:joy_way/screens/home/bottom_bar.dart';
import 'package:joy_way/screens/home/home_screen/home_screen.dart';
import 'package:joy_way/screens/home/journey_screen/journey_screen.dart';
import 'package:joy_way/screens/home/message_screen/message_screen.dart';
import 'package:joy_way/screens/home/notify_screen/notify_screen.dart';
import 'package:joy_way/screens/home/profile_screen/profile_screen.dart';
import '../../config/general_specifications.dart';

class FoundationOfHome extends StatefulWidget {
  const FoundationOfHome({super.key});
  @override
  State<FoundationOfHome> createState() => _FoundationOfHomeState();
}

class _FoundationOfHomeState extends State<FoundationOfHome> {
  int _index = 0;

  Widget _buildChild(GeneralSpecifications specs) {
    switch (_index) {
      case 0:
        return const HomeScreen();
      case 1:
        return const NotifyScreen();
      case 2:
        return const JourneyScreen();
      case 3:
        return const MessageScreen();
      case 4:
        return const ProfileScreen();
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
