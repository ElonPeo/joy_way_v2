// id_camera_capture_screen.dart

import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class IdCameraCaptureScreen extends StatefulWidget {
  final String title;

  const IdCameraCaptureScreen({super.key, required this.title});

  @override
  State<IdCameraCaptureScreen> createState() => _IdCameraCaptureScreenState();
}

class _IdCameraCaptureScreenState extends State<IdCameraCaptureScreen> {
  CameraController? _controller;
  bool _initializing = true;
  bool _taking = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      final back = cameras.firstWhere(
            (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      _controller = CameraController(
        back,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _controller!.initialize();

      if (!mounted) return;
      setState(() => _initializing = false);
    } catch (e) {
      debugPrint('Camera error: $e');
      if (!mounted) return;
      setState(() => _initializing = false);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (_taking) return;

    setState(() => _taking = true);
    try {
      final xFile = await _controller!.takePicture();
      final file = File(xFile.path);
      if (!mounted) return;
      Navigator.pop(context, file);
    } catch (e) {
      debugPrint('Take picture error: $e');
      if (!mounted) return;
      setState(() => _taking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          widget.title,
          style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
        ),
      ),
      body: _initializing || controller == null
          ? const Center(
        child: CircularProgressIndicator(color: Colors.white),
      )
          : Stack(
        children: [
          // 🔹 Hiển thị toàn bộ khung hình camera, không zoom/crop
          Positioned.fill(
            child: _FullCameraPreview(controller: controller),
          ),

          // 🔹 Khung hướng dẫn
          const _IdCardOverlay(),

          // 🔹 Nút chụp
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 32.0),
              child: GestureDetector(
                onTap: _taking ? null : _takePicture,
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 4,
                    ),
                  ),
                  child: Center(
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _taking
                            ? Colors.white.withOpacity(0.4)
                            : Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IdCardOverlay extends StatelessWidget {
  const _IdCardOverlay();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          // lớp mờ phủ toàn màn
          Container(
            color: Colors.black.withOpacity(0.4),
          ),
          // khung trong suốt ở giữa
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.width * 0.5, // tỉ lệ giống CCCD
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
                color: Colors.black.withOpacity(0.2),
              ),
            ),
          ),
          // text hướng dẫn
          Positioned(
            bottom: 140,
            left: 0,
            right: 0,
            child: Text(
              'Đặt căn cước vào khung',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
class _FullCameraPreview extends StatelessWidget {
  final CameraController controller;

  const _FullCameraPreview({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final previewSize = controller.value.previewSize;

    if (previewSize == null) {
      return CameraPreview(controller);
    }

    // Camera luôn trả size theo landscape, nên đảo width/height khi đang portrait
    final double previewWidth = previewSize.height;
    final double previewHeight = previewSize.width;

    return Center(
      child: FittedBox(
        fit: BoxFit.contain, // 🔹 Hiển thị toàn bộ frame, không crop/zoom
        child: SizedBox(
          width: previewWidth,
          height: previewHeight,
          child: CameraPreview(controller),
        ),
      ),
    );
  }
}
