class StarRating {
  final int oneStar;
  final int twoStars;
  final int threeStars;
  final int fourStars;
  final int fiveStars;

  const StarRating({
    this.oneStar = 0,
    this.twoStars = 0,
    this.threeStars = 0,
    this.fourStars = 0,
    this.fiveStars = 0,
  });

  /// Tổng số lượt đánh giá
  int get totalCount => oneStar + twoStars + threeStars + fourStars + fiveStars;

  /// Tổng điểm
  int get totalPoints => oneStar * 1 + twoStars * 2 + threeStars * 3 + fourStars * 4 + fiveStars * 5;

  /// Điểm trung bình
  double get average => totalCount == 0 ? 0 : totalPoints / totalCount;

  /// Trả về phần trăm theo từng sao (ví dụ dùng để hiển thị biểu đồ thanh)
  Map<int, double> get percentage {
    if (totalCount == 0) return {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    return {
      1: oneStar / totalCount,
      2: twoStars / totalCount,
      3: threeStars / totalCount,
      4: fourStars / totalCount,
      5: fiveStars / totalCount,
    };
  }

  /// Chuyển sang map (dùng khi lưu Firestore)
  Map<String, dynamic> toMap() => {
    '1': oneStar,
    '2': twoStars,
    '3': threeStars,
    '4': fourStars,
    '5': fiveStars,
  };

  /// Tạo từ dữ liệu Firestore
  factory StarRating.fromMap(Map<String, dynamic>? data) {
    if (data == null) return const StarRating();
    return StarRating(
      oneStar: data['1'] ?? 0,
      twoStars: data['2'] ?? 0,
      threeStars: data['3'] ?? 0,
      fourStars: data['4'] ?? 0,
      fiveStars: data['5'] ?? 0,
    );
  }
}
