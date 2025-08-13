import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../config/general_specifications.dart';


class FoundationOfHome extends StatefulWidget {
  const FoundationOfHome({super.key});

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
        ],
      ),
    );
  }
}
