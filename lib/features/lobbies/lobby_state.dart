import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'lobby_system.dart';

enum LobbyAction { join, leave, kick, lock, start }

class LobbyAccessProfile {
  final String playerId;
  final LobbyAge age;
  final bool staff;
  const LobbyAccessProfile({required this.playerId, required this.age, this.staff = false});
}

class LobbyState {
  final List<LobbyDefinition> lobbies;
  final Map<String, List<LobbyMessage>> chats;
  final String? activeLobbyId;
  final String? error;
  final int revision;

  const LobbyState({required this.lobbies, required this.chats, required this.activeLobbyId, required this.error, required this.revision});

  factory LobbyState.initial() => const LobbyState(lobbies: [], chats: {}, activeLobbyId: null, error: null, revision: 0);

  LobbyDefinition? get activeLobby {
    final id = activeLobbyId;
    if (id == null) return null;
    for (final lobby in lobbies) {
      if (lobby.id == id) return lobby;
    }
    return null;
  }

  LobbyState copyWith({List<LobbyDefinition>? lobbies, Map<String, List<LobbyMessage>>? chats, Object? activeLobbyId = _keep, Object? error = _keep, int? revision}) => LobbyState(
        lobbies: lobbies ?? this.lobbies,
        chats: chats ?? this.chats,
        activeLobbyId: identical(activeLobbyId, _keep) ? this.activeLobbyId : activeLobbyId as String?,
        error: identical(error, _keep) ? this.error : error as String?,
        revision: revision ?? this.revision,
      );

  static const _keep = Object();
}

final lobbyControllerProvider = NotifierProvider<LobbyController, LobbyState>(LobbyController.new);

class LobbyController extends Notifier<LobbyState> {
  @override
  LobbyState build() => LobbyState.initial();

  LobbyDefinition createLobby({required String id, required String name, required LobbyCategory category, required LobbyLabel label, required String ownerId, required String ownerName, bool staffOnly = false}) {
    final existing = state.lobbies.any((lobby) => lobby.id == id);
    if (existing) throw StateError('این شناسه لابی قبلاً استفاده شده است.');
    if (staffOnly && !RadicalStaffDirectory.isStaff(ownerId)) throw StateError('فقط همکاران رادیکال می‌توانند لابی اختصاصی بسازند.');
    final lobby = LobbyDefinition(id: id, name: name, category: category, label: label, ownerId: ownerId, staffOnly: staffOnly, players: [LobbyPlayerLabel(playerId: ownerId, playerName: ownerName, isLeader: true, isStaff: RadicalStaffDirectory.isStaff(ownerId))]);
    _commit(lobbies: [...state.lobbies, lobby], activeLobbyId: lobby.id);
    _system(lobby.id, '$ownerName لابی را ساخت و به عنوان لیدر وارد شد.');
    return lobby;
  }

  LobbyDefinition createStaffLobby({required String ownerId, required String ownerName}) => createLobby(id: 'radical_staff', name: 'لابی همکاران رادیکال', category: LobbyCatalog.rankedAdult, label: LobbyLabel.radical, ownerId: ownerId, ownerName: ownerName, staffOnly: true);

  bool canJoin(LobbyDefinition lobby, LobbyAccessProfile profile) {
    if (lobby.staffOnly && !profile.staff && !RadicalStaffDirectory.isStaff(profile.playerId)) return false;
    if (lobby.category.age != profile.age) return false;
    if (lobby.locked && lobby.ownerId != profile.playerId) return false;
    if (lobby.category.isRanked && lobby.category.diamond == DiamondType.radical && !profile.staff) return true;
    return true;
  }

  void joinLobby({required String lobbyId, required LobbyAccessProfile profile, required String playerName, String? avatarAsset}) {
    final lobby = _find(lobbyId);
    if (lobby == null) throw StateError('لابی پیدا نشد.');
    if (!canJoin(lobby, profile)) throw StateError('شرایط ورود به این لابی را نداری.');
    if (lobby.players.any((p) => p.playerId == profile.playerId)) {
      state = state.copyWith(activeLobbyId: lobby.id, error: null);
      return;
    }
    final player = LobbyPlayerLabel(playerId: profile.playerId, playerName: playerName, avatarAsset: avatarAsset, isStaff: profile.staff || RadicalStaffDirectory.isStaff(profile.playerId));
    _replace(lobby.copyWith(players: [...lobby.players, player]));
    state = state.copyWith(activeLobbyId: lobby.id, error: null, revision: state.revision + 1);
    _system(lobby.id, '$playerName وارد لابی شد.');
  }

  void leaveLobby({required String lobbyId, required String playerId}) {
    final lobby = _find(lobbyId);
    if (lobby == null) return;
    final player = lobby.players.where((p) => p.playerId == playerId).firstOrNull;
    if (player == null) return;
    if (player.isLeader) throw StateError('لیدر باید ابتدا لابی را ببندد یا مدیریت را منتقل کند.');
    _replace(lobby.copyWith(players: lobby.players.where((p) => p.playerId != playerId).toList(growable: false)));
    if (state.activeLobbyId == lobbyId) state = state.copyWith(activeLobbyId: null, revision: state.revision + 1);
    _system(lobbyId, '${player.playerName} از لابی خارج شد.');
  }

