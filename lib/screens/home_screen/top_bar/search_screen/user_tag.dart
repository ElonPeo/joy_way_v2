import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:joy_way/config/general_specifications.dart';
import 'package:joy_way/models/user/basic_user_info.dart';
import 'package:joy_way/services/firebase_services/profile_services/profile_fire_storage_image.dart';

import '../../../profile_screen/profile_screen.dart';


class UserTag extends StatefulWidget {
  final BasicUserInfo userTagInformation;
  final VoidCallback? onTap;

  const UserTag({
    super.key,
    required this.userTagInformation,
    this.onTap,
  });

  @override
  State<UserTag> createState() => _UserTagState();
}

class _UserTagState extends State<UserTag> {
  final _imageSvc = ProfileFireStorageImage();

  bool _pressed = false;
  bool _loading = false;
  String? _avatarUrl;
  String? _err;

  void _safeSet(void Function() f) {
    if (!mounted) return;
    setState(f);
  }

  Future<void> _loadAvatar() async {
    final id = widget.userTagInformation.avatarImageId;
    if (id == null || id.isEmpty) {
      _safeSet(() {
        _avatarUrl = null;
        _err = null;
      });
      return;
    }

    _safeSet(() {
      _loading = true;
      _err = null;
    });

    final r = await _imageSvc.getImageUrlById(id);
    if (!mounted) return;

    _safeSet(() {
      _loading = false;
      _avatarUrl = r.url;
      _err = r.error;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadAvatar();
  }

  @override
  void didUpdateWidget(covariant UserTag oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userTagInformation.avatarImageId !=
        widget.userTagInformation.avatarImageId) {
      _loadAvatar();
    }
  }

  @override
  Widget build(BuildContext context) {
    final specs = GeneralSpecifications(context);
    final u = widget.userTagInformation;

    final initials = ((u.name?.isNotEmpty ?? false)
        ? u.name!.characters.first
        : (u.userName.isNotEmpty ? u.userName.characters.first : '?'))
        .toUpperCase();

    Widget avatar;
    if (_loading) {
      avatar = CircleAvatar(
        radius: 25,
        backgroundColor: specs.black200,
        child: const SizedBox(
          height: 18,
          width: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    } else if (_avatarUrl != null) {
      avatar = ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Image.network(
          _avatarUrl!,
          height: 50,
          width: 50,
          fit: BoxFit.cover,
          // giúp UX mượt hơn khi tải ảnh
          loadingBuilder: (c, child, progress) {
            if (progress == null) return child;
            return Container(
              height: 50, width: 50, color: specs.black200,
              alignment: Alignment.center,
              child: const SizedBox(
                height: 16, width: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          },
          errorBuilder: (c, e, s) {
            return CircleAvatar(
              radius: 25,
              backgroundColor: specs.black200,
              child: Text(
                initials,
                style: GoogleFonts.outfit(color: Colors.white, fontSize: 16),
              ),
            );
          },
        ),
      );
    } else {
      avatar = CircleAvatar(
        radius: 25,
        backgroundColor: specs.black200,
        child: Text(
          initials,
          style: GoogleFonts.outfit(color: Colors.white, fontSize: 16),
        ),
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _safeSet(() => _pressed = true),
      onTapUp: (_) async {
        await Future.delayed(const Duration(milliseconds: 50));
        if (!mounted) return;
        _safeSet(() => _pressed = false);
        widget.onTap?.call();
        Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (_) => ProfileScreen(
              isOwnerProfile: false,
              userId: u.uid,
            ),
          ),
        );
      },
      onTapCancel: () => _safeSet(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: specs.screenWidth,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        color: _pressed ? specs.black200 : Colors.white,
        child: Row(
          children: [
            avatar,
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 50,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (u.name?.isNotEmpty ?? false) ? u.name! : '@${u.userName}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.roboto(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '@${u.userName}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(
                        color: specs.black150,
                        fontSize: 12,
                      ),
                    ),
                    if (_err != null && _err != 'Permission denied')
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          _err!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.outfit(
                            color: Colors.red,
                            fontSize: 10,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
