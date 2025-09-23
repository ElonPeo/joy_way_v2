import 'package:flutter/material.dart';

import 'basic_statistics.dart';


class PostScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        BasicStatistics(),
      ]
    );
  }
}