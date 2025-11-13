import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:joy_way/config/general_specifications.dart';
import 'package:joy_way/models/request/make_friend.dart';

import '../../models/user/basic_user_info.dart';
import '../../services/data_processing/time_processing.dart';
import '../../services/firebase_services/profile_services/profile_firestore.dart';
import '../../widgets/animated_container/custom_animated_button.dart';
import '../../widgets/photo_view/avatar_view.dart';

class FriendRequestNoticeCard extends StatefulWidget {
  final MakeFriend makeFriend;
  const FriendRequestNoticeCard({
    super.key,
    required this.makeFriend,
  });

  @override
  State<FriendRequestNoticeCard> createState() => _FriendRequestNoticeCardState();
}

class _FriendRequestNoticeCardState extends State<FriendRequestNoticeCard> {
  BasicUserInfo? _sender;
  bool _loadingSender = true;
  bool _busyAction = false;

  bool? _acceptedLocal;

  Future<void> _loadSender() async {
    final r = await ProfileFirestore().getBasicUserInfo(widget.makeFriend.senderId);
    if (!mounted) return;
    setState(() {
      _sender = r.user;
      _loadingSender = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _acceptedLocal = widget.makeFriend.isAccepted;
    _loadSender();
  }

  Future<void> _accept() async {
    if (_busyAction) return;
    setState(() => _busyAction = true);
    try {
      await FirebaseFirestore.instance
          .collection('make_friend_requests')
          .doc(widget.makeFriend.id)
          .update({
        'isAccepted': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      if (!mounted) return;
      setState(() => _acceptedLocal = true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Accept failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _busyAction = false);
    }
  }

  Future<void> _dismiss() async {
    if (_busyAction) return;
    setState(() => _busyAction = true);
    try {
      await FirebaseFirestore.instance
          .collection('make_friend_requests')
          .doc(widget.makeFriend.id)
          .delete();
      if (!mounted) return;
      setState(() => _acceptedLocal = false);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Dismiss failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _busyAction = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final specs = GeneralSpecifications(context);
    final r = widget.makeFriend;
    final timeStr = TimeProcessing.formatTimestamp(r.updatedAt ?? r.createdAt);

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

          // Content
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
                        text: _loadingSender
                            ? '@loading...'
                            : '@${_sender?.userName ?? 'unknown'}',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                      ),
                      const TextSpan(text: ' sent a request to make friend.'),
                    ],
                  ),
                ),

                const SizedBox(height: 4),
                Text(
                  "Update $timeStr",
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    color: specs.black150,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 10),

                // Hành động
                if (_acceptedLocal == null) ...[
                  Row(
                    children: [
                      CustomAnimatedButton(
                        height:35,
                        width: 100,
                        onTap: _busyAction ? null : _accept,
                        borderRadius: BorderRadius.circular(10),
                        child: _busyAction
                            ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                            : Text(
                          'Accept',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w400,
                            color: Colors.white,
                          ),
                        ),
                        color: _busyAction
                            ? specs.black150
                            : specs.pantoneColor,
                      ),
                      const SizedBox(width: 10),
                      CustomAnimatedButton(
                        shadowColor: Colors.transparent,
                        onTap: _busyAction ? null : _dismiss,
                        borderRadius: BorderRadius.circular(10),
                        child: Text(
                          'Dismiss',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w400,
                            color: Colors.black,
                          ),
                        ),
                        color: Colors.grey.shade200,
                        height:35,
                        width: 100,
                      ),
                    ],
                  ),
                ] else if (_acceptedLocal == true) ...[
                  Text(
                    'You accepted this request',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2E7D32),
                    ),
                  ),
                ] else ...[
                  Text(
                    'Request removed',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: specs.black150,
                    ),
                  ),

                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
