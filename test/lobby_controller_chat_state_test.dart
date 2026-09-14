import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mafia_radical/features/lobbies/lobby_state.dart';
import 'package:mafia_radical/features/lobbies/lobby_system.dart';

void main() {
  test('LobbyController keeps typed chat messages and reactions in state', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final controller = container.read(lobbyControllerProvider.notifier);
    controller.createLobby(
      id: 'chat_test_lobby',
      name: 'Chat test',
      category: LobbyCatalog.friendlyAdult,
      label: LobbyLabel.radical,
      ownerId: 'user1',
      ownerName: 'User 1',
    );

    controller.sendMessage(
      lobbyId: 'chat_test_lobby',
      senderId: 'user1',
      senderName: 'User 1',
      text: 'hello',
    );

    final textMessage = container.read(lobbyControllerProvider).chats['chat_test_lobby']!.last;
    expect(textMessage.type, LobbyChatMessageType.text);
    expect(textMessage.content, 'hello');

    controller.react(
      lobbyId: 'chat_test_lobby',
      messageId: textMessage.id,
      actorId: 'user1',
      reaction: '👍',
    );

    final reacted = container.read(lobbyControllerProvider).chats['chat_test_lobby']!.last;
    expect(reacted.reactions['👍'], ['user1']);
    expect(reacted, isNot(same(textMessage)));
  });
}
