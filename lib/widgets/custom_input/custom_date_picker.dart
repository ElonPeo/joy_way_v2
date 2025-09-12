import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import '../../config/general_specifications.dart';
import '../animated_container/animated_button.dart';
import '../animated_container/animated_icon_button.dart';

class CustomDatePicker extends StatelessWidget {
  final Widget child;
  final bool dismissible;
  final Duration duration;
  final DateTime? dateTime;
  final String title;
  final bool isDate;
  final Function(DateTime)? onDateTimeChanged;

  const CustomDatePicker({
    super.key,
    required this.child,
    required this.onDateTimeChanged,
    this.dismissible = true,
    this.duration = const Duration(milliseconds: 250),
    this.isDate = true,
    this.title = "Date Picker",
    this.dateTime,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _open(context),
      child: child,
    );
  }

  void _open(BuildContext context) {
    final specs = GeneralSpecifications(context);
    DateTime temp = dateTime ?? DateTime.now();
    showGeneralDialog(
      context: context,
      barrierDismissible: dismissible,
      barrierLabel: 'select',
      barrierColor: Colors.transparent,
      transitionDuration: duration,
      pageBuilder: (_, __, ___) => const SizedBox.shrink(),
      transitionBuilder: (context, animation, secondary, _) {

        final t = Curves.easeOutCubic.transform(animation.value);
        final sigma = 5.0 * t;
        final barrierOpacity = 0.25 * t;
        return Stack(
          children: [
            // Blur nền + chặn tap
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: dismissible ? () => Navigator.of(context, rootNavigator: true).pop() : null,
                  child: Container(color: Colors.black.withOpacity(barrierOpacity)),
                ),
              ),
            ),

            // Bottom sheet
            Positioned(
              left: 0, right: 0, bottom: 0,
              child: Transform.translate(
                offset: Offset(0, (1 - t) * 330),
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    width: specs.screenWidth,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(topRight: Radius.circular(40),topLeft: Radius.circular(40)),
                      boxShadow: [BoxShadow(blurRadius: 20, color: Colors.black12)],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          decoration: const BoxDecoration(
                            color: Color(0xFF2C7A54),
                            borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 50,
                                child: AnimatedIconButton(
                                  onTap: () => Navigator.of(context).maybePop(),
                                  height: 30,
                                  width: 20,
                                  color: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  child: const ImageIcon(
                                    AssetImage("assets/icons/other_icons/angle-left.png"),
                                    color: Colors.white,
                                    size: 23,
                                  )
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  title,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600),
                                ),
                              ),
                              AnimatedButton(
                                height: 30,
                                width: 50,
                                text: "Save",
                                fontSize: 20,
                                color: Colors.transparent,
                                shadowColor: Colors.transparent,
                                textColor: Colors.white,
                                fontWeight: FontWeight.w400,
                                onTap: () async {
                                  if (onDateTimeChanged != null) onDateTimeChanged!(temp);
                                  Navigator.of(context).maybePop();
                                },
                              )
                            ],
                          ),
                        ),

                        // Picker
                        SizedBox(
                          height: 200,
                          child: CupertinoDatePicker(
                            mode: isDate
                                ? CupertinoDatePickerMode.date
                                : CupertinoDatePickerMode.time,
                            initialDateTime: dateTime ?? DateTime.now(),
                            use24hFormat: true,
                            onDateTimeChanged: (d) => temp = d,
                          ),
                        ),



                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
