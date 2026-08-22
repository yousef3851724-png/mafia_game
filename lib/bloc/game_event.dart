import 'package:equatable/equatable.dart';

abstract class GameEvent extends Equatable {
  const GameEvent();
  @override
  List<Object?> get props => [];
}

// رویداد شروع بازی
class StartGameEvent extends GameEvent {
  final List<String> playerNames;
  const StartGameEvent({required this.playerNames});
  @override
  List<Object?> get props => [playerNames];
}

// رویداد کشتن توسط مافیا
class KillPlayerEvent extends GameEvent {
  final int playerId;
  const KillPlayerEvent({required this.playerId});
  @override
  List<Object?> get props => [playerId];
}

// رویداد نجات توسط دکتر
class HealPlayerEvent extends GameEvent {
  final int playerId;
  const HealPlayerEvent({required this.playerId});
  @override
  List<Object?> get props => [playerId];
}

// رویداد بررسی توسط کارآگاه
class InvestigatePlayerEvent extends GameEvent {
  final int playerId;
  const InvestigatePlayerEvent({required this.playerId});
  @override
  List<Object?> get props => [playerId];
}

// رویداد رأی‌گیری در روز
class VotePlayerEvent extends GameEvent {
  final Map<int, int> votes;
  const VotePlayerEvent({required this.votes});
  @override
  List<Object?> get props => [votes];
}

// رویداد تغییر فاز (شب ↔ روز)
class NextPhaseEvent extends GameEvent {}
