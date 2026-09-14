import 'package:flutter/material.dart';

import '../../core/theme/radical_theme.dart';

enum LobbyMode { friendly, ranked }
enum LobbyAge { teen, adult }
enum LobbyLabel { radical, pros, newcomers, vip }
enum DiamondType { blue, radical, teen, adult }
enum LobbyPermission { viewChat, sendChat, react, kick, lock, startGame, viewStats, admin }
enum LobbyChatMessageType { text, emoji, sticker, system }

class LobbyCategory {
  final LobbyMode mode;
  final LobbyAge age;
  final String title;
  final String description;
  final Color primary;
  final DiamondType diamond;
  const LobbyCategory({required this.mode, required this.age, required this.title, required this.description, required this.primary, required this.diamond});
  bool get isRanked => mode == LobbyMode.ranked;
  bool get isAdult => age == LobbyAge.adult;
  bool get isTeen => age == LobbyAge.teen;
}

class LobbyCatalog {
  LobbyCatalog._();
  static const friendlyTeen = LobbyCategory(mode: LobbyMode.friendly, age: LobbyAge.teen, title: 'دوستانه • نوجوان', description: 'بدون رتبه و امتیاز؛ فضای مناسب زیر ۱۸ سال.', primary: RadicalTheme.violet, diamond: DiamondType.teen);
  static const friendlyAdult = LobbyCategory(mode: LobbyMode.friendly, age: LobbyAge.adult, title: 'دوستانه • بزرگسال', description: 'دورهمی آزاد با محتوای کامل مافیا.', primary: RadicalTheme.gold, diamond: DiamondType.blue);
  static const rankedTeen = LobbyCategory(mode: LobbyMode.ranked, age: LobbyAge.teen, title: 'امتیازی • نوجوان', description: 'رقابتی و رتبه‌ای با محتوای مناسب زیر ۱۸ سال.', primary: RadicalTheme.crimsonBright, diamond: DiamondType.teen);
  static const rankedAdult = LobbyCategory(mode: LobbyMode.ranked, age: LobbyAge.adult, title: 'امتیازی • بزرگسال', description: 'لیگ، رتبه و سناریوهای کامل مافیا.', primary: RadicalTheme.goldBright, diamond: DiamondType.radical);
  static const all = [friendlyTeen, friendlyAdult, rankedTeen, rankedAdult];
  static LobbyCategory of(LobbyMode mode, LobbyAge age) => all.firstWhere((item) => item.mode == mode && item.age == age);
  static bool canEnter({required LobbyCategory category, required LobbyAge playerAge, required bool isStaff}) => playerAge == category.age || isStaff;
}

class LobbyLabelDefinition { final LobbyLabel id; final String title; final IconData icon; final Color color; const LobbyLabelDefinition(this.id, this.title, this.icon, this.color); }
class LobbyLabels {
  LobbyLabels._();
  static const all = [
    LobbyLabelDefinition(LobbyLabel.radical, 'لابی رادیکال', Icons.whatshot_rounded, RadicalTheme.goldBright),
    LobbyLabelDefinition(LobbyLabel.pros, 'لابی حرفه‌ای‌ها', Icons.workspace_premium_rounded, RadicalTheme.violet),
    LobbyLabelDefinition(LobbyLabel.newcomers, 'لابی تازه‌کارها', Icons.school_rounded, RadicalTheme.smoke),
    LobbyLabelDefinition(LobbyLabel.vip, 'لابی VIP', Icons.diamond_rounded, RadicalTheme.gold),
  ];
  static LobbyLabelDefinition of(LobbyLabel id) => all.firstWhere((item) => item.id == id);
}

class LobbyPlayerLabel {
  final String playerId; final String playerName; final String? avatarAsset; final bool isLeader; final bool isStaff; final int rating; final Set<LobbyLabel> groupLabels;
  const LobbyPlayerLabel({required this.playerId, required this.playerName, this.avatarAsset, this.isLeader = false, this.isStaff = false, this.rating = 0, this.groupLabels = const {}});
  bool hasGroupLabel(LobbyLabel label) => groupLabels.contains(label);
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

