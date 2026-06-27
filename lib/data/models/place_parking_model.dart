class PlaceParkingModel {
  final String id;
  final String parkingId;
  final String numero;
  final bool occupe;
  final String niveau;

  const PlaceParkingModel({
    required this.id,
    required this.parkingId,
    required this.numero,
    required this.occupe,
    required this.niveau,
  });

  factory PlaceParkingModel.fromJson(Map<String, dynamic> json) {
    return PlaceParkingModel(
      id: (json['id'] ?? '').toString(),
      parkingId: (json['parking_id'] ?? json['parkingId'] ?? '').toString(),
      numero: (json['numero'] ?? '').toString(),
      occupe: (json['occupe'] ?? false) == true || json['occupe'] == 1,
      niveau: (json['niveau'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'parking_id': parkingId,
      'numero': numero,
      'occupe': occupe,
      'niveau': niveau,
    };
  }

  PlaceParkingModel copyWith({
    String? id,
    String? parkingId,
    String? numero,
    bool? occupe,
    String? niveau,
  }) {
    return PlaceParkingModel(
      id: id ?? this.id,
      parkingId: parkingId ?? this.parkingId,
      numero: numero ?? this.numero,
      occupe: occupe ?? this.occupe,
      niveau: niveau ?? this.niveau,
    );
  }
}

