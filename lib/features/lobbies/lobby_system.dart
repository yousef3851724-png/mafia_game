export 'lobby_domain.dart';

/// Backwards-compatible facade for the lobby chat API.
class LobbyChatStore {
  LobbyChatStore._();
  static final Map<String, List<LobbyChatMessage>> _messages = {};
  static List<LobbyChatMessage> messagesFor(String id) => List.unmodifiable(_messages[id] ?? const <LobbyChatMessage>[]);
  static void seed(String id, String owner) {
    if (_messages.containsKey(id)) return;
    _messages[id] = [LobbyChatMessage(id: '${id}_system_start', lobbyId: id, senderId: 'system', senderName: 'سیستم', content: '$owner لابی را ساخت.', sentAt: DateTime.now(), type: LobbyChatMessageType.system)];
  }
  static bool canRead(String id, String player, LobbyDefinition lobby) => lobby.id == id && lobby.hasPlayer(player);
  static bool canWrite(String id, String player, LobbyDefinition lobby) => canRead(id, player, lobby) && lobby.permissionsFor(player).contains(LobbyPermission.sendChat);
}
