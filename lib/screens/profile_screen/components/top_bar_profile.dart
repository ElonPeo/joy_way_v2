import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:joy_way/config/general_specifications.dart';
import 'package:joy_way/services/firebase_services/profile_services/user_activity_services.dart';
import 'package:joy_way/widgets/animated_container/loading_container.dart';

import '../../../../widgets/animated_container/custom_animated_button.dart';
import '../../../services/firebase_services/request_services/make_friend_firestore.dart';
import '../../message_screen/message_room_screen.dart';
import '../../setting/edit_profile/edit_profile.dart';
import '../../setting/setting_and_privacy.dart';

class TopBarProfile extends StatefulWidget {
  final bool isOwnerProfile;
  final String userId;
  final String userName;
  final String? imageId;
  final Color colorButton;

  const TopBarProfile({
    super.key,
    required this.isOwnerProfile,
    required this.userId,
    required this.userName,
    required this.imageId,
    this.colorButton = const Color.fromRGBO(255, 255, 255, 0.8),
  });

  @override
  State<TopBarProfile> createState() => _TopBarProfileState();
}

class _TopBarProfileState extends State<TopBarProfile> {
  bool _isFollowed = false;
  bool _busy = false;
  String? _myUid;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _myUid = FirebaseAuth.instance.currentUser?.uid;
    _initFollow();
  }

  Future<void> _initFollow() async {
    if (_myUid == null || _myUid == widget.userId) {
      // chủ profile hoặc chưa đăng nhập
      setState(() => _ready = true);
      return;
    }
    final isF = await UserActivityServices.I.isFollowing(
      myUid: _myUid!,
      targetUid: widget.userId,
    );
    if (!mounted) return;
    setState(() {
      _isFollowed = isF;
      _ready = true; // đánh dấu đã có trạng thái ban đầu
    });
  }

  @override
  void didUpdateWidget(covariant TopBarProfile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userId != widget.userId) {
      setState(() {
        _ready = false;
        _isFollowed = false;
      });
      _initFollow();
    }
  }



  Future<void> _toggleFollowAndMakeFriend() async {
    if (_busy || _myUid == null || _myUid == widget.userId) return;
    setState(() => _busy = true);

    try {
      final List<Future> tasks = [];

      // follow / unfollow
      if (_isFollowed) {
        tasks.add(UserActivityServices.I.unfollow(
          myUid: _myUid!,
          targetUid: widget.userId,
        ));
      } else {
        tasks.add(UserActivityServices.I.follow(
          myUid: _myUid!,
          targetUid: widget.userId,
        ));
      }

      // gửi lời mời kết bạn
      tasks.add(
        MakeFriendFirestore().createRequest(
          senderId: _myUid!,
          receiverId: widget.userId,
        ),
      );

      // chạy cả 2 cùng lúc
      final results = await Future.wait(tasks);

      // check lỗi từ createRequest
      final mfError = results.last;
      if (mfError != null) {
        debugPrint("MakeFriend error: $mfError");
      }

      if (!mounted) return;
      setState(() => _isFollowed = !_isFollowed);

    } catch (e) {
      debugPrint("ERR: $e");
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    final specs = GeneralSpecifications(context);

    return Container(
      width: specs.screenWidth,
      height: 90,
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 15),
      child: widget.isOwnerProfile
          ? Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                CustomAnimatedButton(
                  onTap: () {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(builder: (_) => const EditProfile()),
                    );
                  },
                  height: 35,
                  width: 80,
                  color: widget.colorButton,
                  shadowColor: Colors.transparent,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const ImageIcon(
                        AssetImage("assets/icons/setting/user-pen.png"),
                        size: 14,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        "Edit",
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                CustomAnimatedButton(
                  onTap: () {},
                  height: 35,
                  width: 35,
                  color: widget.colorButton,
                  shadowColor: Colors.transparent,
                  child: const Center(
                    child: ImageIcon(
                      AssetImage("assets/icons/setting/qr.png"),
                      size: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                CustomAnimatedButton(
                  onTap: () {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (_) => const SettingAndPrivacy(),
                      ),
                    );
                  },
                  height: 35,
                  width: 35,
                  color: widget.colorButton,
                  shadowColor: Colors.transparent,
                  child: const Center(
                    child: ImageIcon(
                      AssetImage("assets/icons/setting/gears.png"),
                      size: 14,
                    ),
                  ),
                ),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                CustomAnimatedButton(
                  onTap: () => Navigator.pop(context),
                  height: 35,
                  width: 80,
                  color: widget.colorButton,
                  shadowColor: Colors.transparent,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const ImageIcon(
                        AssetImage("assets/icons/other_icons/angle-left.png"),
                        size: 14,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        "Back",
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                      )
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _ready ?
                    CustomAnimatedButton(
                      onTap: _toggleFollowAndMakeFriend,
                      height: 35,
                      width: 110,
                      color: _isFollowed
                          ? specs.pantoneColor4
                          : widget.colorButton,
                      shadowColor: Colors.transparent,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _isFollowed ? "Following" : "Follow",
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: _isFollowed ? Colors.white : Colors.black,
                            ),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          if (_busy)
                            const SizedBox(
                              height: 14,
                              width: 14,
                              child: CupertinoActivityIndicator(radius: 7),
                            )
                          else if (_isFollowed)
                            Icon(
                              Icons.check,
                              size: 16,
                              color: _isFollowed ? Colors.white : Colors.black,
                            ),
                        ],
                      ),
                    ) :
                        LoadingContainer(                   height: 35,
                          width: 110,
                          borderRadius: BorderRadius.circular(100),
                          baseColor: Colors.white,
                          overlayColor: specs.black240,
                        ),

                    const SizedBox(width: 10),
                    // MESSAGE
                    CustomAnimatedButton(
                      onTap: () {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (_) => MessageRoomScreen(
                              userName: widget.userName,
                              imageId: widget.imageId,
                              userId: widget.userId,
                            ),
                          ),
                        );
                      },
                      height: 35,
                      width: 35,
                      color: widget.colorButton,
                      shadowColor: Colors.transparent,
                      child: const Center(
                        child: ImageIcon(
                          AssetImage("assets/icons/bottom_bar/beacon.png"),
                          size: 14,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
    );
  }
}
