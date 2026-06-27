import '../../core/utils/json_parsing.dart';

class TarifModel {
  final String id;
  final String parkingId;
  final double prixHeure;
  final double prixJour;

  const TarifModel({
    required this.id,
    required this.parkingId,
    required this.prixHeure,
    required this.prixJour,
  });

  factory TarifModel.fromJson(Map<String, dynamic> json) {
    return TarifModel(
      id: (json['id'] ?? '').toString(),
      parkingId: (json['parking_id'] ?? json['parkingId'] ?? '').toString(),
      prixHeure: jsonDouble(json['prix_heure'] ?? json['prixHeure']),
      prixJour: jsonDouble(json['prix_jour'] ?? json['prixJour']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'parking_id': parkingId,
      'prix_heure': prixHeure,
      'prix_jour': prixJour,
    };
  }

  TarifModel copyWith({
    String? id,
    String? parkingId,
    double? prixHeure,
    double? prixJour,
  }) {
    return TarifModel(
      id: id ?? this.id,
      parkingId: parkingId ?? this.parkingId,
      prixHeure: prixHeure ?? this.prixHeure,
      prixJour: prixJour ?? this.prixJour,
    );
  }
}
