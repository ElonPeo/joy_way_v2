import 'package:flutter/material.dart';

class ShowGeneralDialog {
  static void General_Dialog({
    required BuildContext context,
    required Offset beginOffset,
    required Widget child,
    Duration duration = const Duration(milliseconds: 500),
    bool barrierDismissible = true,
    Color barrierColor = Colors.black54,
    Curve curve = Curves.easeInOut,
    String barrierLabel = 'Dismiss',
  }) {
    showGeneralDialog(
      barrierDismissible: barrierDismissible,
      barrierLabel: barrierLabel,
      barrierColor: barrierColor,
      context: context,
      transitionDuration: duration,
      transitionBuilder: (_, animation, __, child) {
        final tween = Tween<Offset>(begin: beginOffset, end: Offset.zero);
        return SlideTransition(
          position: tween.animate(
            CurvedAnimation(parent: animation, curve: curve),
          ),
          child: child,
        );
      },
      pageBuilder: (context, _, __) => child,
    );
  }
}