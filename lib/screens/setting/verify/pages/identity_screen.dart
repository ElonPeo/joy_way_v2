import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:joy_way/config/general_specifications.dart';

import '../components/id_camera.dart';

class IdentityScreen extends StatefulWidget {
  final File? frontImage;
  final File? backImage;
  final ValueChanged<File> onFrontChanged;
  final ValueChanged<File> onBackChanged;

  const IdentityScreen({
    super.key,
    required this.frontImage,
    required this.backImage,
    required this.onFrontChanged,
    required this.onBackChanged,
  });

  @override
  State<IdentityScreen> createState() => _IdentityScreenState();
}

class _IdentityScreenState extends State<IdentityScreen> {
  File? _frontImage;
  File? _backImage;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _frontImage = widget.frontImage;
    _backImage = widget.backImage;
  }

  Future<void> _captureFront() async {
    final result = await Navigator.push<File?>(
      context,
      MaterialPageRoute(
        builder: (_) => const IdCameraCaptureScreen(title: "Capture front side"),
      ),
    );
    if (result == null) return;
    setState(() => _frontImage = result);
    widget.onFrontChanged(result); // 🔹 đẩy ảnh lên Verify
  }

  Future<void> _captureBack() async {
    final result = await Navigator.push<File?>(
      context,
      MaterialPageRoute(
        builder: (_) => const IdCameraCaptureScreen(title: "Capture back side"),
      ),
    );
    if (result == null) return;
    setState(() => _backImage = result);
    widget.onBackChanged(result); // 🔹 đẩy ảnh lên Verify
  }

  Future<void> _onContinue() async {
    if (_frontImage == null || _backImage == null) return;
    setState(() => _saving = true);

    // TODO: upload / OCR / xử lý hai ảnh căn cước ở đây

    setState(() => _saving = false);
    // ❌ không pop ở đây, Verify đang giữ PageView
    // Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final s = GeneralSpecifications(context);

    return Scaffold(
      backgroundColor: s.backgroundColor,
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        children: [
          Text(
            "Capture your ID card",
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Please take clear photos of both front and back sides of your ID card.",
            style: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 20),

          _IdCaptureCard(
            title: "Front side",
            hint: "Take a photo of the front side",
            onTap: _captureFront,
            imageFile: _frontImage,
          ),
          const SizedBox(height: 20),

          _IdCaptureCard(
            title: "Back side",
            hint: "Take a photo of the back side",
            onTap: _captureBack,
            imageFile: _backImage,
          ),
          const SizedBox(height: 30),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: (_frontImage != null && _backImage != null && !_saving)
                  ? _onContinue
                  : null,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _saving
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : Text(
                "Continue",
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IdCaptureCard extends StatelessWidget {
  final String title;
  final String hint;
  final VoidCallback onTap;
  final File? imageFile;

  const _IdCaptureCard({
    required this.title,
    required this.hint,
    required this.onTap,
    required this.imageFile,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = imageFile != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 190,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: hasImage ? Colors.green : Colors.grey.shade400,
                width: 1.2,
              ),
            ),
            child: hasImage
                ? ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(
                imageFile!,
                fit: BoxFit.cover,
              ),
            )
                : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.photo_camera_outlined,
                  size: 40,
                  color: Colors.grey[700],
                ),
                const SizedBox(height: 10),
                Text(
                  "Tap to capture",
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  hint,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