  const LobbyChatMessage({required this.id, required this.lobbyId, required this.senderId, required this.senderName, required this.content, required this.sentAt, this.type = LobbyChatMessageType.text, this.reactions = const <String, List<String>>{}});
  String get text => content;
  String? get emoji => type == LobbyChatMessageType.emoji ? content : null;
  String? get sticker => type == LobbyChatMessageType.sticker ? content : null;
  bool get system => type == LobbyChatMessageType.system;
  LobbyChatMessage copyWith({String? id, String? lobbyId, String? senderId, String? senderName, String? content, Object? sentAt = _keep, LobbyChatMessageType? type, Map<String, List<String>>? reactions}) => LobbyChatMessage(id: id ?? this.id, lobbyId: lobbyId ?? this.lobbyId, senderId: senderId ?? this.senderId, senderName: senderName ?? this.senderName, content: content ?? this.content, sentAt: identical(sentAt, _keep) ? this.sentAt : sentAt as DateTime?, type: type ?? this.type, reactions: _copyReactions(reactions ?? this.reactions));
  LobbyChatMessage react(String reaction, String playerId) { final updated = _copyReactions(reactions); final users = [...(updated[reaction] ?? const <String>[])]; if (!users.contains(playerId)) users.add(playerId); updated[reaction] = List.unmodifiable(users); return copyWith(reactions: updated); }
  Map<String, dynamic> toMap() => {'id': id, 'lobbyId': lobbyId, 'senderId': senderId, 'senderName': senderName, 'content': content, 'sentAt': sentAt?.millisecondsSinceEpoch, 'type': type.name, 'reactions': reactions.map((key, value) => MapEntry(key, List<String>.from(value)))};
  factory LobbyChatMessage.fromMap(Map<String, dynamic> map) { final rawReactions = map['reactions']; final parsedReactions = <String, List<String>>{}; if (rawReactions is Map) { for (final entry in rawReactions.entries) { final users = entry.value is List ? List<String>.from(entry.value as List) : <String>[]; parsedReactions[entry.key.toString()] = List.unmodifiable(users); } } final rawType = map['type']?.toString(); final type = LobbyChatMessageType.values.firstWhere((value) => value.name == rawType, orElse: () => LobbyChatMessageType.text); final rawSentAt = map['sentAt']; final milliseconds = rawSentAt is num ? rawSentAt.toInt() : int.tryParse(rawSentAt?.toString() ?? ''); return LobbyChatMessage(id: map['id']?.toString() ?? '', lobbyId: map['lobbyId']?.toString() ?? '', senderId: map['senderId']?.toString() ?? '', senderName: map['senderName']?.toString() ?? '', content: map['content']?.toString() ?? '', sentAt: milliseconds == null ? null : DateTime.fromMillisecondsSinceEpoch(milliseconds), type: type, reactions: parsedReactions); }
  static Map<String, List<String>> _copyReactions(Map<String, List<String>> source) => {for (final entry in source.entries) entry.key: List.unmodifiable(entry.value)};
  static const _keep = Object();
}

typedef LobbyMessage = LobbyChatMessage;

class LobbyChatStore {
  LobbyChatStore._();
  static final Map<String, List<LobbyChatMessage>> _messages = {};
  static List<LobbyChatMessage> messagesFor(String lobbyId) => List.unmodifiable(_messages[lobbyId] ?? const []);
  static void seed(String lobbyId, String ownerName) { if (_messages.containsKey(lobbyId)) return; _messages[lobbyId] = [LobbyChatMessage(id: '${lobbyId}_system_start', lobbyId: lobbyId, senderId: 'system', senderName: 'سیستم', content: '$ownerName لابی را ساخت.', sentAt: DateTime.now(), type: LobbyChatMessageType.system)]; }
  static bool canRead(String lobbyId, String playerId, LobbyDefinition lobby) => lobby.id == lobbyId && lobby.hasPlayer(playerId);
  static bool canWrite(String lobbyId, String playerId, LobbyDefinition lobby) => canRead(lobbyId, playerId, lobby) && lobby.permissionsFor(playerId).contains(LobbyPermission.sendChat);
  static LobbyChatMessage? send({required LobbyDefinition lobby, required String senderId, required String senderName, String text = '', String? emoji, String? sticker}) { if (!canWrite(lobby.id, senderId, lobby)) return null; if (text.trim().isEmpty && emoji == null && sticker == null) return null; final type = emoji != null ? LobbyChatMessageType.emoji : sticker != null ? LobbyChatMessageType.sticker : LobbyChatMessageType.text; final content = emoji ?? sticker ?? text.trim(); final message = LobbyChatMessage(id: '${lobby.id}_${DateTime.now().microsecondsSinceEpoch}', lobbyId: lobby.id, senderId: senderId, senderName: senderName, content: content, sentAt: DateTime.now(), type: type); _messages.putIfAbsent(lobby.id, () => <LobbyChatMessage>[]).add(message); return message; }
  static bool react({required LobbyDefinition lobby, required String playerId, required String messageId, required String reaction}) { if (!canRead(lobby.id, playerId, lobby) || !lobby.permissionsFor(playerId).contains(LobbyPermission.react)) return false; final list = _messages[lobby.id]; if (list == null) return false; final index = list.indexWhere((m) => m.id == messageId); if (index < 0) return false; list[index] = list[index].react(reaction, playerId); return true; }
}

