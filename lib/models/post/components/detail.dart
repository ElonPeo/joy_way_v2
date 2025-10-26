import '../post.dart';

class DetailInfo {
  final ExpenseType type;
  final int? amount;
  final String? description;


  const DetailInfo({
    required this.type,
    this.amount,
    this.description,
  });

  Map<String, dynamic> toMap() => {
    'type': type.name,
    'amount': amount,
    'description': description,

  };

  factory DetailInfo.fromMap(Map<String, dynamic> m) => DetailInfo(
    type: ExpenseType.values.firstWhere((e) => e.name == m['type']),
    amount: m['amount'] as int?,
    description: m['description'] as String?,
  );

  DetailInfo copyWith({
    ExpenseType? type,
    int? amount,
    String? description,
    List<String>? photoUrls,
  }) => DetailInfo(
    type: type ?? this.type,
    amount: amount ?? this.amount,
    description: description ?? this.description,
  );
}


class DetailInfoBuilder {
  ExpenseType? type;
  int? amount;
  String? description;

  DetailInfoBuilder();

  DetailInfoBuilder.from(DetailInfo d) {
    type = d.type;
    amount = d.amount;
    description = d.description;
  }

  /// Hợp lệ khi:
  /// - type != null
  bool get isComplete {
    if (type == null) return false;
    if (type == ExpenseType.share) {
      return (amount != null && amount! > 0);
    }
    return true;
  }

  DetailInfo? tryBuild() => isComplete
      ? DetailInfo(
    type: type!,
    amount: amount,
    description: description,
  ) : null;

  /// Patch tiện dụng
  DetailInfoBuilder patch({
    ExpenseType? type,
    int? amount,
    String? description,
    List<String>? photoUrls,
  }) {
    if (type != null) this.type = type;
    if (amount != null) this.amount = amount;
    if (description != null) this.description = description;
    return this;
  }

  /// Map partial nếu muốn lưu nháp (merge) lên Firestore
  Map<String, dynamic> toPartialMap() => {
    if (type != null) 'type': type!.name,
    if (amount != null) 'amount': amount,
    if (description != null) 'description': description,
  };
}
