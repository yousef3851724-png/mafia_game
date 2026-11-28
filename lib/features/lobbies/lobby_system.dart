import 'lobby_domain.dart';

export 'lobby_domain.dart';

/// Backwards-compatible facade for the lobby chat API.
/// All lobby domain models remain in lobby_domain.dart; this facade keeps the
/// historical LobbyChatStore API available to older screens and tests.
class LobbyChatStore {
  LobbyChatStore._();

  static final Map<String, List<LobbyChatMessage>> _messages = {};

  static List<LobbyChatMessage> messagesFor(String id) =>
      List.unmodifiable(_messages[id] ?? const <LobbyChatMessage>[]);

  static void seed(String id, String owner) {
    if (_messages.containsKey(id)) return;
    _messages[id] = [
      LobbyChatMessage(
        id: '${id}_system_start',
        lobbyId: id,
        senderId: 'system',
        senderName: 'سیستم',
        content: '$owner لابی را ساخت.',
        sentAt: DateTime.now(),
        type: LobbyChatMessageType.system,
      ),
    ];
  }

  static bool canRead(String id, String player, LobbyDefinition lobby) =>
      lobby.id == id && lobby.hasPlayer(player);

  static bool canWrite(String id, String player, LobbyDefinition lobby) =>
      canRead(id, player, lobby) &&
      lobby.permissionsFor(player).contains(LobbyPermission.sendChat);

  static LobbyChatMessage? send({
    required LobbyDefinition lobby,
    required String senderId,
    required String senderName,
    String text = '',
    String? emoji,
    String? sticker,
  }) {
    if (!canWrite(lobby.id, senderId, lobby)) return null;

    final content = emoji ?? sticker ?? text.trim();
    if (content.isEmpty) return null;

    final type = emoji != null
        ? LobbyChatMessageType.emoji
        : sticker != null
            ? LobbyChatMessageType.sticker
            : LobbyChatMessageType.text;

    final message = LobbyChatMessage(
      id: '${lobby.id}_${DateTime.now().microsecondsSinceEpoch}',
      lobbyId: lobby.id,
      senderId: senderId,
      senderName: senderName,
      content: content,
      sentAt: DateTime.now(),
      type: type,
    );

    _messages.putIfAbsent(lobby.id, () => <LobbyChatMessage>[]).add(message);
    return message;
  }
}
