import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:joy_way/config/general_specifications.dart';
import 'package:joy_way/models/user/basic_user_info.dart';

import 'package:joy_way/services/firebase_services/profile_services/profile_firestore.dart';
import 'package:joy_way/services/firebase_services/profile_services/profile_fire_storage_image.dart';
import 'package:joy_way/services/firebase_services/message_services/message_services.dart';
import 'package:joy_way/widgets/animated_container/flashing_container.dart';

import '../../widgets/photo_view/avatar_view.dart';
import 'message_room_screen.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  BasicUserInfo? _me;
  late final String _myUid;

  final _pageCtrl = PageController();
  int _pageIndex = 0;

  @override
  void initState() {
    super.initState();
    _myUid = FirebaseAuth.instance.currentUser!.uid;
    _loadMe();
  }

  void _goPage(int index) {
    setState(() => _pageIndex = index);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_pageCtrl.hasClients) {
        _pageCtrl.animateToPage(
          index,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
        );
      }
    });
  }


  Future<void> _loadMe() async {
    final pf = ProfileFirestore();
    final r = await pf.getBasicUserInfo(_myUid);
    BasicUserInfo? me = r.user;
    if (!mounted) return;
    setState(() {
      _me = me;
    });
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final specs = GeneralSpecifications(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // ===== Top bar =====
          Container(
            height: 100,
            width: specs.screenWidth,
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _me?.userName != null ? '@${_me!.userName}' : '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.outfit(
                      fontSize: 22, fontWeight: FontWeight.w500),
                ),

                ImageIcon(
                    AssetImage(
                        "assets/icons/setting/qr.png"),
                    color: Colors.black,
                    size: 20),

              ],
            ),
          ),
          Container(
            height: 45,
            width: specs.screenWidth - 30,
            decoration: BoxDecoration(
              color: specs.black240,
              borderRadius: BorderRadius.circular(40),
            ),
            child: Row(
              children: [
                SizedBox(
                  height: 45,
                  width: 45,
                  child: Center(
                    child: Container(
                      height: 38,
                      width: 38,
                      decoration:  BoxDecoration(
                          color: Colors.black, shape: BoxShape.circle),
                      child: const Center(
                        child: ImageIcon(
                            AssetImage(
                                "assets/icons/other_icons/search.png"),
                            color: Colors.white,
                            size: 20),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text("Search for messages",
                    style: GoogleFonts.outfit(
                        color: specs.black80, fontSize: 14)),
              ],
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Container(
            height: 80,
            width: specs.screenWidth,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 15),
              children: [
                SizedBox(
                  height: 80,
                  width: 60,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AvatarView(
                        size: 60,
                        nameUser: _me?.name,
                        imageId: _me?.avatarImageId,
                      ),
                      Text(
                        "You",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  width: 15,
                ),
                SizedBox(
                  height: 80,
                  width: 60,
                  child: Column(
                    children: [
                      AvatarView(
                        size: 60,
                      ),
                      Text(
                        "",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  width: 15,
                ),
                SizedBox(
                  height: 80,
                  width: 60,
                  child: Column(
                    children: [
                      Container(
                        height: 60,
                        width: 60,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: specs.black240
                        ),
                        child: Center(
                          child: ImageIcon(
                            AssetImage("assets/icons/other_icons/plus.png"),
                            color: specs.black100,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(
            height: 15,
          ),
          // ===== Header + Segmented =====
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => _goPage(0),
                child: Container(
                    height: 30,
                    width: 80,
                    decoration: BoxDecoration(
                      color: _pageIndex == 0 ? specs.pantoneColor4 : specs.black240,
                      borderRadius: BorderRadius.horizontal(
                        right: Radius.circular(100)
                      )
                    ),
                    child: Center(
                      child: Text(
                        "Messages",
                        style: GoogleFonts.outfit(
                          color: _pageIndex == 0 ? Colors.white : specs.black150,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    )),
              ),
              GestureDetector(
                onTap: () => _goPage(1),
                child: Container(
                    height: 30,
                    width: 130,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.horizontal(
                          left: Radius.circular(100)
                      ),
                      color: _pageIndex == 1 ? specs.pantoneColor4 : specs.black240,
                    ),
                    child: Center(
                      child: Text("Messages waiting",
                        style: GoogleFonts.outfit(
                          color: _pageIndex == 1 ? Colors.white : specs.black150,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    )),
              ),

            ],
          ),

          // ===== Body: PageView 2 trang =====
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: MessageServices.I
                  .streamRecentRooms(myUid: _myUid, limit: 100),
              builder: (ctx, snap) {
                final docs = snap.data?.docs ?? const [];
                // Chuyển thành list room đơn giản
                final rooms = docs.map((d) {
                  final m = d.data();
                  return _Room(
                    id: d.id,
                    participants:
                        List<String>.from(m['participants'] ?? const []),
                    lastMessage: (m['lastMessage'] ?? '') as String,
                    lastSenderId: (m['lastSenderId'] ?? '') as String,
                    unread: Map<String, dynamic>.from(m['unread'] ?? const {}),
                    updatedAt: m['updatedAt'],
                  );
                }).toList();

                final waiting = rooms.where((r) {
                  final u = (r.unread[_myUid] ?? 0);
                  return u is int && u > 0 && r.lastSenderId != _myUid;
                }).toList();

                final normal = rooms
                    .where((r) => !waiting.any((w) => w.id == r.id))
                    .toList();

                return PageView(
                  controller: _pageCtrl,
                  onPageChanged: (i) => setState(() => _pageIndex = i),
                  children: [
                    _RoomList(
                      key: const PageStorageKey('messages_normal'),
                      rooms: normal,
                      myUid: _myUid,
                    ),
                    _RoomList(
                      key: const PageStorageKey('messages_waiting'),
                      rooms: waiting,
                      myUid: _myUid,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}


class _RoomList extends StatelessWidget {
  final List<_Room> rooms;
  final String myUid;

  const _RoomList({super.key, required this.rooms, required this.myUid});

  @override
  Widget build(BuildContext context) {
    if (rooms.isEmpty) {
      return const Center(child: Text('No conversations'));
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: rooms.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (ctx, i) => _RoomTile(room: rooms[i], myUid: myUid),
    );
  }
}

class _RoomTile extends StatefulWidget {
  final _Room room;
  final String myUid;

  const _RoomTile({required this.room, required this.myUid});

  @override
  State<_RoomTile> createState() => _RoomTileState();
}

class _RoomTileState extends State<_RoomTile> {
  BasicUserInfo? _peer;

  @override
  void initState() {
    super.initState();
    _loadPeer();
  }

  Future<void> _loadPeer() async {
    final peerId = widget.room.participants
        .firstWhere((e) => e != widget.myUid, orElse: () => widget.myUid);
    final pf = ProfileFirestore();
    final r = await pf.getBasicUserInfo(peerId);
    BasicUserInfo? peer = r.user;

    if (!mounted) return;
    setState(() {
      _peer = peer;

    });
  }

  void _openRoom() {
    final peerId = widget.room.participants
        .firstWhere((e) => e != widget.myUid, orElse: () => widget.myUid);
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => MessageRoomScreen(
        userName: _peer?.userName != null ? '@${_peer!.userName}' : 'Unknown',
        userId: peerId,
        imageId: _peer?.avatarImageId,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final specs = GeneralSpecifications(context);
    final unreadMine = (widget.room.unread[widget.myUid] ?? 0);
    final hasUnread = unreadMine is int && unreadMine > 0;
    return GestureDetector(
      onTap: _openRoom,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 10
        ),
        color: Colors.transparent,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                AvatarView(
                  nameUser: _peer?.userName,
                  imageId: _peer?.avatarImageId,
                ),
                SizedBox(
                  width: 10,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _peer?.userName != null ? '@${_peer!.userName}' : 'Unknown',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      widget.room.lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(fontSize: 13, color: Colors.black54),
                    ),
                  ],
                )
              ],
            ),
            ImageIcon(
              AssetImage(
                "assets/icons/other_icons/angle-right.png",
              ),
              size: 18,
              color: specs.black240,
            )

          ],
        ),
      ),
    );
  }
}

class _Room {
  final String id;
  final List<String> participants;
  final String lastMessage;
  final String lastSenderId;
  final Map<String, dynamic> unread;
  final dynamic updatedAt;

  _Room({
    required this.id,
    required this.participants,
    required this.lastMessage,
    required this.lastSenderId,
    required this.unread,
    required this.updatedAt,
  });
}
