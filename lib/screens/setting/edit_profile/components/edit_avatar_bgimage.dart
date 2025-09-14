import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';

class EditAvatarBgimage extends StatefulWidget {
  const EditAvatarBgimage({super.key});

  @override
  State<EditAvatarBgimage> createState() => _EditAvatarBgimageState();
}

class _EditAvatarBgimageState extends State<EditAvatarBgimage> {
  File? _avatarImage; // ảnh tạm thời
  File? _bgImage;     // ảnh nền tạm thời
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickAvatar() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _avatarImage = File(picked.path));
  }

  Future<void> _pickBackground() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _bgImage = File(picked.path));
  }

  ImageProvider _bgProvider() {
    if (_bgImage != null) return FileImage(_bgImage!);
    return const AssetImage('assets/background/backgroundEX.jpg');
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return ClipRRect(
      borderRadius: BorderRadius.circular(40),
      child: Container(
        height: 250,
        width: w,
        color: Colors.white,
        child: Stack(
          children: [
            /// NỀN có zoom/drag bằng PhotoView



            /// AVATAR (góc trái dưới)
            Positioned(
              left: 16,
              bottom: 16,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 38,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: _avatarImage != null
                        ? FileImage(_avatarImage!)
                        : const AssetImage('assets/avatar/default_avatar.png')
                    as ImageProvider,
                  ),
                  Positioned(
                    bottom: -2,
                    right: -2,
                    child: GestureDetector(
                      onTap: _pickAvatar,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.75),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.edit, size: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}




