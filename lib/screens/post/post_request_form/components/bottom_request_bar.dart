import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:joy_way/services/firebase_services/request_services/request_firestore.dart';
import 'package:joy_way/widgets/custom_input/confirm_button.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import '../../../../config/general_specifications.dart';
import '../../../../models/post/post.dart';
import '../../../../models/request/request_journey/request_join_journey/end_request_info.dart';
import '../../../../models/request/request_journey/request_join_journey/request_join_journey.dart';
import '../../../../models/request/request_journey/request_join_journey/start_request_info.dart';
import '../../../../services/firebase_services/request_services/request_journey_services/request_join_journey_services.dart';
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
              0,
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
              0,
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
          final userId = FirebaseAuth.instance.currentUser?.uid;
          if (userId == null) {
            ShowNotification.showAnimatedSnackBar(context, "You are not logged in", 1, const Duration(milliseconds: 200),);
            return;
          }
          final start = widget.startRequestInfo;
          final end   = widget.endRequestInfo;
          if (start == null || end == null) {
            ShowNotification.showAnimatedSnackBar(context, "Missing pick-up/drop-off point data", 1, const Duration(milliseconds: 200),);
            return;
          }
          final req = RequestJoinJourney(
            id: '',
            senderId: userId,
            receiverId: widget.post.ownerId,
            postId: widget.post.id,
            desiredPickUpTime: start.desiredPickUpTime,
            desiredDropOffTime: end.desiredDropOffTime,
            pickUpName: start.pickUpName,
            pickUpPoint: start.pickUpPoint,
            dropOffName: end.dropOffName,
            dropOffPoint: end.dropOffPoint,
            note: "",
            isAccepted: null,
            createdAt: null,
            updatedAt: null,
          );

          final service = RequestJoinJourneyServices();
          final err = await service.createRequest(req);
          if (err == null) {
            ShowNotification.showAnimatedSnackBar(context, "Request to join the journey successfully sent.", 3, const Duration(milliseconds: 200),);
            if (mounted) Navigator.of(context).maybePop();
          } else {
            ShowNotification.showAnimatedSnackBar(context, "Err: $err", 0, const Duration(milliseconds: 200),);
          }
        },
        onRefuse: () {
          _goPrev();
        },
      );
    }

    return ConfirmButton(
      isConfirmOnly: false,
      onConfirm: () async {
        FocusScope.of(context).unfocus();
        final userId = FirebaseAuth.instance.currentUser?.uid;
        if (userId == null) {
          ShowNotification.showAnimatedSnackBar(context, "You are not logged in", 1, const Duration(milliseconds: 200),);
          return;
        }
        final start = widget.startRequestInfo;
        final end   = widget.endRequestInfo;
        if (start == null || end == null) {
          ShowNotification.showAnimatedSnackBar(context, "Missing pick-up/drop-off point data", 1, const Duration(milliseconds: 200),);
          return;
        }
        final req = RequestJoinJourney(
          id: '',
          senderId: userId,
          receiverId: widget.post.ownerId,
          postId: widget.post.id,
          desiredPickUpTime: start.desiredPickUpTime,
          desiredDropOffTime: end.desiredDropOffTime,
          pickUpName: start.pickUpName,
          pickUpPoint: start.pickUpPoint,
          dropOffName: end.dropOffName,
          dropOffPoint: end.dropOffPoint,
          note: "",
          isAccepted: null,
          createdAt: null,
          updatedAt: null,
        );

        final service = RequestJoinJourneyServices();
        final err = await service.createRequest(req);
        if (err == null) {
          ShowNotification.showAnimatedSnackBar(context, "Request to join the journey successfully sent.", 3, const Duration(milliseconds: 200),);
          if (mounted) Navigator.of(context).maybePop();
        } else {
          ShowNotification.showAnimatedSnackBar(context, "Err: $err", 0, const Duration(milliseconds: 200),);
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
