import 'package:flutter/material.dart';

import '../../../../widgets/ShowGeneralDialog.dart';
import '../../../../widgets/map/select_location/select_location.dart';



class SelectLocationButton extends StatelessWidget {
  final Widget child;
  final double height;
  final double width;

  const SelectLocationButton({
    super.key,
    required this.height,
    required this.width,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        ShowGeneralDialog.General_Dialog(
          context: context,
          beginOffset: const Offset(1, 0),
          child: const SelectLocation(),
        );
      },
      child: SizedBox(
        height: height,
        width: width,
        child: child,
      ),
    );
  }
}