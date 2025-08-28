import 'package:flutter/material.dart';
import 'package:joy_way/services/firebase_services/authentication.dart';
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
  @override
  Widget build(BuildContext context) {
    final specs = GeneralSpecifications(context);
    return Material(
      color: Colors.white,
      child: Stack(
        children: [
          Text('soiwfghujonw dingvhu owdhug owieudfgoedugf'),
          IconButton(
              onPressed: () async {
                await widget.onFinishedAnimation(false);
                Authentication().signOut();
              },
              icon: Icon(
                Icons.abc,
                size: 100,
              )),
        ],
      ),
    );
  }
}
