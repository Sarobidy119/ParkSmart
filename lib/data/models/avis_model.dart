import '../../core/utils/json_parsing.dart';

class AvisModel {
  final String id;
  final String parkingId;
  final String utilisateurId;
  final int note;
  final String commentaire;
  final DateTime createdAt;

  const AvisModel({
    required this.id,
    required this.parkingId,
    required this.utilisateurId,
    required this.note,
    required this.commentaire,
    required this.createdAt,
  });

  factory AvisModel.fromJson(Map<String, dynamic> json) {
    return AvisModel(
      id: (json['id'] ?? '').toString(),
      parkingId: (json['parking_id'] ?? json['parkingId'] ?? '').toString(),
      utilisateurId:
          (json['utilisateur_id'] ?? json['utilisateurId'] ?? '').toString(),
      note: jsonInt(json['note']),
      commentaire: (json['commentaire'] ?? '').toString(),
      createdAt: jsonDateTime(json['created_at'] ?? json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'parking_id': parkingId,
      'utilisateur_id': utilisateurId,
      'note': note,
      'commentaire': commentaire,
      'created_at': createdAt.toIso8601String(),
    };
  }

  AvisModel copyWith({
    String? id,
    String? parkingId,
    String? utilisateurId,
    int? note,
    String? commentaire,
    DateTime? createdAt,
  }) {
    return AvisModel(
      id: id ?? this.id,
      parkingId: parkingId ?? this.parkingId,
      utilisateurId: utilisateurId ?? this.utilisateurId,
      note: note ?? this.note,
      commentaire: commentaire ?? this.commentaire,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
