import 'package:flutter/material.dart';

import 'basic_statistics.dart';


class PostScreen extends StatelessWidget {
  const PostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        BasicStatistics(),
      ]
    );
  }
}