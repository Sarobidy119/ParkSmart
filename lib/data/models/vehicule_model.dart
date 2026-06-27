class VehiculeModel {
  final String id;
  final String utilisateurId;
  final String plaque;
  final String type;
  final String marque;
  final String modele;

  const VehiculeModel({
    required this.id,
    required this.utilisateurId,
    required this.plaque,
    required this.type,
    required this.marque,
    required this.modele,
  });

  factory VehiculeModel.fromJson(Map<String, dynamic> json) {
    return VehiculeModel(
      id: (json['id'] ?? '').toString(),
      utilisateurId:
          (json['utilisateur_id'] ?? json['utilisateurId'] ?? '').toString(),
      plaque: (json['plaque'] ?? '').toString(),
      type: (json['type'] ?? '').toString(),
      marque: (json['marque'] ?? '').toString(),
      modele: (json['modele'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'utilisateur_id': utilisateurId,
      'plaque': plaque,
      'type': type,
      'marque': marque,
      'modele': modele,
    };
  }

  VehiculeModel copyWith({
    String? id,
    String? utilisateurId,
    String? plaque,
    String? type,
    String? marque,
    String? modele,
  }) {
    return VehiculeModel(
      id: id ?? this.id,
      utilisateurId: utilisateurId ?? this.utilisateurId,
      plaque: plaque ?? this.plaque,
      type: type ?? this.type,
      marque: marque ?? this.marque,
      modele: modele ?? this.modele,
    );
  }
}

