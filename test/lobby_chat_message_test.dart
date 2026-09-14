import 'package:flutter_test/flutter_test.dart';

import 'package:mafia_radical/features/lobbies/lobby_system.dart';

void main() {
  test('LobbyChatMessage serializes typed content and reaction actors', () {
    final sentAt = DateTime.fromMillisecondsSinceEpoch(1730000000123);
    final message = LobbyChatMessage(
      id: 'm1',
      lobbyId: 'l1',
      senderId: 'user1',
      senderName: 'User 1',
      content: '🔥',
      sentAt: sentAt,
      type: LobbyChatMessageType.emoji,
    ).react('👍', 'user1').react('👍', 'user2');

    final restored = LobbyChatMessage.fromMap(message.toMap());

    expect(restored.id, 'm1');
    expect(restored.content, '🔥');
    expect(restored.type, LobbyChatMessageType.emoji);
    expect(restored.sentAt?.millisecondsSinceEpoch, 1730000000123);
    expect(restored.reactions, {
      '👍': ['user1', 'user2'],
    });
  });

  test('react is immutable and does not duplicate the same actor', () {
    const message = LobbyChatMessage(
      id: 'm2',
      lobbyId: 'l1',
      senderId: 'user1',
      senderName: 'User 1',
      content: 'hello',
      sentAt: null,
    );

    final reacted = message.react('👍', 'user1').react('👍', 'user1');

    expect(message.reactions, isEmpty);
    expect(reacted.reactions['👍'], ['user1']);
  });

  test('system messages use the typed system variant', () {
    final message = LobbyChatMessage(
      id: 'm3',
      lobbyId: 'l1',
      senderId: 'system',
      senderName: 'سیستم',
      content: 'لابی ساخته شد.',
      sentAt: DateTime.now(),
      type: LobbyChatMessageType.system,
    );

    expect(message.type, LobbyChatMessageType.system);
    expect(message.content, 'لابی ساخته شد.');
  });
}