  void kick({required String lobbyId, required String actorId, required String targetId}) {
    final lobby = _find(lobbyId);
    if (lobby == null) throw StateError('لابی پیدا نشد.');
    _requireLeader(lobby, actorId);
    final target = lobby.players.where((p) => p.playerId == targetId).firstOrNull;
    if (target == null || target.isLeader) return;
    _replace(lobby.copyWith(players: lobby.players.where((p) => p.playerId != targetId).toList(growable: false)));
    _system(lobbyId, '${target.playerName} توسط لیدر از لابی اخراج شد.');
  }

  void toggleLock({required String lobbyId, required String actorId}) {
    final lobby = _find(lobbyId);
    if (lobby == null) throw StateError('لابی پیدا نشد.');
    _requireLeader(lobby, actorId);
    _replace(lobby.copyWith(locked: !lobby.locked));
    _system(lobbyId, lobby.locked ? 'لابی قفل شد.' : 'قفل لابی باز شد.');
  }

  void startGame({required String lobbyId, required String actorId}) {
    final lobby = _find(lobbyId);
    if (lobby == null) throw StateError('لابی پیدا نشد.');
    _requireLeader(lobby, actorId);
    if (lobby.players.length < 4) throw StateError('برای شروع بازی حداقل ۴ بازیکن لازم است.');
    if (lobby.category.isRanked && lobby.players.length != 10) throw StateError('لابی امتیازی دقیقاً به ۱۰ بازیکن نیاز دارد.');
    _system(lobbyId, 'بازی توسط لیدر شروع شد.');
  }

  void sendMessage({required String lobbyId, required String senderId, required String senderName, required String text, String? emoji, String? sticker}) {
    final lobby = _find(lobbyId);
    if (lobby == null || !lobby.players.any((p) => p.playerId == senderId)) throw StateError('فقط اعضای همان لابی می‌توانند پیام ارسال کنند.');
    final trimmed = text.trim();
    if (trimmed.isEmpty && emoji == null && sticker == null) return;
    _addMessage(LobbyMessage(id: '${lobbyId}_${state.revision + 1}', lobbyId: lobbyId, senderId: senderId, senderName: senderName, text: trimmed, sentAt: DateTime.now(), emoji: emoji, sticker: sticker));
  }

  void sendQuickEmoji({required String lobbyId, required String senderId, required String senderName, required String emoji}) => sendMessage(lobbyId: lobbyId, senderId: senderId, senderName: senderName, text: '', emoji: emoji);

  void react({required String lobbyId, required String messageId, required String actorId}) {
    final lobby = _find(lobbyId);
    if (lobby == null || !lobby.players.any((p) => p.playerId == actorId)) throw StateError('واکنش فقط برای اعضای همان لابی مجاز است.');
    final messages = [...(state.chats[lobbyId] ?? const <LobbyMessage>[])];
    final index = messages.indexWhere((m) => m.id == messageId);
    if (index < 0) return;
    final old = messages[index];
    messages[index] = LobbyMessage(id: old.id, lobbyId: old.lobbyId, senderId: old.senderId, senderName: old.senderName, text: old.text, sentAt: old.sentAt, system: old.system, emoji: old.emoji, sticker: old.sticker, reactions: old.reactions + 1);
    final chats = {...state.chats, lobbyId: List.unmodifiable(messages)};
    state = state.copyWith(chats: chats, error: null, revision: state.revision + 1);
  }

  List<LobbyMessage> messagesFor(String lobbyId) => List.unmodifiable(state.chats[lobbyId] ?? const <LobbyMessage>[]);

  LobbyDefinition? _find(String id) {
    for (final lobby in state.lobbies) {
      if (lobby.id == id) return lobby;
    }
    return null;
  }

  void _replace(LobbyDefinition lobby) => _commit(lobbies: [for (final item in state.lobbies) if (item.id == lobby.id) lobby else item]);

  void _commit({List<LobbyDefinition>? lobbies, Object? activeLobbyId = _keep, Object? error = _keep}) => state = state.copyWith(lobbies: lobbies, activeLobbyId: activeLobbyId, error: error, revision: state.revision + 1);

  void _addMessage(LobbyMessage message) {
    final messages = [...(state.chats[message.lobbyId] ?? const <LobbyMessage>[]) , message];
    state = state.copyWith(chats: {...state.chats, message.lobbyId: List.unmodifiable(messages)}, error: null, revision: state.revision + 1);
  }

  void _system(String lobbyId, String text) => _addMessage(LobbyMessage(id: '${lobbyId}_system_${state.revision + 1}', lobbyId: lobbyId, senderId: 'system', senderName: 'سیستم', text: text, sentAt: DateTime.now(), system: true));

  void _requireLeader(LobbyDefinition lobby, String actorId) {
    if (lobby.ownerId != actorId) throw StateError('این عملیات فقط در اختیار لیدر لابی است.');
  }

  static const _keep = Object();
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
