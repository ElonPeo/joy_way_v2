import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:joy_way/config/general_specifications.dart';
import 'package:joy_way/models/request/request_journey/request_join_journey/request_join_journey.dart';
import 'package:joy_way/models/user/basic_user_info.dart';
import 'package:joy_way/services/data_processing/time_processing.dart';
import 'package:joy_way/services/firebase_services/profile_services/profile_firestore.dart';
import 'package:joy_way/widgets/animated_container/custom_animated_button.dart';
import 'package:joy_way/widgets/photo_view/avatar_view.dart';

import '../../services/firebase_services/passenger_services/passenger_firestore.dart';
import '../../services/firebase_services/request_services/request_journey_services/request_join_journey_services.dart';
import '../../widgets/notifications/show_notification.dart';

class RequestJoinNoticeCard extends StatefulWidget {
  final RequestJoinJourney requestJoinJourney;

  const RequestJoinNoticeCard({
    super.key,
    required this.requestJoinJourney,
  });

  @override
  State<RequestJoinNoticeCard> createState() => _RequestJoinNoticeCardState();
}

class _RequestJoinNoticeCardState extends State<RequestJoinNoticeCard> {
  BasicUserInfo? _sender;
  bool _loadingSender = true;
  bool _busyAction = false;

  bool? _acceptedLocal;

  Future<void> _loadSender() async {
    final r = await ProfileFirestore()
        .getBasicUserInfo(widget.requestJoinJourney.senderId);
    if (!mounted) return;
    setState(() {
      _sender = r.user;
      _loadingSender = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _acceptedLocal = widget.requestJoinJourney.isAccepted;
    _loadSender();
  }

  Future<void> _handleUpdate(bool accept) async {
    if (_busyAction) return;
    setState(() => _busyAction = true);
    final req = widget.requestJoinJourney;
    final service = RequestJoinJourneyServices();
    final err = await service.updateRequestStatus(
      requestId: req.id,
      isAccepted: accept,
    );
    if (!mounted) return;
    if (err != null) {
      setState(() => _busyAction = false);
      ShowNotification.showAnimatedSnackBar(
        context,
        "Err: $err",
        0,
        const Duration(milliseconds: 500),
      );
      return;
    }

    // 2) Nếu chấp nhận -> tạo Passenger
    if (accept) {
      final pf = PassengerFirestore();
      final err2 = await pf.createPassenger(
        postId: req.postId,
        userId: req.senderId,   // người gửi request trở thành passenger
        requestId: req.id,
      );

      if (err2 != null) {
        setState(() {
          _busyAction = false;
          _acceptedLocal = true;
        });
        ShowNotification.showAnimatedSnackBar(
          context,
          "Accepted, but failed to create passenger.\nErr: $err2",
          0,
          const Duration(milliseconds: 600),
        );
        return;
      }
    }

    // 3) Thành công
    setState(() {
      _busyAction = false;
      _acceptedLocal = accept;
    });
    ShowNotification.showAnimatedSnackBar(
      context,
      accept
          ? "You accepted @${_sender?.userName}'s request.\nJID: ${req.postId}"
          : "You refused @${_sender?.userName}'s request.\nJID: ${req.postId}",
      3,
      const Duration(milliseconds: 500),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingSender || _sender == null) {
      return const SizedBox.shrink();
    }

    final specs = GeneralSpecifications(context);
    final r = widget.requestJoinJourney;
    final timeStr =
        TimeProcessing.formatTimestamp(r.updatedAt ?? r.createdAt) ?? '';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(width: 1, color: specs.black240),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 5),
          AvatarView(
            imageId: _sender?.avatarImageId,
            nameUser: _sender?.userName,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: Colors.black,
                    ),
                    children: [
                      TextSpan(
                        text: '@${_sender?.userName}',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const TextSpan(text: ' sent a request to join the journey.'),
                    ],
                  ),
                ),

                const SizedBox(height: 4),
                Text(
                  "Update ${timeStr}",
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    color: specs.black150,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 10),

                if (_acceptedLocal == null)
                  Row(
                    children: [
                      CustomAnimatedButton(
                        onTap: _busyAction ? null : () => _handleUpdate(false),
                        height: 35,
                        width: 100,
                        color: specs.black240,
                        shadowColor: Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        child: _busyAction
                            ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                            : Text(
                          "Refuse",
                          style: GoogleFonts.outfit(
                            color: specs.black100,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      CustomAnimatedButton(
                        onTap: _busyAction ? null : () => _handleUpdate(true),
                        height: 35,
                        width: 100,
                        borderRadius: BorderRadius.circular(10),
                        child: _busyAction
                            ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                            : Text(
                          "Accept",
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  _StatusPill(
                    accepted: _acceptedLocal!,
                    specs: specs,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final bool accepted;
  final GeneralSpecifications specs;
  const _StatusPill({required this.accepted, required this.specs});

  @override
  Widget build(BuildContext context) {
    final bg = accepted ? specs.pantoneColor : specs.rBlushPink;
    final fg = accepted ? Colors.white : Colors.white;
    final label = accepted ? 'Accepted' : 'Refused';

    return Container(
      height: 35,
      width: 100,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: GoogleFonts.outfit(
          color: fg,
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      ),
    );
  }
}
