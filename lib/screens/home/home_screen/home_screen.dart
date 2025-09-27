import 'package:flutter/material.dart';
import 'package:joy_way/widgets/notifications/confirm_notification.dart';

import '../../../config/general_specifications.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final specs = GeneralSpecifications(context);
    return Container(
        height: specs.screenHeight,
        width: specs.screenWidth,
        color: Colors.red,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(onPressed: () {
              ConfirmNotification.showAnimatedSnackBar(
                  context,
                  "Are you sure you want to log out?",
                  2,
              );
            }, icon: const Icon(Icons.abc, size: 30,)),
          ],
        )
    );
  }
}