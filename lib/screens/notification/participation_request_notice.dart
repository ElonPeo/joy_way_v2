import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:joy_way/config/general_specifications.dart';
import 'package:joy_way/models/passenger/passengers.dart';
import 'package:joy_way/models/request/request_journey/request_journey.dart';
import 'package:joy_way/models/user/basic_user_info.dart';
import 'package:joy_way/services/data_processing/time_processing.dart';
import 'package:joy_way/services/firebase_services/profile_services/profile_firestore.dart';
import 'package:joy_way/services/firebase_services/request_services/request_firestore.dart';
import 'package:joy_way/widgets/animated_container/custom_animated_button.dart';
import 'package:joy_way/widgets/photo_view/avatar_view.dart';

import '../../models/request/app_request.dart';
import '../../services/data_processing/location_name_handling.dart';
import '../../services/firebase_services/passenger_services/passenger_firestore.dart';

class ParticipationRequestNotice extends StatefulWidget {
  final AppRequest appRequest;

  const ParticipationRequestNotice({
    super.key,
    required this.appRequest,
  });

  @override
  State<ParticipationRequestNotice> createState() =>
      _ParticipationRequestNoticeState();
}

class _ParticipationRequestNoticeState
    extends State<ParticipationRequestNotice> {
  BasicUserInfo? _sender;
  RequestJourney? _journey;

  bool _loadingSender = true;
  bool _busyAction = false;

  StreamSubscription<RequestJourney?>? _journeySub;

  @override
  void initState() {
    super.initState();
    _loadSender(); // lấy thông tin người gửi (one-shot)
    _listenJourneyDetail(); // lắng nghe trạng thái isAccepted realtime
  }

  Future<void> _loadSender() async {
    try {
      final r = await ProfileFirestore()
          .getBasicUserInfo(widget.appRequest.senderId);
      if (!mounted) return;
      setState(() {
        _sender = r.user;
        _loadingSender = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingSender = false);
    }
  }

  void _listenJourneyDetail() {
    _journeySub = RequestFirestore()
        .streamJourneyDetail(widget.appRequest.id)
        .listen((j) {
      if (!mounted) return;
      setState(() => _journey = j);
    });
  }

  Future<void> _setAccepted(bool val) async {
    if (_busyAction) return;
    setState(() => _busyAction = true);
    try {
      // Lấy postId an toàn
      final String? postId = _journey?.journeyId; // tuỳ bạn lưu
      if (val && (postId == null || postId.isEmpty)) {
        throw Exception('postId không có. Hãy map postId vào AppRequest hoặc Journey.');
      }

      // 1) Cập nhật request accepted/rejected
      await RequestFirestore().updateRequestAcceptance(
        requestId: widget.appRequest.id,
        isAccepted: val,
      );

      // 2) Nếu ACCEPT -> tạo passenger record
      if (val) {
        await PassengerFirestore().createPassengerRecord(
          postId: postId!,                         // đã check null phía trên
          userId: widget.appRequest.senderId,      // KHÔNG dùng _sender?.uid (có thể null)
          requestId: widget.appRequest.id,
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(val ? "Accepted." : "Refused.")),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      if (mounted) setState(() => _busyAction = false);
    }
  }



  @override
  void dispose() {
    _journeySub?.cancel();
    super.dispose();
  }

  Widget _buildChild(GeneralSpecifications specs) {
    final status = _journey?.isAccepted;
    if (status == null) {
      return Row(
        children: [
          CustomAnimatedButton(
            height: 35,
            width: 90,
            color: specs.black240,
            shadowColor: Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            onTap: _busyAction ? null : () => _setAccepted(false),
            child: Text(
              _busyAction ? "..." : "Refuse",
              style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ),
          const SizedBox(width: 10),
          CustomAnimatedButton(
            height: 35,
            width: 90,
            color: specs.pantoneColor,
            borderRadius: BorderRadius.circular(10),
            onTap: _busyAction ? null : () => _setAccepted(true),
            child: Text(
              _busyAction ? "..." : "Accept",
              style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: Colors.white),
            ),
          ),
        ],
      );
    }

    final accepted = status == true;
    return Container(
      height: 35,
      width: 110,
      decoration: BoxDecoration(
        color: accepted ? specs.pantoneColor : specs.black240,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          accepted ? "Accepted" : "Refused",
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: accepted ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final specs = GeneralSpecifications(context);

    final cmp = LocationNameHandling.comparePlaces(
      _journey?.pickUpName ?? "",
      _journey?.dropOffName ?? "",
    );
    final pick = cmp['dep'] ?? "";
    final drop = cmp['arr'] ?? "";

    final update = TimeProcessing.formatTimestamp(widget.appRequest.updatedAt);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // avatar + badge
          SizedBox(
            height: 60,
            width: 60,
            child: Stack(
              children: [
                Center(
                  child: _loadingSender
                      ? Container(
                    height: 50,
                    width: 50,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black12,
                    ),
                  )
                      : AvatarView(
                    size: 50,
                    imageId: _sender?.avatarImageId,
                    nameUser: _sender?.name ?? _sender?.userName,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    height: 24,
                    width: 24,
                    decoration: BoxDecoration(
                      color: specs.pantoneColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: ImageIcon(
                        AssetImage("assets/icons/notifications/question.png"),
                        size: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),

          // text + actions
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // câu mô tả
                RichText(
                  textAlign: TextAlign.start,
                  text: TextSpan(
                    style: const TextStyle(fontSize: 14, color: Colors.black),
                    children: [
                      TextSpan(
                        text: (_sender?.userName != null &&
                            (_sender!.userName?.isNotEmpty ?? false))
                            ? "@${_sender!.userName} "
                            : "Someone ",
                        style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w500, fontSize: 14),
                      ),
                      TextSpan(
                        text: "wants a ride from ",
                        style: GoogleFonts.outfit(fontSize: 14),
                      ),
                      TextSpan(
                        text: pick,
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          color: specs.pantoneColor4,
                        ),
                      ),
                      TextSpan(
                        text: " to ",
                        style: GoogleFonts.outfit(fontSize: 14),
                      ),
                      TextSpan(
                        text: drop,
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          color: specs.pantoneColor4,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),
                Text(
                  "JID: ${widget.appRequest.id}",
                  style:
                  GoogleFonts.outfit(fontSize: 11, color: specs.black150),
                ),
                Text(
                  update,
                  style: GoogleFonts.outfit(
                      fontSize: 11, color: specs.black150),
                ),
                const SizedBox(height: 8),

                _buildChild(specs),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
