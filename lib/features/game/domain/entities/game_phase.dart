import 'package:equatable/equatable.dart';

enum GamePhase { lobby, roleAssignment, night, day, discussion, voting, result, ended }

extension GamePhaseX on GamePhase {
  String get title {
    switch (this) {
      case GamePhase.lobby:
        return 'لابی';
      case GamePhase.roleAssignment:
        return 'تخصیص نقش';
      case GamePhase.night:
        return 'شب';
      case GamePhase.day:
        return 'روز';
      case GamePhase.discussion:
        return 'گفت‌وگو';
      case GamePhase.voting:
        return 'رأی‌گیری';
      case GamePhase.result:
        return 'نتیجه';
      case GamePhase.ended:
        return 'پایان بازی';
    }
  }
}

class PhaseState extends Equatable {
  final GamePhase phase;
  final DateTime? startedAt;
  final Duration duration;

  const PhaseState({
    this.phase = GamePhase.lobby,
    this.startedAt,
    this.duration = Duration.zero,
  });

  PhaseState copyWith({
    GamePhase? phase,
    DateTime? startedAt,
    Duration? duration,
  }) {
    return PhaseState(
      phase: phase ?? this.phase,
      startedAt: startedAt ?? this.startedAt,
      duration: duration ?? this.duration,
    );
  }

  @override
  List<Object?> get props => [phase, startedAt, duration];
}
