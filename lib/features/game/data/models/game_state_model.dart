import '../../domain/entities/player.dart';

class PlayerModel extends Player {
  const PlayerModel({
    required super.id,
    required super.name,
    required super.role,
    super.isAlive,
    super.votesReceived,
  });

  factory PlayerModel.fromJson(Map<String, dynamic> json) {
    return PlayerModel(
      id: json['id'] as String,
      name: json['name'] as String,
      role: json['role'] as String? ?? 'نامشخص',
      isAlive: json['is_alive'] as bool? ?? true,
      votesReceived: json['votes_received'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'is_alive': isAlive,
      'votes_received': votesReceived,
    };
  }
}
