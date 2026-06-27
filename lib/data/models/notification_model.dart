class NotificationModel {
  final String id;
  final String utilisateurId;
  final String titre;
  final String message;
  final bool lu;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.utilisateurId,
    required this.titre,
    required this.message,
    required this.lu,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: (json['id'] ?? '').toString(),
      utilisateurId:
          (json['utilisateur_id'] ?? json['utilisateurId'] ?? '').toString(),
      titre: (json['titre'] ?? '').toString(),
      message: (json['message'] ?? '').toString(),
      lu: (json['lu'] ?? false) == true || json['lu'] == 1,
      createdAt: DateTime.parse((json['created_at'] ?? json['createdAt'] ?? DateTime.now().toIso8601String()).toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'utilisateur_id': utilisateurId,
      'titre': titre,
      'message': message,
      'lu': lu,
      'created_at': createdAt.toIso8601String(),
    };
  }

  NotificationModel copyWith({
    String? id,
    String? utilisateurId,
    String? titre,
    String? message,
    bool? lu,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      utilisateurId: utilisateurId ?? this.utilisateurId,
      titre: titre ?? this.titre,
      message: message ?? this.message,
      lu: lu ?? this.lu,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

