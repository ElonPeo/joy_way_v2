import 'package:flutter/material.dart';
import 'package:joy_way/services/firebase_services/authentication.dart';
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
          Text('soiwfghujonw dingvhu owdhug owieudfgoedugf'),
          IconButton(onPressed: (){Authentication().signOut();}, icon: Icon(Icons.abc, size: 100,)),
        ],
      ),
    );
  }
}
