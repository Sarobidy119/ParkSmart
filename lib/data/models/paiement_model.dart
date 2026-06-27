import '../../core/utils/json_parsing.dart';

class PaiementModel {
  final String id;
  final String reservationId;
  final String utilisateurId;
  final String methode;
  final double montant;
  final String statut;
  final DateTime createdAt;

  const PaiementModel({
    required this.id,
    required this.reservationId,
    required this.utilisateurId,
    required this.methode,
    required this.montant,
    required this.statut,
    required this.createdAt,
  });

  factory PaiementModel.fromJson(Map<String, dynamic> json) {
    return PaiementModel(
      id: (json['id'] ?? '').toString(),
      reservationId:
          (json['reservation_id'] ?? json['reservationId'] ?? '').toString(),
      utilisateurId:
          (json['utilisateur_id'] ?? json['utilisateurId'] ?? '').toString(),
      methode: (json['methode'] ?? '').toString(),
      montant: jsonDouble(json['montant']),
      statut: (json['statut'] ?? '').toString(),
      createdAt: jsonDateTime(json['created_at'] ?? json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reservation_id': reservationId,
      'utilisateur_id': utilisateurId,
      'methode': methode,
      'montant': montant,
      'statut': statut,
      'created_at': createdAt.toIso8601String(),
    };
  }

  PaiementModel copyWith({
    String? id,
    String? reservationId,
    String? utilisateurId,
    String? methode,
    double? montant,
    String? statut,
    DateTime? createdAt,
  }) {
    return PaiementModel(
      id: id ?? this.id,
      reservationId: reservationId ?? this.reservationId,
      utilisateurId: utilisateurId ?? this.utilisateurId,
      methode: methode ?? this.methode,
      montant: montant ?? this.montant,
      statut: statut ?? this.statut,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
