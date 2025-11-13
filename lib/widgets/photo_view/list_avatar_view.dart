import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:joy_way/config/general_specifications.dart';
import 'package:joy_way/services/firebase_services/profile_services/profile_fire_storage_image.dart';


class ListAvatarView extends StatelessWidget {
  final List<String> userIds;
  final double size;         // đường kính mỗi avatar
  final double overlap;      // phần chồng (px), nên < size
  final int maxShown;        // tối đa số avatar hiển thị

  const ListAvatarView({
    super.key,
    required this.userIds,
    this.size = 48,
    this.overlap = 14,
    this.maxShown = 3,
  });

  Future<List<_AvatarData>> _fetchAll() async {
    final ids = userIds.take(maxShown).toList();
    return Future.wait(ids.map(_fetchAvatarForUser));
  }

  @override
  Widget build(BuildContext context) {
    final count = userIds.length.clamp(0, maxShown);
    final totalWidth = count <= 0
        ? 0.0
        : size + (count - 1) * (size - overlap);

    return SizedBox(
      width: totalWidth,
      height: size,
      child: FutureBuilder<List<_AvatarData>>(
        future: _fetchAll(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            // khung loading đơn giản
            return Stack(
              children: List.generate(count, (i) {
                return Positioned(
                  left: i * (size - overlap),
                  child: _LoadingCircle(size: size),
                );
              }),
            );
          }
          final items = snap.data ?? const <_AvatarData>[];
          return Stack(
            clipBehavior: Clip.none,
            children: [
              for (int i = 0; i < items.length; i++)
                Positioned(
                  left: i * (size - overlap),
                  child: _MiniAvatar(
                    data: items[i],
                    size: size,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// Dữ liệu avatar đã resolve
class _AvatarData {
  final String? url;      // URL ảnh đã resolve (có thể null)
  final String? name;     // tên để lấy chữ cái đầu
  _AvatarData({this.url, this.name});
}

/// Lấy avatar cho 1 userId: đọc users/{uid} -> avatarImageId -> resolve URL
Future<_AvatarData> _fetchAvatarForUser(String uid) async {
  try {
    final users = FirebaseFirestore.instance.collection('users');
    final snap = await users.doc(uid).get();
    if (!snap.exists) return _AvatarData(name: uid);

    final data = snap.data()!;
    final avatarImageId = (data['avatarImageId'] as String?) ?? '';
    final displayName = (data['userName'] as String?) ?? (data['name'] as String?) ?? uid;

    if (avatarImageId.isEmpty) {
      return _AvatarData(name: displayName);
    }

    final storage = ProfileFireStorageImage();
    final r = await storage.getImageUrlById(avatarImageId);
    return _AvatarData(url: r.url, name: displayName);
  } catch (_) {
    return _AvatarData(name: uid);
  }
}

/// 1 avatar tròn nhỏ (có bo viền trắng cho đẹp)
class _MiniAvatar extends StatelessWidget {
  final _AvatarData data;
  final double size;
  const _MiniAvatar({required this.data, required this.size});

  @override
  Widget build(BuildContext context) {
    final specs = GeneralSpecifications(context);
    final border = 2.0;

    Widget inner;
    if (data.url != null && data.url!.isNotEmpty) {
      inner = ClipRRect(
        borderRadius: BorderRadius.circular(9999),
        child: Image.network(
          data.url!,
          height: size,
          width: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _InitialsCircle(
            size: size,
            text: _initials(data.name),
          ),
          loadingBuilder: (_, child, progress) {
            if (progress == null) return child;
            return _LoadingCircle(size: size);
          },
        ),
      );
    } else {
      inner = _InitialsCircle(size: size, text: _initials(data.name));
    }

    return Container(
      height: size,
      width: size,
      padding: EdgeInsets.all(border),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: specs.black200.withOpacity(0.35),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: inner,
    );
  }

  String _initials(String? name) {
    if (name == null || name.trim().isEmpty) return 'U';
    final n = name.replaceAll('@', '').trim();
    final parts = n.split(RegExp(r'\s+'));
    final first = parts.isNotEmpty ? parts.first : '';
    final last = parts.length > 1 ? parts.last : '';
    final s = (first.isNotEmpty ? first.characters.first : '') +
        (last.isNotEmpty ? last.characters.first : '');
    return s.isEmpty ? 'U' : s.toUpperCase();
  }
}

/// Vòng tròn chữ cái đầu
class _InitialsCircle extends StatelessWidget {
  final double size;
  final String text;
  const _InitialsCircle({required this.size, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      decoration: const BoxDecoration(
        color: Color(0xFFEFEFEF),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: GoogleFonts.outfit(
          fontWeight: FontWeight.w600,
          fontSize: size * 0.38,
          color: const Color(0xFF333333),
        ),
      ),
    );
  }
}

/// Khối tròn “skeleton” khi loading
class _LoadingCircle extends StatelessWidget {
  final double size;
  const _LoadingCircle({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        color: const Color(0xFFEEEEEE),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      alignment: Alignment.center,
      child: const SizedBox(
        height: 14,
        width: 14,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }
}
