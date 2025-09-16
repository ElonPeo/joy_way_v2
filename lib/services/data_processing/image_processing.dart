
import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

class ImageProcessing {
  /// Chuẩn hoá: ép mọi định dạng (PNG/HEIC/WebP/…) → JPG 720p, quality 70.
  /// - Tự tô nền cho ảnh có alpha.
  /// - Trả về File JPG sẵn sàng upload.
  Future<File?> normalizeToJpeg(
      File input, {
        int targetW = 1280,
        int targetH = 720,
        int quality = 70,
      }) async {
    if (!await input.exists()) {
      throw Exception('Input file does not exist.');
    }
    final String outPath =
    input.path.replaceAll(RegExp(r'\.\w+$'), '_norm.jpg');
    final img.Color bgColor = img.ColorRgba8(255, 255, 255, 255);
    bool hasAlphaChannel(img.Image i) {
      return i.numChannels == 4; // 4 kênh = RGBA, 3 kênh = RGB
    }

    // 1) Thử convert trực tiếp bằng flutter_image_compress (nhanh, hỗ trợ HEIC)
    Uint8List? bytes = await FlutterImageCompress.compressWithFile(
      input.path,
      minWidth: targetW,
      minHeight: targetH,
      quality: quality,
      format: CompressFormat.jpeg,
      // ép về JPG
      keepExif: false, // bỏ EXIF giảm size (đổi true nếu cần giữ)
    );

    // 2) nếu flutter_image_compress null, dùng package:image để tự xử lý alpha
    if (bytes == null) {
      final raw = await input.readAsBytes();
      final decoded = img.decodeImage(raw);
      if (decoded == null) {
        throw Exception('Photo is not appropriate.');
      }

      // Resize downscale (giữ tỷ lệ)
      final resized = img.copyResize(
        decoded,
        width: decoded.width > decoded.height ? targetW : null,
        height: decoded.height >= decoded.width ? targetH : null,
        interpolation: img.Interpolation.linear,
      );

      // Nếu có alpha → vẽ lên nền đặc
      img.Image flattened;
      if (hasAlphaChannel(resized)) {
        flattened = img.Image(width: resized.width, height: resized.height);
        img.fill(flattened, color: bgColor);
        img.compositeImage(flattened, resized);
      } else {
        flattened = resized;
      }

      bytes = Uint8List.fromList(img.encodeJpg(flattened, quality: quality));
    }

    final outFile = File(outPath);
    await outFile.writeAsBytes(bytes, flush: true);
    return outFile;
  }
}