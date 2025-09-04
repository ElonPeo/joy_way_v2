import 'package:flutter/material.dart';
import 'package:joy_way/screens/home/bottom_bar.dart';
import '../../config/general_specifications.dart';

class FoundationOfHome extends StatefulWidget {
  final Function(bool) onFinishedAnimation;

  const FoundationOfHome({
    super.key,
    required this.onFinishedAnimation,
  });

  @override
  State<FoundationOfHome> createState() => _FoundationOfHomeState();
}

class _FoundationOfHomeState extends State<FoundationOfHome> {
  int page = 0;

  @override
  Widget build(BuildContext context) {
    final specs = GeneralSpecifications(context);
    return Material(
      color: Colors.white70,
      child: Stack(
        children: [
          IconButton(
            onPressed: () {
              // widget.onFinishedAnimation(false);
              // Authentication().signOut();
              setState(() {
                page = 1;
              });
            },
            icon: Icon(
              Icons.abc,
              size: 100,
            ),
          ),
          Positioned(bottom: 0, child: BottomBar(
            page: page,
            onPage: (value) {
              setState(() => page = value);
            },
          )),
        ],
      ),
    );
  }
}
