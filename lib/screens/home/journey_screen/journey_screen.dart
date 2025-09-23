import 'package:flutter/material.dart';
import 'package:joy_way/widgets/map/SelectLocationZoomable.dart';

import '../../../config/general_specifications.dart';

class JourneyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final specs = GeneralSpecifications(context);
    return Container(
      height: specs.screenHeight,
      width: specs.screenWidth,
      color: Colors.red,
      child: ShowMap(),
    );
  }
}
