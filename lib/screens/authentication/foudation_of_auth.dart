import 'package:flutter/material.dart';

import '../../config/general_specifications.dart';
import 'components/login/login_screen.dart';
import 'components/status_and_message/status_and_message.dart';

class FoundationOfAuth extends StatefulWidget {
  const FoundationOfAuth({super.key});

  @override
  State<FoundationOfAuth> createState() => _FoundationOfAuthState();
}

class _FoundationOfAuthState extends State<FoundationOfAuth> {
  bool animationBlur = false;


  @override
  Widget build(BuildContext context) {
    final specs = GeneralSpecifications(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        height: specs.screenHeight,
        width: specs.screenWidth,
        color: Color.fromRGBO(100, 100, 100, 1),
        child: Stack(
          children: [
            IconButton(
              icon: Icon(
                Icons.abc,
                size: 100,
              ),
              onPressed: (){
                setState(() {
                  Navigator.pushNamed(context, '/welcome');
                  // animationBlur = !animationBlur;
                  // print(animationBlur);
                });
              },
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                LoginScreen(),
              ],
            )


          ],
        ),
      ),
    );
  }
}
