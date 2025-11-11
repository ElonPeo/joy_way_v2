class LocationNameHandling {
  /// Tách chuỗi địa chỉ thành các phần (tách theo dấu phẩy), loại:
  /// - 'Việt Nam' / 'Vietnam' / 'VN' ở cuối hoặc bất kỳ vị trí nào
  /// - Mã ZIP độc lập 4–6 chữ số (vd: 12100) hoặc cụm có tiền tố: zip/zipcode/postal code/postcode/
  ///   "mã bưu chính"/"mã zip"/"cd:" + số. Không phân biệt hoa/thường.
  static List<String> splitPlaceParts(String s) {
    final parts = s.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

    final List<String> out = [];
    for (var p in parts) {
      final lower = p.toLowerCase();
      // 1) lọc country
      if (lower == 'việt nam' || lower == 'vietnam' || lower == 'vn') {
        continue;
      }
      // 2) lọc mã ZIP
      final onlyDigits = RegExp(r'^\s*\d{4,6}\s*$'); // 4-6 chữ số độc lập
      if (onlyDigits.hasMatch(p)) continue;
      // các biến thể có tiền tố
      final zipPhrase = RegExp(
        r'^(?:zip|zipcode|postal\s*code|postcode|mã\s*(?:bưu\s*chính|zip|postcode)|cd:)\s*\d{4,6}$',
        caseSensitive: false,
      );
      // bỏ dấu chấm đơn giản để khớp "cd: 12100." nếu có
      final normalized = lower.replaceAll('.', '');
      if (zipPhrase.hasMatch(normalized.trim())) continue;
      out.add(p);
    }

    // bỏ phần trùng lặp liên tiếp (nếu có), giữ nguyên thứ tự
    final dedup = <String>[];
    for (final p in out) {
      if (dedup.isEmpty || dedup.last.toLowerCase() != p.toLowerCase()) {
        dedup.add(p);
      }
    }
    return dedup;
  }

  /// Giữ lại chuỗi đã làm sạch (không country/ZIP).
  static String removeTailCountryAndZip(String s) {
    return splitPlaceParts(s).join(', ');
  }

  /// So sánh hai địa điểm sau khi đã lọc, trả về phần “khác nhau nhất” (gần đầu chuỗi)
  /// để hiển thị ngắn gọn (vd: tên bệnh viện ↔ tên công viên),
  /// hoặc nhảy lùi 1–2 cấp nếu phần cuối trùng nhau.
  static Map<String, String> comparePlaces(String dep, String arr) {
    final depParts = splitPlaceParts(dep);
    final arrParts = splitPlaceParts(arr);

    final depRev = depParts.reversed.toList();
    final arrRev = arrParts.reversed.toList();

    int same = 0;
    final minLen = depRev.length < arrRev.length ? depRev.length : arrRev.length;
    for (var i = 0; i < minLen; i++) {
      if (depRev[i].toLowerCase() == arrRev[i].toLowerCase()) {
        same++;
      } else {
        break;
      }
    }

    // Không trùng phần cuối -> lấy “phần gần cuối” nhất (thường là quận/huyện hoặc địa danh chính)
    if (same == 0) {
      return {
        'dep': depRev.isNotEmpty ? depRev.first : depParts.join(', '),
        'arr': arrRev.isNotEmpty ? arrRev.first : arrParts.join(', '),
      };
    }
    // Trùng 1 cấp (thường là tỉnh/thành) -> lùi 1 cấp
    if (same == 1 && depRev.length > 1 && arrRev.length > 1) {
      return {'dep': depRev[1], 'arr': arrRev[1]};
    }
    // Trùng 2 cấp -> lùi 2 cấp
    if (same == 2 && depRev.length > 2 && arrRev.length > 2) {
      return {'dep': depRev[2], 'arr': arrRev[2]};
    }

    // Mặc định: hiển thị ngắn gọn 2 phần cuối (sau khi lọc)
    String shortLast2(List<String> xs) =>
        (xs.length <= 2) ? xs.join(', ') : xs.sublist(xs.length - 2).join(', ');

    return {'dep': shortLast2(depParts), 'arr': shortLast2(arrParts)};
  }
}
