import 'package:equatable/equatable.dart';

class Player extends Equatable {
  final String id;
  final String name;
  final bool isHost;
  final String? vote;

  const Player({
    required this.id,
    required this.name,
    this.isHost = false,
    this.vote,
  });

  Player copyWith({
    String? id,
    String? name,
    bool? isHost,
    String? vote,
    bool clearVote = false,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      isHost: isHost ?? this.isHost,
      vote: clearVote ? null : (vote ?? this.vote),
    );
  }

  @override
  List<Object?> get props => [id, name, isHost, vote];
}
