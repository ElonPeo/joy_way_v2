// bottom_verify_bar.dart
import 'dart:io';

import 'package:flutter/material.dart';
import '../../../../config/general_specifications.dart';
import '../../../../services/firebase_services/user_verification_firestore.dart';
import '../../../../widgets/custom_input/confirm_button.dart';

class BottomVerifyBar extends StatefulWidget {
  final File? frontIdImage;
  final File? backIdImage;
  final File? faceImage;

  final int page;
  final Function(int) onPage;
  final int totalSteps;

  const BottomVerifyBar({
    super.key,
    required this.page,
    required this.onPage,
    this.totalSteps = 3,
    required this.frontIdImage,
    required this.backIdImage,
    required this.faceImage,
  });

  @override
  State<BottomVerifyBar> createState() => _BottomVerifyBarState();
}

class _BottomVerifyBarState extends State<BottomVerifyBar> {
  bool _submitting = false;

  bool get _isFirst => widget.page <= 0;
  bool get _isLast => widget.page >= widget.totalSteps - 1;

  void _goPrev() {
    if (_isFirst) return;
    widget.onPage((widget.page - 1).clamp(0, widget.totalSteps - 1));
  }

  void _goNext() {
    if (_isLast) return;
    widget.onPage((widget.page + 1).clamp(0, widget.totalSteps - 1));
  }

  Future<void> _onSubmit() async {
    if (_submitting) return;

    // Check đủ ảnh
    if (widget.frontIdImage == null ||
        widget.backIdImage == null ||
        widget.faceImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Vui lòng chụp đủ 3 ảnh: mặt trước CCCD, mặt sau CCCD và ảnh khuôn mặt.',
          ),
        ),
      );
      return;
    }

    setState(() => _submitting = true);
    FocusScope.of(context).unfocus();

    try {
      await UserVerificationFirestore().submitVerification(
        frontIdImage: widget.frontIdImage,
        backIdImage: widget.backIdImage,
        faceImage: widget.faceImage,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Gửi thông tin xác minh thành công. Vui lòng chờ hệ thống/nhân viên duyệt.',
          ),
        ),
      );

      // tuỳ flow: next hoặc pop
      if (_isLast) {
        Navigator.of(context).maybePop();
      } else {
        _goNext();
      }
    } catch (e) {
      if (!mounted) return;
      print("uiy quưefi $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Có lỗi khi gửi xác minh: $e'),
        ),

      );
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  Widget _buildChild(GeneralSpecifications specs) {
    // Bước 0: chỉ nút tiếp tục
    if (widget.page == 0) {
      return ConfirmButton(
        onConfirm: () {
          FocusScope.of(context).unfocus();
          _goNext();
        },
      );
    }

    // Bước 1: quay lại / tiếp tục
    if (widget.page == 1) {
      return ConfirmButton(
        isConfirmOnly: false,
        onConfirm: () {
          FocusScope.of(context).unfocus();
          _goNext();
        },
        onRefuse: () {
          _goPrev();
        },
      );
    }

    // Bước cuối: quay lại / gửi
    if (widget.page == 2 || _isLast) {
      return ConfirmButton(
        isConfirmOnly: false,
        onConfirm: () {
          if (_submitting) return;
          _onSubmit();
        },
        onRefuse: () {
          if (_submitting) return;
          _goPrev();
        },
      );
    }

    // fallback (nếu sau này thêm step)
    return ConfirmButton(
      isConfirmOnly: false,
      onConfirm: () {
        if (_submitting) return;
        _onSubmit();
      },
      onRefuse: () {
        if (_submitting) return;
        _goPrev();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final specs = GeneralSpecifications(context);
    final childWidget = _buildChild(specs);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 100),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, anim) =>
          FadeTransition(opacity: anim, child: child),
      child: KeyedSubtree(
        key: ValueKey<int>(widget.page),
        child: childWidget,
      ),
    );
  }
}
