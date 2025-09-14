import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../config/general_specifications.dart';
import '../animated_container/flashing_container.dart';

class CustomSelectPhoto extends StatefulWidget {
  final Widget child;
  final bool dismissible;
  final Duration duration;

  const CustomSelectPhoto({
    super.key,
    required this.child,
    this.dismissible = true,
    this.duration = const Duration(milliseconds: 250),
  });

  @override
  State<CustomSelectPhoto> createState() => _CustomSelectPhotoState();
}

class _CustomSelectPhotoState extends State<CustomSelectPhoto> {
  File? _avatarImage;
  File? _bgImage;
  final ImagePicker _picker = ImagePicker();
  Future<void> _pickAvatar() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _avatarImage = File(picked.path);
      });
    }
  }
  Future<void> _pickBackground() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _bgImage = File(picked.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _open(context),
      child: widget.child,
    );
  }

  void _open(BuildContext context) {
    final specs = GeneralSpecifications(context);

    showGeneralDialog(
      context: context,
      barrierDismissible: widget.dismissible,
      barrierLabel: 'select',
      barrierColor: Colors.transparent,
      transitionDuration: widget.duration,
      pageBuilder: (_, __, ___) {
        return const SizedBox.shrink();
      },
      transitionBuilder: (context, animation, secondary, child) {
        final t = Curves.easeOutCubic.transform(animation.value);
        final sigma = 5.0 * t;      // blur theo tiến độ
        final barrierOpacity = 0.25 * t;

        return Stack(
          children: [
            // Lớp blur + barrier chặn tap bên dưới
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: widget.dismissible ? () => Navigator.of(context).maybePop() : null,
                  child: Container(color: Colors.black.withOpacity(barrierOpacity)),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Transform.translate(
                offset: Offset(0, (1 - t) * 300),
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    width: specs.screenWidth,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                      ),
                    ),
                    child: SafeArea(
                      top: false,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FlashingContainer(
                            onTap: () {

                            },
                            height: 50,
                            width: specs.screenWidth,
                            borderRadius: BorderRadius.circular(0),
                            color: Colors.white,
                            flashingColor: specs.black240,
                            child: Container(
                              width: specs.screenWidth,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: specs.black240,
                                    width: 1,
                                    style: BorderStyle.solid,
                                  ),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  const ImageIcon(
                                    AssetImage(
                                      "assets/icons/other_icons/camera.png",),
                                    size: 20,
                                    color: Colors.black,
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    "Camera",
                                    style: GoogleFonts.outfit(
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                      fontSize: 15,
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          FlashingContainer(
                            onTap: () {

                            },
                            height: 50,
                            width: specs.screenWidth,
                            borderRadius: BorderRadius.circular(0),
                            color: Colors.white,
                            flashingColor: specs.black240,
                            child: Container(
                              width: specs.screenWidth,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  const ImageIcon(
                                    AssetImage(
                                      "assets/icons/other_icons/picture.png",),
                                    size: 20,
                                    color: Colors.black,
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    "From photo library",
                                    style: GoogleFonts.outfit(
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                      fontSize: 15,
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
