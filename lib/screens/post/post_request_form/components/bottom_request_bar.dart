import 'package:flutter/material.dart';
import 'package:joy_way/models/request/request_journey/components/end_request_info.dart';
import 'package:joy_way/models/request/request_journey/components/start_request_info.dart';
import 'package:joy_way/models/request/request_journey/request_journey.dart';
import 'package:joy_way/services/firebase_services/request_services/request_firestore.dart';
import 'package:joy_way/widgets/custom_input/confirm_button.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import '../../../../config/general_specifications.dart';
import '../../../../models/post/post.dart';
import '../../../../widgets/notifications/show_notification.dart';

class BottomRequestBar extends StatefulWidget {

  final Post post;
  final int page;
  final Function(int) onPage;
  final int totalSteps;

  final StartRequestInfo? startRequestInfo;
  final EndRequestInfo? endRequestInfo;

  const BottomRequestBar({
    super.key,
    required this.page,
    required this.onPage,
    required this.post,
    this.totalSteps = 3,
    required this.startRequestInfo,
    required this.endRequestInfo,
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
          FocusScope.of(context).unfocus();
          final start = widget.startRequestInfo;
          if (start == null) {
            ShowNotification.showAnimatedSnackBar(
              context,
              "Fields marked with * cannot be left blank",
              1,
              const Duration(milliseconds: 200),
            );
            return;
          }
          final result = RequestFirestore().checkValidStartRequest(start);
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
          _goNext();
        },
      );
    }

    if (widget.page == 1) {
      return ConfirmButton(
        isConfirmOnly: false,
        onConfirm: () {
          FocusScope.of(context).unfocus();
          final end = widget.endRequestInfo;
          if (end == null) {
            ShowNotification.showAnimatedSnackBar(
              context,
              "Fields marked with * cannot be left blank",
              1,
              const Duration(milliseconds: 200),
            );
            return;
          }
          final result = RequestFirestore().checkValidEndRequest(end);
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
        onConfirm: () async {
          FocusScope.of(context).unfocus();
          try {
            final start = widget.startRequestInfo;
            final end = widget.endRequestInfo;
            if (start == null || end == null ) {
              ShowNotification.showAnimatedSnackBar(
                context,
                "Please complete all required sections before confirming.",
                2,
                const Duration(milliseconds: 300),
              );
              return;
            }
            // Map sang Post phẳng
            final request = RequestJourney(
              journeyId: widget.post.id,
              desiredPickUpTime: widget.startRequestInfo?.desiredPickUpTime,
              desiredDropOffTime: widget.endRequestInfo?.desiredDropOffTime,
              pickUpName: widget.startRequestInfo?.pickUpName,
              pickUpPoint: widget.startRequestInfo?.pickUpPoint,
              dropOffName: widget.endRequestInfo?.dropOffName,
              dropOffPoint: widget.endRequestInfo?.dropOffPoint,
              message: '',
              note: '',
            );

            final postService = RequestFirestore();
            final postId = await postService.createJourneyRequest(
              receiverId: widget.post.ownerId,
              requestJourney: request,
            );

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
      onConfirm: () async {
        FocusScope.of(context).unfocus();
        try {
          final start = widget.startRequestInfo;
          final end = widget.endRequestInfo;
          if (start == null || end == null ) {
            ShowNotification.showAnimatedSnackBar(
              context,
              "Please complete all required sections before confirming.",
              2,
              const Duration(milliseconds: 300),
            );
            return;
          }
          // Map sang Post phẳng
          final request = RequestJourney(
            journeyId: widget.post.id,
            desiredPickUpTime: widget.startRequestInfo?.desiredPickUpTime,
            desiredDropOffTime: widget.endRequestInfo?.desiredDropOffTime,
            pickUpName: widget.startRequestInfo?.pickUpName,
            pickUpPoint: widget.startRequestInfo?.pickUpPoint,
            dropOffName: widget.endRequestInfo?.dropOffName,
            dropOffPoint: widget.endRequestInfo?.dropOffPoint,
            message: '',
            note: '',
          );

          final postService = RequestFirestore();
          final postId = await postService.createJourneyRequest(
              receiverId: widget.post.ownerId,
              requestJourney: request,
          );

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
