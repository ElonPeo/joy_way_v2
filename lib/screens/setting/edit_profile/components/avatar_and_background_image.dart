import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:joy_way/config/general_specifications.dart';
import 'package:joy_way/services/data_processing/image_processing.dart';
import 'package:joy_way/widgets/animated_container/loading_container.dart';
import 'package:joy_way/widgets/notifications/show_notification.dart';
import 'package:joy_way/widgets/photo_view/custom_photo_view.dart';

import '../../../../services/firebase_services/profile_services/profile_fire_storage_image.dart';

class AvatarAndBackgroundImage extends StatefulWidget {
  final Function(File?) onAvatarImage;
  final Function(File?) onBgImage;

  const AvatarAndBackgroundImage({
    super.key,
    required this.onAvatarImage,
    required this.onBgImage,
  });

  @override
  State<AvatarAndBackgroundImage> createState() =>
      _AvatarAndBackgroundImageState();
}

class _AvatarAndBackgroundImageState extends State<AvatarAndBackgroundImage> {
  File? _avatarImage;
  File? _bgImage;
  String? _avatarUrl;
  String? _bgUrl;
  String? _error;
  bool _isLoaded = false;
  final ImagePicker _picker = ImagePicker();


  bool _isProcessingAvatar = false;
  bool _isProcessingBg = false;

  @override
  void initState() {
    _loadCurrentUserImages();
    super.initState();
  }

  Future<void> _loadCurrentUserImages() async {
    final imgs =
        await ProfileFireStorageImage().getCurrentUserAvatarAndBackgroundUrls();
    if (!mounted) return;
    if (imgs.error != null) {
      setState(() => _error = imgs.error);
    } else {
      setState(() {
        _avatarUrl = imgs.avatarUrl;
        _bgUrl = imgs.bgUrl;
      });
    }
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _isLoaded = true;
      });
    });
  }

  Future<void> _pickAvatar() async {
    if (_isProcessingAvatar) return;
    setState(() => _isProcessingAvatar = true);
    try {
      final picked = await _picker.pickImage(source: ImageSource.gallery);
      if (picked == null) return;

      final original = File(picked.path);
      final normalized = await ImageProcessing().normalizeToJpeg(
        original,
        targetW: 1280,
        targetH: 720,
        quality: 70,
      );

      if (normalized == null) {
        if (!mounted) return;
        ShowNotification.showAnimatedSnackBar(
            context,
            'Unable to normalize image (invalid file).',
            0,
            const Duration(milliseconds: 500));
        return;
      }
      if (!mounted) return;
      setState(() => _avatarImage = normalized);
      widget.onAvatarImage(normalized);
    } catch (e) {
      if (!mounted) return;
      ShowNotification.showAnimatedSnackBar(
          context, e.toString(), 0, const Duration(milliseconds: 500));
    } finally {
      if (mounted) setState(() => _isProcessingAvatar = false); // << thêm
    }
  }

  Future<void> _pickBackground() async {
    if (_isProcessingBg) return;
    setState(() => _isProcessingBg = true); // << thêm
    try {
      final picked = await _picker.pickImage(source: ImageSource.gallery);
      if (picked == null) return;

      final original = File(picked.path);
      final normalized = await ImageProcessing().normalizeToJpeg(
        original,
        targetW: 1920,
        targetH: 1080,
        quality: 75,
      );

      if (normalized == null) {
        if (!mounted) return;
        ShowNotification.showAnimatedSnackBar(
            context,
            'Unable to normalize background image (invalid file).',
            0,
            const Duration(milliseconds: 500));
        return;
      }
      if (!mounted) return;
      setState(() => _bgImage = normalized);
      widget.onBgImage(normalized);
    } catch (e) {
      if (!mounted) return;
      ShowNotification.showAnimatedSnackBar(
          context, e.toString(), 0, const Duration(milliseconds: 500));
    } finally {
      if (mounted) setState(() => _isProcessingBg = false); // << thêm
    }
  }

  ImageProvider? _bgProvider() {
    if (_bgImage != null) return FileImage(_bgImage!);
    if (_bgUrl != null && _bgUrl!.isNotEmpty) return NetworkImage(_bgUrl!);
    return null;
  }

  ImageProvider? _avatarProvider() {
    if (_avatarImage != null) return FileImage(_avatarImage!);
    if (_avatarUrl != null && _avatarUrl!.isNotEmpty)
      return NetworkImage(_avatarUrl!);
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final specs = GeneralSpecifications(context);
    return SizedBox(
      height: 250,
      width: specs.screenWidth,
      child: Stack(
        children: [
          // Ảnh nền có thể bấm để mở full screen (trong CustomPhotoView)
          _isLoaded
              ? CustomPhotoView(
                  height: 250,
                  width: specs.screenWidth,
                  imageProvider: _bgProvider(),
                  backgroundColor: Colors.white,
                  child: Container(
                    color: Colors.black12,
                  ),
                )
              : LoadingContainer(
                  height: 250,
                  width: specs.screenWidth,
                  borderRadius: BorderRadius.circular(40),
                ),

          // Nút Edit nền (góc phải trên)
          Positioned(
            top: 20,
            right: 20,
            child: GestureDetector(
              onTap: _pickBackground,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(0, 0, 0, 0.75),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "Edit",
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),

          // Avatar + nút đổi avatar (góc trái dưới)
          Positioned(
            bottom: 40,
            left: 40,
            child: Stack(
              children: [
                _isLoaded
                    ? Container(
                  height: 106,
                  width: 106,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle
                      ),

                      child: Center(
                        child: CustomPhotoView(
                            height: 100,
                            width: 100,
                            imageProvider: _avatarProvider(),
                            backgroundColor: specs.black150,
                            borderRadius: BorderRadius.circular(100),
                            child: const ImageIcon(
                              AssetImage("assets/icons/other_icons/user.png"),
                              size: 30,
                            )
                          ),
                      ),
                    )
                    : LoadingContainer(
                        height: 100,
                        width: 100,
                        borderRadius: BorderRadius.circular(100),
                      ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _pickAvatar,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Color.fromRGBO(0, 0, 0, 0.75),
                        shape: BoxShape.circle,
                      ),
                      child:
                          const Icon(Icons.edit, size: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
