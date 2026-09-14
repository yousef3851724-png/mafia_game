enum LobbyChatMessageType {
  text,
  emoji,
  system,
}

class LobbyChatMessage {
  final String id;
  final String lobbyId;
  final String senderId;
  final String senderName;
  final String content;
  final DateTime? sentAt;
  final LobbyChatMessageType type;
  final Map<String, List<String>> reactions;

  const LobbyChatMessage({
    required this.id,
    required this.lobbyId,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.sentAt,
    this.type = LobbyChatMessageType.text,
    this.reactions = const <String, List<String>>{},
  });

  LobbyChatMessage react(String emoji, String actorId) {
    final updatedReactions = <String, List<String>>{
      for (final entry in reactions.entries)
        entry.key: List<String>.from(entry.value),
    };
    final actors = updatedReactions.putIfAbsent(emoji, () => <String>[]);
    if (!actors.contains(actorId)) {
      actors.add(actorId);
    }
    return LobbyChatMessage(
      id: id,
      lobbyId: lobbyId,
      senderId: senderId,
      senderName: senderName,
      content: content,
      sentAt: sentAt,
      type: type,
      reactions: updatedReactions,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'lobbyId': lobbyId,
      'senderId': senderId,
      'senderName': senderName,
      'content': content,
      'sentAt': sentAt?.millisecondsSinceEpoch,
      'type': type.name,
      'reactions': reactions.map(
        (emoji, actors) => MapEntry(emoji, List<String>.from(actors)),
      ),
    };
  }

  factory LobbyChatMessage.fromMap(Map<String, dynamic> map) {
    final rawReactions = map['reactions'];
    final parsedReactions = <String, List<String>>{};
    if (rawReactions is Map) {
      rawReactions.forEach((key, value) {
        if (value is List) {
          parsedReactions[key.toString()] =
              value.map((e) => e.toString()).toList();
        }
      });
    }

    final rawSentAt = map['sentAt'];
    DateTime? parsedSentAt;
    if (rawSentAt is int) {
      parsedSentAt = DateTime.fromMillisecondsSinceEpoch(rawSentAt);
    } else if (rawSentAt is String) {
      parsedSentAt = DateTime.tryParse(rawSentAt);
    }

    final rawType = map['type']?.toString();
    final parsedType = LobbyChatMessageType.values.firstWhere(
      (value) => value.name == rawType,
      orElse: () => LobbyChatMessageType.text,
    );

    return LobbyChatMessage(
      id: map['id']?.toString() ?? '',
      lobbyId: map['lobbyId']?.toString() ?? '',
      senderId: map['senderId']?.toString() ?? '',
      senderName: map['senderName']?.toString() ?? '',
      content: map['content']?.toString() ?? '',
      sentAt: parsedSentAt,
      type: parsedType,
      reactions: parsedReactions,
    );
  }
}
