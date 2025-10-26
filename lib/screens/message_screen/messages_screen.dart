import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:joy_way/config/general_specifications.dart';
import 'package:joy_way/models/user/basic_user_info.dart';

import 'package:joy_way/services/firebase_services/profile_services/profile_firestore.dart';
import 'package:joy_way/services/firebase_services/profile_services/profile_fire_storage_image.dart';
import 'package:joy_way/services/firebase_services/message_services/message_services.dart';

import 'message_room_screen.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  BasicUserInfo? _me;
  ImageProvider _avatar = const AssetImage('assets/background/photo_not_available.jpg');
  late final String _myUid;

  final _pageCtrl = PageController();
  int _pageIndex = 0;

  @override
  void initState() {
    super.initState();
    _myUid = FirebaseAuth.instance.currentUser!.uid;
    _loadMe();
  }

  Future<void> _loadMe() async {
    final pf = ProfileFirestore();
    final r = await pf.getBasicUserInfo(_myUid);
    BasicUserInfo? me = r.user;

    ImageProvider avatar = _avatar;
    if (me?.avatarImageId != null && me!.avatarImageId!.isNotEmpty) {
      final storage = ProfileFireStorageImage();
      final ar = await storage.getImageUrlById(me.avatarImageId!);
      if (ar.url != null) avatar = NetworkImage(ar.url!);
    }
    if (!mounted) return;
    setState(() {
      _me = me;
      _avatar = avatar;
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
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 15),
            decoration: BoxDecoration(
              color: const Color.fromRGBO(255, 255, 255, 0.85),
              border: Border(bottom: BorderSide(width: 1, color: specs.black240)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                CircleAvatar(radius: 25, backgroundImage: _avatar),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _me?.userName != null ? '@${_me!.userName}' : '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),

          // ===== Header + Segmented =====
          Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.center,
            child: _HeaderSegmented(
              index: _pageIndex,
              onTap: (i) {
                setState(() => _pageIndex = i);
                _pageCtrl.animateToPage(i, duration: const Duration(milliseconds: 180), curve: Curves.easeOut);
              },
            ),
          ),

          // ===== Body: PageView 2 trang =====
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: MessageServices.I.streamRecentRooms(myUid: _myUid, limit: 100),
              builder: (ctx, snap) {
                final docs = snap.data?.docs ?? const [];
                // Chuyển thành list room đơn giản
                final rooms = docs.map((d) {
                  final m = d.data();
                  return _Room(
                    id: d.id,
                    participants: List<String>.from(m['participants'] ?? const []),
                    lastMessage: (m['lastMessage'] ?? '') as String,
                    lastSenderId: (m['lastSenderId'] ?? '') as String,
                    unread: Map<String, dynamic>.from(m['unread'] ?? const {}),
                    updatedAt: m['updatedAt'],
                  );
                }).toList();

                // Partition:
                // Message: bạn đã từng trả lời (có message của bạn) hoặc không còn unread từ người kia
                // Message waiting: tin người ta nhắn trước + còn unread với bạn
                // => đơn giản: nếu unread[myUid] > 0 && lastSenderId != myUid => waiting
                final waiting = rooms.where((r) {
                  final u = (r.unread[_myUid] ?? 0);
                  return u is int && u > 0 && r.lastSenderId != _myUid;
                }).toList();

                final normal = rooms.where((r) => !waiting.any((w) => w.id == r.id)).toList();

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

// ===================== Widgets =====================

class _HeaderSegmented extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;
  const _HeaderSegmented({required this.index, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final specs = GeneralSpecifications(context);
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: specs.black240,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _SegBtn(label: 'Message', selected: index == 0, onTap: () => onTap(0)),
          _SegBtn(label: 'Message waiting', selected: index == 1, onTap: () => onTap(1)),
        ],
      ),
    );
  }
}

class _SegBtn extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _SegBtn({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          alignment: Alignment.center,
          height: 32,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.black : Colors.black87,
            ),
          ),
        ),
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
  ImageProvider _avatar = const AssetImage('assets/background/photo_not_available.jpg');

  @override
  void initState() {
    super.initState();
    _loadPeer();
  }

  Future<void> _loadPeer() async {
    final peerId = widget.room.participants.firstWhere((e) => e != widget.myUid, orElse: () => widget.myUid);
    final pf = ProfileFirestore();
    final r = await pf.getBasicUserInfo(peerId);
    BasicUserInfo? peer = r.user;

    ImageProvider avatar = _avatar;
    if (peer?.avatarImageId != null && peer!.avatarImageId!.isNotEmpty) {
      final storage = ProfileFireStorageImage();
      final ar = await storage.getImageUrlById(peer.avatarImageId!);
      if (ar.url != null) avatar = NetworkImage(ar.url!);
    }
    if (!mounted) return;
    setState(() {
      _peer = peer;
      _avatar = avatar;
    });
  }

  void _openRoom() {
    final peerId = widget.room.participants.firstWhere((e) => e != widget.myUid, orElse: () => widget.myUid);
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => MessageRoomScreen(
        userName: _peer?.userName != null ? '@${_peer!.userName}' : 'Unknown',
        userId: peerId,
        imageProvider: _avatar,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final specs = GeneralSpecifications(context);
    final unreadMine = (widget.room.unread[widget.myUid] ?? 0);
    final hasUnread = unreadMine is int && unreadMine > 0;

    return ListTile(
      onTap: _openRoom,
      leading: CircleAvatar(radius: 22, backgroundImage: _avatar),
      title: Text(
        _peer?.userName != null ? '@${_peer!.userName}' : 'Unknown',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        widget.room.lastMessage,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.outfit(fontSize: 13, color: Colors.black54),
      ),
      trailing: hasUnread
          ? Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.redAccent, borderRadius: BorderRadius.circular(12),
        ),
        child: Text('$unreadMine', style: const TextStyle(color: Colors.white, fontSize: 12)),
      )
          : Icon(Icons.chevron_right, color: specs.black200),
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
