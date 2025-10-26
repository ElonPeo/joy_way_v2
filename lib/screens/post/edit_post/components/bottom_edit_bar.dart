import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:joy_way/models/post/components/detail.dart';
import 'package:joy_way/models/post/components/end_infor.dart';
import 'package:joy_way/models/post/components/start_info.dart';
import 'package:joy_way/services/firebase_services/post_services/post_firestore.dart';
import 'package:joy_way/widgets/notifications/show_notification.dart';
import '../../../../config/general_specifications.dart';
import '../../../../models/post/components/visibility.dart';
import '../../../../models/post/post.dart';
import '../../../../widgets/animated_container/custom_animated_button.dart';
import '../../../../widgets/custom_input/confirm_button.dart';


class BottomEditBar extends StatefulWidget {

  final StartInfo? startInfo;
  final EndInfo? endInfo;
  final DetailInfo? detailInfo;

  final int page;
  final Function(int) onPage;
  final int totalSteps;

  const BottomEditBar({
    super.key,
    required this.startInfo,
    required this.endInfo,
    required this.detailInfo,
    required this.page,
    required this.onPage,
    this.totalSteps = 4,
  });

  @override
  State<BottomEditBar> createState() => _BottomEditBarState();
}

class _BottomEditBarState extends State<BottomEditBar> {
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
          FocusScope.of(context).unfocus();
          final start = widget.startInfo;
          if (start == null) {
            ShowNotification.showAnimatedSnackBar(
              context,
              "Fields marked with * cannot be left blank",
              1,
              const Duration(milliseconds: 200),
            );
            return;
          }
          final result = PostFirestore().checkValidStartInfo(start);
          if (result == null) {
            _goNext();
          } else {
            ShowNotification.showAnimatedSnackBar(
              context,
              result,
              1,
              const Duration(milliseconds: 200),
            );
          }
        },
      );
    }

    if (widget.page == 1) {
      return ConfirmButton(
        isConfirmOnly: false,
        onConfirm: () {
          FocusScope.of(context).unfocus();
          final end = widget.endInfo;
          if (end == null) {
            ShowNotification.showAnimatedSnackBar(
              context,
              "Fields marked with * cannot be left blank",
              1,
              const Duration(milliseconds: 200),
            );
            return;
          }
          final result = PostFirestore().checkValidEndInfo(end);
          if (result == null) {
            _goNext();
          } else {
            ShowNotification.showAnimatedSnackBar(
              context,
              result,
              2,
              const Duration(milliseconds: 200),
            );
          }
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
          FocusScope.of(context).unfocus();
          final detail = widget.detailInfo;
          if (detail == null) {
            ShowNotification.showAnimatedSnackBar(
              context,
              "Fields marked with * cannot be left blank",
              1,
              const Duration(milliseconds: 200),
            );
            return;
          }
          final result = PostFirestore().checkValidDetail(detail);
          if (result == null) {
            _goNext();
          } else {
            ShowNotification.showAnimatedSnackBar(
              context,
              result,
              2,
              const Duration(milliseconds: 200),
            );
          }
        },
        onRefuse: () {
          _goPrev();
        },
      );
    }

    if (widget.page == 3) {
      return ConfirmButton(
        isConfirmOnly: false,
        onConfirm: () async {
          FocusScope.of(context).unfocus();
          try {
            final start = widget.startInfo;
            final end = widget.endInfo;
            final detail = widget.detailInfo;

            if (start == null || end == null || detail == null) {
              ShowNotification.showAnimatedSnackBar(
                context,
                "Please complete all required sections before confirming.",
                2,
                const Duration(milliseconds: 300),
              );
              return;
            }

            // Map sang Post phẳng
            final post = Post(
              id: "",
              ownerId: "", // PostFirestore.savePost sẽ ghi đè = currentUser.uid
              departureCoordinate: start.departureCoordinate,
              departureName: start.departureName,
              departureTime: start.departureTime,
              vehicleType: start.vehicleType,
              availableSeats: start.availableSeats,

              arrivalCoordinate: end.arrivalCoordinate,
              arrivalName: end.arrivalName,
              arrivalTime: end.arrivalTime,

              type: detail.type,               // ExpenseType.free | share
              amount: detail.amount,           // null nếu free
              description: detail.description, // mô tả tuỳ chọn

              // tuỳ bạn có cho chỉnh visibility ở màn tạo bài hay để mặc định public
              visibility: const VisibilityPostInfo(),
            );

            final postService = PostFirestore();
            final postId = await postService.savePost(post);

            ShowNotification.showAnimatedSnackBar(
              context,
              "Post created successfully (ID: $postId)",
              3,
              const Duration(milliseconds: 400),
            );
            Navigator.pop(context);
          } catch (e) {
            ShowNotification.showAnimatedSnackBar(
              context,
              e.toString(),
              0,
              const Duration(milliseconds: 400),
            );
          }
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
