import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:joy_way/config/general_specifications.dart';
import 'package:joy_way/models/request/request_journey/request_join_journey/request_join_journey.dart';
import 'package:joy_way/models/user/basic_user_info.dart';
import 'package:joy_way/services/data_processing/time_processing.dart';
import 'package:joy_way/services/firebase_services/profile_services/profile_firestore.dart';
import 'package:joy_way/widgets/animated_container/custom_animated_button.dart';
import 'package:joy_way/widgets/photo_view/avatar_view.dart';

import '../../../services/data_processing/location_name_handling.dart';
// ✳️ Thêm 2 import dưới để gọi service và show thông báo
import 'package:joy_way/services/firebase_services/request_services/request_journey_services/request_join_journey_services.dart';
import 'package:joy_way/widgets/notifications/show_notification.dart';

import '../../../services/firebase_services/passenger_services/passenger_firestore.dart';

class RequestJoinCard extends StatefulWidget {
  final RequestJoinJourney requestJoinJourney;

  const RequestJoinCard({
    super.key,
    required this.requestJoinJourney,
  });

  @override
  State<RequestJoinCard> createState() => _RequestJoinCardState();
}

class _RequestJoinCardState extends State<RequestJoinCard> {

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

    final List<String> dep = LocationNameHandling
        .splitPlaceParts(widget.requestJoinJourney.pickUpName ?? "");
    final List<String> arr = LocationNameHandling
        .splitPlaceParts(widget.requestJoinJourney.dropOffName ?? "");

    final depProvince = dep.isNotEmpty ? dep.last : '';
    final arrProvince = arr.isNotEmpty ? arr.last : '';
    final depRest = dep.length > 1 ? dep.sublist(0, dep.length - 1).join(', ') : '';
    final arrRest = arr.length > 1 ? arr.sublist(0, arr.length - 1).join(', ') : '';

    final timeStr = TimeProcessing
        .formatTimestamp(widget.requestJoinJourney.updatedAt ??
        widget.requestJoinJourney.createdAt) ??
        '';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(width: 1, color: specs.black240),
        ),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(width: 5),
              AvatarView(
                imageId: _sender?.avatarImageId,
                nameUser: _sender?.userName,
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: specs.screenWidth - 100,
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
                          const TextSpan(
                              text: ' sent a request to join the journey.'),
                        ],
                      ),
                    ),
                    Text(
                      timeStr,
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        color: specs.black150,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              )
            ],
          ),

          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: (specs.screenWidth - 70) / 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      depProvince,
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      depRest,
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color: specs.black150,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              ImageIcon(
                const AssetImage("assets/icons/notifications/right.png"),
                color: specs.pantoneColor4,
                size: 18,
              ),
              SizedBox(
                width: (specs.screenWidth - 70) / 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      arrProvince,
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      arrRest,
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color: specs.black150,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          // Hành động / Trạng thái
          if (_acceptedLocal == null)
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
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
                    ),
                  ),
                ),
              ],
            )
          else
            _StatusPill(accepted: _acceptedLocal!, specs: specs),
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

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          height: 35,
          width: 100,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.outfit(
                color: fg,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }
}