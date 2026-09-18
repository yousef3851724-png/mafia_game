import 'package:equatable/equatable.dart';

class SessionPlayer extends Equatable {
  final String id;
  final String name;
  final bool isHost;
  final String? vote;

  const SessionPlayer({
    required this.id,
    required this.name,
    this.isHost = false,
    this.vote,
  });

  SessionPlayer copyWith({
    String? id,
    String? name,
    bool? isHost,
    String? vote,
    bool clearVote = false,
  }) {
    return SessionPlayer(
      id: id ?? this.id,
      name: name ?? this.name,
      isHost: isHost ?? this.isHost,
      vote: clearVote ? null : (vote ?? this.vote),
    );
  }

  @override
  List<Object?> get props => [id, name, isHost, vote];
}
