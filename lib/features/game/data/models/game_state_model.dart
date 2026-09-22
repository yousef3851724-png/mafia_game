import '../../domain/entities/player.dart';

class PlayerModel {
  final String id;
  final String name;
  final bool isHost;
  final String? vote;

  const PlayerModel({
    required this.id,
    required this.name,
    this.isHost = false,
    this.vote,
  });

  factory PlayerModel.fromEntity(Player player) {
    return PlayerModel(
      id: player.id,
      name: player.name,
      isHost: player.isHost,
      vote: player.vote,
    );
  }

  Player toEntity() {
    return Player(
      id: id,
      name: name,
      isHost: isHost,
      vote: vote,
    );
  }

  factory PlayerModel.fromJson(Map<String, dynamic> json) {
    return PlayerModel(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      isHost: json['is_host'] as bool? ?? false,
      vote: json['vote'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'is_host': isHost,
        'vote': vote,
      };
}

class GameStateModel {
  final List<PlayerModel> players;
  final Map<String, int> votes;
  final List<String> options;

  const GameStateModel({
    required this.players,
    required this.votes,
    required this.options,
  });

  factory GameStateModel.initial() => const GameStateModel(
        players: [],
        votes: {},
        options: ['A', 'B', 'C', 'D'],
      );

  GameStateModel copyWith({
    List<PlayerModel>? players,
    Map<String, int>? votes,
    List<String>? options,
  }) {
    return GameStateModel(
      players: players ?? this.players,
      votes: votes ?? this.votes,
      options: options ?? this.options,
    );
  }

  factory GameStateModel.fromJson(Map<String, dynamic> json) {
    final rawPlayers = json['players'] as List<dynamic>? ?? const [];
    final rawVotes = json['votes'] as Map<String, dynamic>? ?? const {};
    final rawOptions = json['options'] as List<dynamic>? ?? const ['A', 'B', 'C', 'D'];

    return GameStateModel(
      players: rawPlayers
          .whereType<Map<String, dynamic>>()
          .map(PlayerModel.fromJson)
          .toList(growable: false),
      votes: rawVotes.map((key, value) => MapEntry(key, (value as num).toInt())),
      options: rawOptions.cast<String>(),
    );
  }

  Map<String, dynamic> toJson() => {
        'players': players.map((player) => player.toJson()).toList(),
        'votes': votes,
        'options': options,
      };
}
