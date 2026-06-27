import '../../core/utils/json_parsing.dart';

class ReservationModel {
  final String id;
  final String utilisateurId;
  final String parkingId;
  final String placeId;
  final String vehiculeId;
  final DateTime debut;
  final DateTime fin;
  final String statut; // ex: en_cours, a_venir, terminee, annulee
  final double montant;

  const ReservationModel({
    required this.id,
    required this.utilisateurId,
    required this.parkingId,
    required this.placeId,
    required this.vehiculeId,
    required this.debut,
    required this.fin,
    required this.statut,
    required this.montant,
  });

  factory ReservationModel.fromJson(Map<String, dynamic> json) {
    return ReservationModel(
      id: (json['id'] ?? '').toString(),
      utilisateurId:
          (json['utilisateur_id'] ?? json['utilisateurId'] ?? '').toString(),
      parkingId: (json['parking_id'] ?? json['parkingId'] ?? '').toString(),
      placeId: (json['place_id'] ?? json['placeId'] ?? '').toString(),
      vehiculeId: (json['vehicule_id'] ?? json['vehiculeId'] ?? '').toString(),
      debut: jsonDateTime(json['debut'] ?? json['start']),
      fin: jsonDateTime(json['fin'] ?? json['end']),
      statut: (json['statut'] ?? '').toString(),
      montant: jsonDouble(json['montant']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'utilisateur_id': utilisateurId,
      'parking_id': parkingId,
      'place_id': placeId,
      'vehicule_id': vehiculeId,
      'debut': debut.toIso8601String(),
      'fin': fin.toIso8601String(),
      'statut': statut,
      'montant': montant,
    };
  }

  ReservationModel copyWith({
    String? id,
    String? utilisateurId,
    String? parkingId,
    String? placeId,
    String? vehiculeId,
    DateTime? debut,
    DateTime? fin,
    String? statut,
    double? montant,
  }) {
    return ReservationModel(
      id: id ?? this.id,
      utilisateurId: utilisateurId ?? this.utilisateurId,
      parkingId: parkingId ?? this.parkingId,
      placeId: placeId ?? this.placeId,
      vehiculeId: vehiculeId ?? this.vehiculeId,
      debut: debut ?? this.debut,
      fin: fin ?? this.fin,
      statut: statut ?? this.statut,
      montant: montant ?? this.montant,
    );
  }
}
