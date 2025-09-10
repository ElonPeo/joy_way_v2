import 'dart:ui';
import 'package:flutter/material.dart';
import '../../config/general_specifications.dart';

class CustomeSelect extends StatelessWidget {
  final Widget child;
  final List<Widget> children;
  final bool dismissible;
  final Duration duration;

  const CustomeSelect({
    super.key,
    required this.child,
    required this.children,
    this.dismissible = true,
    this.duration = const Duration(milliseconds: 250),
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

    showGeneralDialog(
      context: context,
      barrierDismissible: dismissible,
      barrierLabel: 'select',
      barrierColor: Colors.transparent,
      transitionDuration: duration,
      pageBuilder: (_, __, ___) {
        return const SizedBox.shrink();
      },
      transitionBuilder: (context, animation, secondary, child) {
        final t = Curves.easeOutCubic.transform(animation.value);
        final sigma = 5.0 * t;      // blur theo tiến độ
        final barrierOpacity = 0.25 * t;

        return Stack(
          children: [
            // Lớp blur + barrier chặn tap bên dưới
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: dismissible ? () => Navigator.of(context).maybePop() : null,
                  child: Container(color: Colors.black.withOpacity(barrierOpacity)),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Transform.translate(
                offset: Offset(0, (1 - t) * 300),
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    width: specs.screenWidth,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                      ),
                    ),
                    child: SafeArea(
                      top: false,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: children,
                      ),
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
