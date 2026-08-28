import 'dart:async';
import '../models/game_state_model.dart';

abstract class GameRemoteDataSource {
  Future<void> initSocket(String roomId, String playerId);
  Stream<List<PlayerModel>> get onPlayersUpdated;
  Stream<String> get onPhaseChanged;
  Future<void> emitJoinRoom(String roomId, String playerName);
  Future<void> emitVote(String roomId, String voterId, String targetPlayerId);
  Future<void> closeSocket();
}

class GameRemoteDataSourceImpl implements GameRemoteDataSource {
  final _playersController = StreamController<List<PlayerModel>>.broadcast();
  final _phaseController = StreamController<String>.broadcast();

  @override
  Future<void> initSocket(String roomId, String playerId) async {
    // پیاده‌سازی اتصال Socket.io و لیسنرها
  }

  @override
  Stream<List<PlayerModel>> get onPlayersUpdated => _playersController.stream;

  @override
  Stream<String> get onPhaseChanged => _phaseController.stream;

  @override
  Future<void> emitJoinRoom(String roomId, String playerName) async {
    // ارسال اونت join_room به سوکت
  }

  @override
  Future<void> emitVote(String roomId, String voterId, String targetPlayerId) async {
    // ارسال اونت submit_vote به سوکت
  }

  @override
  Future<void> closeSocket() async {
    await _playersController.close();
    await _phaseController.close();
  }
}
