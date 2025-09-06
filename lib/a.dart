// import 'package:flutter/material.dart';
// import 'dart:ui';
//
// void main() {
//   runApp(const BlurExample());
// }
//
// class BlurExample extends StatelessWidget {
//   const BlurExample({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Stack(
//         children: [
//           Positioned.fill(child: ColoredBox(color: Colors.black)),
//           // ** Create a new layer that only contains the content you want to be blurred
//           ClipRect(
//             clipBehavior: Clip.antiAliasWithSaveLayer,
//             child: Stack(
//               children: [
//                 Center(
//                   child: SizedBox(
//                     width: 100,
//                     height: 100,
//                     child: ColoredBox(
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//                 Center(
//                   child: SizedBox(
//                     width: 50,
//                     height: 50,
//                     child: ColoredBox(
//                       color: Colors.red,
//                     ),
//                   ),
//                 ),
//                 Center(
//                   // ** Clip the backdrop filter so that it only applies to a fixed area - no need to use anti aliasing
//                   child: ClipRect(
//                     child: BackdropFilter(
//                       filter: ImageFilter.blur(
//                           sigmaX: 10, sigmaY: 10, tileMode: TileMode.mirror),
//                       child: SizedBox(width: 100, height: 100),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }
