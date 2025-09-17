import 'package:flutter/material.dart';
import 'package:joy_way/widgets/animated_container/loading_container.dart';

import '../../../config/general_specifications.dart';

class NotifyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final specs = GeneralSpecifications(context);
    return Container(
        height: specs.screenHeight,
        width: specs.screenWidth,
        color: Color(0x66FFFFFF),
        child: Center(
          child: LoadingContainer(width: 200, height: 100),
        ));
  }
}
