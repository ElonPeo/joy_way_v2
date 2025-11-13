import 'package:cloud_firestore/cloud_firestore.dart';

class UserVerification {
  final String userId;

  final String? idFrontImagePath;
  final String? idBackImagePath;
  final String? faceImagePath;

  final String? ocrRawText;
  final String? ocrTextNoAccent;

  final double? faceSimilarity;
  final double? faceSimilarityThreshold;
  final bool? faceMatched;

  final String idStatus;
  final String faceStatus;
  final String overallStatus;

  final bool isVerified;
  final bool hasIdCard;
  final bool hasFacePhoto;

  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? verifiedAt;

  const UserVerification({
    required this.userId,
    this.idFrontImagePath,
    this.idBackImagePath,
    this.faceImagePath,
    this.ocrRawText,
    this.ocrTextNoAccent,
    this.faceSimilarity,
    this.faceSimilarityThreshold,
    this.faceMatched,
    this.idStatus = 'none',
    this.faceStatus = 'none',
    this.overallStatus = 'pending',
    this.isVerified = false,
    this.hasIdCard = false,
    this.hasFacePhoto = false,
    this.createdAt,
    this.updatedAt,
    this.verifiedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'idFrontImagePath': idFrontImagePath,
      'idBackImagePath': idBackImagePath,
      'faceImagePath': faceImagePath,
      'ocrRawText': ocrRawText,
      'ocrTextNoAccent': ocrTextNoAccent,
      'faceSimilarity': faceSimilarity,
      'faceSimilarityThreshold': faceSimilarityThreshold,
      'faceMatched': faceMatched,
      'idStatus': idStatus,
      'faceStatus': faceStatus,
      'overallStatus': overallStatus,
      'isVerified': isVerified,
      'hasIdCard': hasIdCard,
      'hasFacePhoto': hasFacePhoto,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'verifiedAt': verifiedAt != null ? Timestamp.fromDate(verifiedAt!) : null,
    };
  }

  factory UserVerification.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    Timestamp? t1 = data['createdAt'];
    Timestamp? t2 = data['updatedAt'];
    Timestamp? t3 = data['verifiedAt'];

    return UserVerification(
      userId: data['userId'] ?? doc.id,
      idFrontImagePath: data['idFrontImagePath'],
      idBackImagePath: data['idBackImagePath'],
      faceImagePath: data['faceImagePath'],
      ocrRawText: data['ocrRawText'],
      ocrTextNoAccent: data['ocrTextNoAccent'],
      faceSimilarity: (data['faceSimilarity'] as num?)?.toDouble(),
      faceSimilarityThreshold: (data['faceSimilarityThreshold'] as num?)?.toDouble(),
      faceMatched: data['faceMatched'],
      idStatus: data['idStatus'] ?? 'none',
      faceStatus: data['faceStatus'] ?? 'none',
      overallStatus: data['overallStatus'] ?? 'pending',
      isVerified: data['isVerified'] ?? false,
      hasIdCard: data['hasIdCard'] ?? false,
      hasFacePhoto: data['hasFacePhoto'] ?? false,
      createdAt: t1?.toDate(),
      updatedAt: t2?.toDate(),
      verifiedAt: t3?.toDate(),
    );
  }
}
