import 'dart:io';
import 'package:flutter/material.dart';

class ConfirmVerifyScreen extends StatefulWidget {
  final File? frontIdImage;
  final File? backIdImage;
  final File? faceImage;

  const ConfirmVerifyScreen({
    super.key,
    required this.frontIdImage,
    required this.backIdImage,
    required this.faceImage,
  });

  @override
  State<ConfirmVerifyScreen> createState() => _ConfirmVerifyScreenState();
}

class _ConfirmVerifyScreenState extends State<ConfirmVerifyScreen> {

  String _frontText = '';
  bool _loading = false;
  String? _error;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Verify Information',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 16),

          if (widget.frontIdImage != null) ...[
            const Text(
              'Front side of ID card',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                widget.frontIdImage!,
                height: 180,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
          ],

        ],
      ),
    );
  }
}