class LobbyDefinition {
  final String id; final String name; final LobbyCategory category; final LobbyLabel label; final String ownerId; final bool locked; final bool staffOnly; final List<LobbyPlayerLabel> players;
  const LobbyDefinition({required this.id, required this.name, required this.category, required this.label, required this.ownerId, this.locked = false, this.staffOnly = false, this.players = const []});
  LobbyDefinition copyWith({String? name, LobbyCategory? category, LobbyLabel? label, String? ownerId, bool? locked, bool? staffOnly, List<LobbyPlayerLabel>? players}) => LobbyDefinition(id: id, name: name ?? this.name, category: category ?? this.category, label: label ?? this.label, ownerId: ownerId ?? this.ownerId, locked: locked ?? this.locked, staffOnly: staffOnly ?? this.staffOnly, players: players ?? this.players);
  bool hasPlayer(String playerId) => players.any((player) => player.playerId == playerId);
  LobbyPlayerLabel? player(String playerId) => players.where((p) => p.playerId == playerId).firstOrNull;
  Set<LobbyPermission> permissionsFor(String playerId) { final member = player(playerId); if (member == null) return const {}; if (member.isStaff && staffOnly) return LobbyPermission.values.toSet(); if (member.isLeader) return const {LobbyPermission.viewChat, LobbyPermission.sendChat, LobbyPermission.react, LobbyPermission.kick, LobbyPermission.lock, LobbyPermission.startGame}; return const {LobbyPermission.viewChat, LobbyPermission.sendChat, LobbyPermission.react}; }
}

class LobbyEngine {
  const LobbyEngine();
  bool canJoin(LobbyDefinition lobby, LobbyPlayerLabel player) => !lobby.staffOnly || player.isStaff;
  LobbyDefinition join(LobbyDefinition lobby, LobbyPlayerLabel player) { if (lobby.locked || !canJoin(lobby, player)) throw StateError('Player cannot join this lobby.'); if (lobby.hasPlayer(player.playerId)) return lobby; return lobby.copyWith(players: [...lobby.players, player]); }
  LobbyDefinition leave(LobbyDefinition lobby, String playerId) { final remaining = lobby.players.where((p) => p.playerId != playerId).toList(growable: false); if (remaining.isEmpty) return lobby.copyWith(players: const []); if (lobby.ownerId == playerId) { final nextLeader = remaining.first; return lobby.copyWith(ownerId: nextLeader.playerId, players: remaining.map((p) => p.playerId == nextLeader.playerId ? LobbyPlayerLabel(playerId: p.playerId, playerName: p.playerName, avatarAsset: p.avatarAsset, isLeader: true, isStaff: p.isStaff, rating: p.rating, groupLabels: p.groupLabels) : p).toList(growable: false)); } return lobby.copyWith(players: remaining); }
  LobbyDefinition kick(LobbyDefinition lobby, String actorId, String targetId) { if (!lobby.permissionsFor(actorId).contains(LobbyPermission.kick) || actorId == targetId) throw StateError('Kick permission denied.'); return leave(lobby, targetId); }
  LobbyDefinition setLocked(LobbyDefinition lobby, String actorId, bool locked) { if (!lobby.permissionsFor(actorId).contains(LobbyPermission.lock)) throw StateError('Lock permission denied.'); return lobby.copyWith(locked: locked); }
}

class RadicalStaffDirectory {
  RadicalStaffDirectory._();
  static const members = [LobbyPlayerLabel(playerId: 'staff_01', playerName: 'رادیکال • مدیر', isStaff: true, rating: 9999), LobbyPlayerLabel(playerId: 'staff_02', playerName: 'رادیکال • ناظر', isStaff: true, rating: 9800), LobbyPlayerLabel(playerId: 'staff_03', playerName: 'رادیکال • پشتیبان', isStaff: true, rating: 9500)];
  static bool isStaff(String playerId) => members.any((member) => member.playerId == playerId);
  static LobbyPlayerLabel? member(String playerId) => members.where((member) => member.playerId == playerId).firstOrNull;
}

class RadicalDiamondDefinition { final DiamondType type; final String name; final String emoji; final Color primary; final Color secondary; final String usage; const RadicalDiamondDefinition({required this.type, required this.name, required this.emoji, required this.primary, required this.secondary, required this.usage}); }
class RadicalDiamonds {
  RadicalDiamonds._();
  static const all = [
    RadicalDiamondDefinition(type: DiamondType.blue, name: 'الماس رادیکال', emoji: '◆', primary: RadicalTheme.gold, secondary: RadicalTheme.goldBright, usage: 'لابی‌های دوستانه'),
    RadicalDiamondDefinition(type: DiamondType.radical, name: 'الماس رادیکال', emoji: '◆', primary: RadicalTheme.violet, secondary: RadicalTheme.goldBright, usage: 'لابی‌های امتیازی و VIP'),
    RadicalDiamondDefinition(type: DiamondType.teen, name: 'الماس رادیکال نوجوان', emoji: '✦', primary: RadicalTheme.violet, secondary: RadicalTheme.goldBright, usage: 'لابی‌های نوجوانان'),
    RadicalDiamondDefinition(type: DiamondType.adult, name: 'الماس رادیکال بزرگسال', emoji: '◆', primary: RadicalTheme.crimsonBright, secondary: RadicalTheme.goldBright, usage: 'لابی‌های بزرگسالان'),
  ];
  static RadicalDiamondDefinition of(DiamondType type) => all.firstWhere((item) => item.type == type);
}
