import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:joy_way/config/general_specifications.dart';
import 'package:joy_way/widgets/animated_container/loading_container.dart';
import '../../services/firebase_services/profile_services/profile_fire_storage_image.dart';

class AvatarView extends StatefulWidget {
  // Nếu có URL trực tiếp thì ưu tiên dùng luôn (nhanh).
  final String? imageUrl;

  // Nếu chỉ có imageId (path trong Firebase Storage) thì widget sẽ tự lấy URL.
  final String? imageId;

  // Dùng để vẽ fallback chữ cái đầu khi không có ảnh.
  final String? nameUser;

  // Kích thước cạnh
  final double size;

  // Bo góc (mặc định hình tròn).
  final double borderRadius;

  const AvatarView({
    super.key,
    this.imageUrl,
    this.imageId,
    this.nameUser,
    this.size = 55,
    double? borderRadius,
  }) : borderRadius = borderRadius ?? 9999;
  // đặt borderRadius to để mặc định là tròn
  @override
  State<AvatarView> createState() => _AvatarViewState();
}

class _AvatarViewState extends State<AvatarView> {
  final _imageSvc = ProfileFireStorageImage();

  bool _loading = false;
  String? _resolvedUrl;
  String? _err;

  @override
  void initState() {
    super.initState();
    _resolveUrl();
  }

  @override
  void didUpdateWidget(covariant AvatarView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl || oldWidget.imageId != widget.imageId) {
      _resolveUrl();
    }
  }

  Future<void> _resolveUrl() async {
    if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty) {
      setState(() {
        _resolvedUrl = widget.imageUrl;
        _err = null;
        _loading = false;
      });
      return;
    }
    if (widget.imageId == null || widget.imageId!.isEmpty) {
      setState(() {
        _resolvedUrl = null;
        _err = null;
        _loading = false;
      });
      return;
    }

    setState(() {
      _loading = true;
      _err = null;
    });

    final r = await _imageSvc.getImageUrlById(widget.imageId!);
    if (!mounted) return;

    setState(() {
      _loading = false;
      _resolvedUrl = r.url;
      _err = r.error;
    });
  }

  String _initials() {
    final n = widget.nameUser?.trim();
    if (n == null || n.isEmpty) return 'U';
    final parts = n.replaceAll('@', '').split(RegExp(r'\s+'));
    final first = parts.isNotEmpty ? parts.first : '';
    final last = parts.length > 1 ? parts.last : '';
    final s = (first.isNotEmpty ? first[0] : '') + (last.isNotEmpty ? last[0] : '');
    return s.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    final radius = widget.borderRadius;
    final specs = GeneralSpecifications(context);
    // Loading state
    if (_loading) {
      return LoadingContainer(
        height: size,
        width: size,
        baseColor: specs.black240,
        overlayColor: specs.black200,
        borderRadius: BorderRadius.circular(9999),
      );
    }

    // Có URL ảnh
    if (_resolvedUrl != null && _resolvedUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Image.network(
          _resolvedUrl!,
          height: size,
          width: size,
          fit: BoxFit.cover,
          // Hiển thị progress trong lúc Image.network tải
          loadingBuilder: (c, child, progress) {
            if (progress == null) return child;
            return Container(
              height: size,
              width: size,
              color: const Color(0xFFEEEEEE),
              alignment: Alignment.center,
              child: const SizedBox(
                height: 16,
                width: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          },
          errorBuilder: (c, e, s) => _fallbackCircle(size),
        ),
      );
    }
    return _fallbackCircle(size);
  }

  Widget _fallbackCircle(double size) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        color: const Color(0xFFBDBDBD),
        borderRadius: BorderRadius.circular(widget.borderRadius),
      ),
      alignment: Alignment.center,
      child: Text(
        _initials(),
        style: GoogleFonts.outfit(color: Colors.white, fontSize: size * 0.32, fontWeight: FontWeight.w600),
      ),
    );
  }
}
