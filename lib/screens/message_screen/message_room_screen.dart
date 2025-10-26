import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:joy_way/config/general_specifications.dart';

import '../../../services/firebase_services/message_services/message_services.dart';
import '../../../widgets/animated_container/custom_animated_button.dart';


class MessageRoomScreen extends StatefulWidget{
  final String userName;
  final String userId;
  final ImageProvider? imageProvider;
  const MessageRoomScreen({
    super.key,
    required this.userName,
    required this.imageProvider,
    required this.userId,
  });

  @override
  State<MessageRoomScreen> createState() => _MessageRoomState();
}

class _MessageRoomState extends State<MessageRoomScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _listCtrl = ScrollController();
  final FocusNode _focus = FocusNode();

  String? _roomId;
  late final String _myUid;

  @override
  void initState() {
    super.initState();
    _myUid = FirebaseAuth.instance.currentUser!.uid;
    _setupRoom();
  }

  Future<void> _setupRoom() async {
    final id = await MessageServices.I.getOrCreateRoom(_myUid, widget.userId);
    setState(() => _roomId = id);
    await MessageServices.I.markAsRead(roomId: id, myUid: _myUid);
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _roomId == null) return;
    _controller.clear();
    await MessageServices.I.sendInRoom(
      roomId: _roomId!,
      senderId: _myUid,
      text: text,
    );
    if (_listCtrl.hasClients) {
      _listCtrl.animateTo(
        0,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _listCtrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final specs = GeneralSpecifications(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            height: 90,
            width: specs.screenWidth,
            padding: const EdgeInsets.only(left: 12, right: 16, bottom: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: specs.black240, width: 0.5)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SizedBox(
                  width: 48,
                  child: CustomAnimatedButton(
                    onTap: () => Navigator.pop(context),
                    height: 30,
                    width: 30,
                    color: Colors.transparent,
                    shadowColor: Colors.transparent,
                    child: const Center(
                      child: ImageIcon(
                        AssetImage("assets/icons/other_icons/angle-left.png"),
                        size: 22,
                      ),
                    ),
                  ),
                ),
                if (widget.imageProvider != null) ...[
                  CircleAvatar(radius: 16, backgroundImage: widget.imageProvider),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: Text(
                    widget.userName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: _roomId == null
                ? const SizedBox()
                : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: MessageServices.I.streamRecentMessages(
                roomId: _roomId!,
                limit: 30,
              ),
              builder: (ctx, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const SizedBox.shrink();
                }
                final docs = snap.data?.docs ?? const [];
                return ListView.builder(
                  controller: _listCtrl,
                  reverse: true,
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  itemCount: docs.length,
                  itemBuilder: (_, i) {
                    final m = docs[i].data();
                    final isMe = m['senderId'] == _myUid;
                    final text = (m['content'] ?? '') as String;
                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        constraints: BoxConstraints(maxWidth: specs.screenWidth * 0.7),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.blue.shade50 : specs.black240,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          text,
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            color: isMe ? Colors.black : Colors.black87,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.only(bottom: bottomInset > 0 ? 0 : 10),
              child: Container(
                width: specs.screenWidth,
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: specs.black240, width: 0.5)),
                ),
                padding: const EdgeInsets.all(10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 45, width: 45,
                      child: Center(
                        child: ImageIcon(
                          const AssetImage("assets/icons/messenger/add-image.png"),
                          size: 25,
                          color: specs.black100,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 45, width: 45,
                      child: Center(
                        child: ImageIcon(
                          const AssetImage("assets/icons/other_icons/pin.png"),
                          size: 25,
                          color: specs.black100,
                        ),
                      ),
                    ),
                    Expanded(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        height: 45,
                        decoration: BoxDecoration(
                          color: specs.black240,
                          borderRadius: BorderRadius.circular(45),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Center(
                          child: TextField(
                            controller: _controller,
                            focusNode: _focus,
                            autofocus: true,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "Aa",
                              hintStyle: GoogleFonts.outfit(
                                color: specs.black200,
                                fontSize: 14,
                              ),
                              isCollapsed: true,
                              contentPadding: const EdgeInsets.only(bottom: 1),
                            ),
                            textAlignVertical: TextAlignVertical.center,
                            textInputAction: TextInputAction.send,
                            onSubmitted: (_) => _send(),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: _send,
                      behavior: HitTestBehavior.opaque,
                      child: SizedBox(
                        height: 45, width: 45,
                        child: Center(
                          child: ImageIcon(
                            const AssetImage("assets/icons/map/paper-plane.png"),
                            size: 25,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
