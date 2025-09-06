import 'package:flutter/material.dart';

import '../../../config/general_specifications.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final specs = GeneralSpecifications(context);
    return Container(
      height: specs.screenHeight,
      width: specs.screenWidth,
      color: Colors.red,
    );
  }
}