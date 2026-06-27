class CodeQrModel {
  final String id;
  final String reservationId;
  final String token;
  final DateTime createdAt;

  const CodeQrModel({
    required this.id,
    required this.reservationId,
    required this.token,
    required this.createdAt,
  });

  factory CodeQrModel.fromJson(Map<String, dynamic> json) {
    return CodeQrModel(
      id: (json['id'] ?? '').toString(),
      reservationId:
          (json['reservation_id'] ?? json['reservationId'] ?? '').toString(),
      token: (json['token'] ?? '').toString(),
      createdAt: DateTime.parse((json['created_at'] ?? json['createdAt'] ?? DateTime.now().toIso8601String()).toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reservation_id': reservationId,
      'token': token,
      'created_at': createdAt.toIso8601String(),
    };
  }

  CodeQrModel copyWith({
    String? id,
    String? reservationId,
    String? token,
    DateTime? createdAt,
  }) {
    return CodeQrModel(
      id: id ?? this.id,
      reservationId: reservationId ?? this.reservationId,
      token: token ?? this.token,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

