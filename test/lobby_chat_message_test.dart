import 'package:flutter_test/flutter_test.dart';
import 'package:mafia_radical/features/lobbies/lobby_system.dart';

void main() {
  group('LobbyChatMessage Tests', () {
    test('creates instance correctly', () {
      final now = DateTime.now();
      final message = LobbyChatMessage(
        id: '1',
        lobbyId: 'lobby-1',
        senderId: 'user-1',
        senderName: 'Yousef',
        content: 'Hello World',
        sentAt: now,
        type: LobbyChatMessageType.text,
      );

      expect(message.id, '1');
      expect(message.lobbyId, 'lobby-1');
      expect(message.senderId, 'user-1');
      expect(message.senderName, 'Yousef');
      expect(message.content, 'Hello World');
      expect(message.sentAt, now);
      expect(message.type, LobbyChatMessageType.text);
      expect(message.reactions, isEmpty);
    });

    test('react adds new reaction', () {
      final message = LobbyChatMessage(
        id: '1',
        lobbyId: 'lobby-1',
        senderId: 'user-1',
        senderName: 'Yousef',
        content: 'Hello',
        sentAt: DateTime.now(),
      );

      final reacted = message.react('❤️', 'user-2');
      expect(reacted.reactions['❤️'], contains('user-2'));
    });

    test('toMap and fromMap serialization work', () {
      final now = DateTime.fromMillisecondsSinceEpoch(1700000000000);
      final message = LobbyChatMessage(
        id: 'msg-123',
        lobbyId: 'lobby-abc',
        senderId: 'user-xyz',
        senderName: 'Amir',
        content: 'Ready to play',
        sentAt: now,
        type: LobbyChatMessageType.system,
        reactions: const {
          '👍': ['user-1', 'user-2'],
        },
      );

      final map = message.toMap();
      final fromMapMessage = LobbyChatMessage.fromMap(map);

      expect(fromMapMessage.id, message.id);
      expect(fromMapMessage.lobbyId, message.lobbyId);
      expect(fromMapMessage.senderId, message.senderId);
      expect(fromMapMessage.senderName, message.senderName);
      expect(fromMapMessage.content, message.content);
      expect(fromMapMessage.sentAt, message.sentAt);
      expect(fromMapMessage.type, message.type);
      expect(fromMapMessage.reactions['👍'], ['user-1', 'user-2']);
    });
  });
}
