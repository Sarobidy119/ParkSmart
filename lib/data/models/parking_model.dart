import '../../core/utils/json_parsing.dart';

class ParkingModel {
  final String id;
  final String nom;
  final String adresse;
  final double latitude;
  final double longitude;
  final String ville;
  final String description;

  const ParkingModel({
    required this.id,
    required this.nom,
    required this.adresse,
    required this.latitude,
    required this.longitude,
    required this.ville,
    required this.description,
  });

  factory ParkingModel.fromJson(Map<String, dynamic> json) {
    return ParkingModel(
      id: (json['id'] ?? '').toString(),
      nom: (json['nom'] ?? '').toString(),
      adresse: (json['adresse'] ?? '').toString(),
      latitude: jsonDouble(json['latitude']),
      longitude: jsonDouble(json['longitude']),
      ville: (json['ville'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'adresse': adresse,
      'latitude': latitude,
      'longitude': longitude,
      'ville': ville,
      'description': description,
    };
  }

  ParkingModel copyWith({
    String? id,
    String? nom,
    String? adresse,
    double? latitude,
    double? longitude,
    String? ville,
    String? description,
  }) {
    return ParkingModel(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      adresse: adresse ?? this.adresse,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      ville: ville ?? this.ville,
      description: description ?? this.description,
    );
  }
}
