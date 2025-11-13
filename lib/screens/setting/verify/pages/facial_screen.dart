import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:joy_way/config/general_specifications.dart';
import 'package:camera/camera.dart';


class FacialScreen extends StatefulWidget {
  final File? faceImage;
  final ValueChanged<File> onFaceChanged;

  const FacialScreen({
    super.key,
    required this.faceImage,
    required this.onFaceChanged,
  });

  @override
  State<FacialScreen> createState() => _FacialScreenState();
}

class _FacialScreenState extends State<FacialScreen> {
  File? _faceImage;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _faceImage = widget.faceImage;
  }

  Future<void> _captureFace() async {
    final file = await Navigator.push<File?>(
      context,
      MaterialPageRoute(
        builder: (_) => const FaceCameraCaptureScreen(
          title: "Capture your face",
        ),
      ),
    );
    if (file == null) return;
    setState(() => _faceImage = file);
    widget.onFaceChanged(file);
  }

  Future<void> _onContinue() async {
    if (_faceImage == null) return;
    setState(() => _saving = true);

    // TODO: upload / so khớp khuôn mặt

    setState(() => _saving = false);
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
            "Capture your face",
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Please look straight at the camera. Make sure your whole face is inside the guide.",
            style: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 20),

          GestureDetector(
            onTap: _captureFace,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final height = width * 4 / 3;
                final hasImage = _faceImage != null;

                return Container(
                  width: width,
                  height: height,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: hasImage ? Colors.green : Colors.grey.shade400,
                      width: 1.2,
                    ),
                  ),
                  child: hasImage
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.file(
                      _faceImage!,
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
                        "Tap to capture your face",
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 30),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: (_faceImage != null && !_saving) ? _onContinue : null,
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
                "Save face image",
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

class FaceCameraCaptureScreen extends StatefulWidget {
  final String title;

  const FaceCameraCaptureScreen({super.key, required this.title});

  @override
  State<FaceCameraCaptureScreen> createState() =>
      _FaceCameraCaptureScreenState();
}

class _FaceCameraCaptureScreenState extends State<FaceCameraCaptureScreen> {
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
      final front = cameras.firstWhere(
            (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _controller = CameraController(
        front,
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

      // đọc bytes
      final bytes = await xFile.readAsBytes();

      // decode ảnh
      img.Image? image = img.decodeImage(bytes);
      if (image == null) {
        if (!mounted) return;
        setState(() => _taking = false);
        return;
      }

      // chuẩn hóa orientation (xoay đúng chiều)
      image = img.bakeOrientation(image);

      final w = image.width;
      final h = image.height;

      // 🔹 chọn vùng crop trung tâm (vuông)
      final size = (w < h ? w : h) * 0.7; // 70% cạnh ngắn
      final cropSize = size.toInt();

      final centerX = w ~/ 2;
      final centerY = h ~/ 2;

      int left = centerX - cropSize ~/ 2;
      int top = centerY - cropSize ~/ 2;

      // clamp tránh vượt biên
      if (left < 0) left = 0;
      if (top < 0) top = 0;
      if (left + cropSize > w) left = w - cropSize;
      if (top + cropSize > h) top = h - cropSize;

      final cropped = img.copyCrop(
        image,
        x: left,
        y: top,
        width: cropSize,
        height: cropSize,
      );

      // encode lại JPG (giảm dung lượng)
      final croppedBytes = img.encodeJpg(cropped, quality: 90);

      // ghi đè lên file cũ (hoặc tạo file mới tuỳ bạn)
      final file = File(xFile.path);
      await file.writeAsBytes(croppedBytes, flush: true);

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
          Positioned.fill(
            child: _FullCameraPreview(controller: controller),
          ),

          const _FaceOverlay(),

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

// preview full khung hình, không zoom
class _FullCameraPreview extends StatelessWidget {
  final CameraController controller;

  const _FullCameraPreview({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final previewSize = controller.value.previewSize;

    if (previewSize == null) {
      return CameraPreview(controller);
    }

    final double previewWidth = previewSize.height;
    final double previewHeight = previewSize.width;

    return Center(
      child: FittedBox(
        fit: BoxFit.contain,
        child: SizedBox(
          width: previewWidth,
          height: previewHeight,
          child: CameraPreview(controller),
        ),
      ),
    );
  }
}

// overlay dạng vòng tròn cho khuôn mặt
class _FaceOverlay extends StatelessWidget {
  const _FaceOverlay();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final diameter = size.width * 0.7;

    return IgnorePointer(
      child: Stack(
        children: [
          // nền mờ
          Container(
            color: Colors.black.withOpacity(0.4),
          ),
          // vòng tròn trong suốt
          Center(
            child: CustomPaint(
              size: Size(size.width, size.height),
              painter: _HoleCirclePainter(diameter: diameter),
            ),
          ),
          // text hướng dẫn
          Positioned(
            bottom: 140,
            left: 0,
            right: 0,
            child: Text(
              'Đặt khuôn mặt vào trong vòng tròn',
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

class _HoleCirclePainter extends CustomPainter {
  final double diameter; // dùng làm chiều ngang elip

  _HoleCirclePainter({required this.diameter});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);

    // 🔹 Elip: rộng = diameter, cao = diameter * 1.3 (tuỳ chỉnh)
    final rect = Rect.fromCenter(
      center: center,
      width: diameter,
      height: diameter * 1.3,
    );

    final ellipsePath = Path()..addOval(rect);
    final fullPath = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final result = Path.combine(
      PathOperation.difference,
      fullPath,
      ellipsePath,
    );

    // nền mờ xung quanh
    canvas.drawPath(result, paint);

    // viền trắng quanh elip
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawOval(rect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _HoleCirclePainter oldDelegate) =>
      oldDelegate.diameter != diameter;
}
