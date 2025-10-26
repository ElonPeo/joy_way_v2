import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:joy_way/models/post/components/detail.dart';
import 'package:joy_way/models/post/components/end_infor.dart';
import 'package:joy_way/models/post/components/start_info.dart';
import 'package:joy_way/services/firebase_services/post_services/post_firestore.dart';
import 'package:joy_way/widgets/custom_input/confirm_button.dart';
import 'package:joy_way/widgets/notifications/show_notification.dart';
import '../../../../config/general_specifications.dart';
import '../../../../models/post/post.dart';
import '../../../../widgets/animated_container/custom_animated_button.dart';


class BottomRequestBar extends StatefulWidget {


  final int page;
  final Function(int) onPage;
  final int totalSteps;

  const BottomRequestBar({
    super.key,

    required this.page,
    required this.onPage,
    this.totalSteps = 3,
  });

  @override
  State<BottomRequestBar> createState() => _BottomRequestBarState();
}

class _BottomRequestBarState extends State<BottomRequestBar> {
  // Helper
  bool get _isFirst => widget.page <= 0;
  bool get _isLast  => widget.page >= widget.totalSteps - 1;

  void _goPrev() {
    if (_isFirst) return;
    widget.onPage((widget.page - 1).clamp(0, widget.totalSteps - 1));
  }

  void _goNext() {
    if (_isLast) return;
    widget.onPage((widget.page + 1).clamp(0, widget.totalSteps - 1));
  }

  Widget _buildChild(GeneralSpecifications specs) {

    if (widget.page == 0) {
      return ConfirmButton(
        onConfirm: () {
          _goNext();
        },
      );
    }

    if (widget.page == 1) {
      return ConfirmButton(
        isConfirmOnly: false,
        onConfirm: () {
          _goNext();
        },
        onRefuse: () {
          _goPrev();
        },
      );
    }

    if (widget.page == 2) {
      return ConfirmButton(
        isConfirmOnly: false,
        onConfirm: () {

        },
        confirmTitle: "Confirm",
        onRefuse: () {
          _goPrev();
        },
      );
    }

    return ConfirmButton(
      isConfirmOnly: false,
      onConfirm: () {
        _goNext();
      },
      onRefuse: () {
        _goPrev();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final specs = GeneralSpecifications(context);
    final childWidget = _buildChild(specs);
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 100),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: child),
      child: KeyedSubtree(
        key: ValueKey<int>(widget.page),
        child: childWidget,
      ),
    );
  }
}
