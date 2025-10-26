class LocationNameHandling {
  static String shortenPlace(String fullName) {
    // Ví dụ: "Phường Dịch Vọng Hậu, Quận Cầu Giấy, Hà Nội"
    final parts = fullName.split(',').map((e) => e.trim()).toList();
    return parts.isNotEmpty ? parts.last : fullName;
  }

  /// So sánh hai địa danh, tự động rút gọn theo yêu cầu
  static Map<String, String> comparePlaces(String dep, String arr) {
    final depParts = dep.split(',').map((e) => e.trim()).toList();
    final arrParts = arr.split(',').map((e) => e.trim()).toList();

    // Đảo chiều để so sánh từ tỉnh -> huyện -> xã
    final depRev = depParts.reversed.toList();
    final arrRev = arrParts.reversed.toList();

    int sameLevel = 0;
    final minLen = depRev.length < arrRev.length ? depRev.length : arrRev.length;
    for (int i = 0; i < minLen; i++) {
      if (depRev[i].toLowerCase() == arrRev[i].toLowerCase()) {
        sameLevel++;
      } else {
        break;
      }
    }

    // Nếu khác tỉnh (sameLevel == 0) → hiển thị mỗi tỉnh
    if (sameLevel == 0) {
      return {
        'dep': depRev.isNotEmpty ? depRev.first : dep,
        'arr': arrRev.isNotEmpty ? arrRev.first : arr,
      };
    }

    // Nếu cùng tỉnh nhưng khác huyện → hiển thị huyện
    if (sameLevel == 1 && depRev.length > 1 && arrRev.length > 1) {
      return {
        'dep': depRev[1],
        'arr': arrRev[1],
      };
    }

    // Nếu giống tỉnh + huyện nhưng khác xã → hiển thị xã
    if (sameLevel == 2 && depRev.length > 2 && arrRev.length > 2) {
      return {
        'dep': depRev[2],
        'arr': arrRev[2],
      };
    }

    // Nếu giống hoàn toàn → hiển thị 2 tên cuối để người dùng vẫn thấy
    final depShort = depRev.take(2).toList().reversed.join(', ');
    final arrShort = arrRev.take(2).toList().reversed.join(', ');
    return {'dep': depShort, 'arr': arrShort};
  }

}