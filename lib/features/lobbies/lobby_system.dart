import 'package:flutter/material.dart';
import '../../core/theme/radical_theme.dart';

enum LobbyMode { friendly, ranked }
enum LobbyAge { teen, adult }
enum LobbyLabel { radical, pros, newcomers, vip }
enum DiamondType { blue, radical, teen, adult }
enum LobbyPermission { viewChat, sendChat, react, kick, lock, startGame, viewStats, admin }
enum LobbyChatMessageType { text, emoji, sticker, system }

class LobbyCategory {
  final LobbyMode mode; final LobbyAge age; final String title; final String description; final Color primary; final DiamondType diamond;
  const LobbyCategory({required this.mode, required this.age, required this.title, required this.description, required this.primary, required this.diamond});
  bool get isRanked => mode == LobbyMode.ranked; bool get isAdult => age == LobbyAge.adult; bool get isTeen => age == LobbyAge.teen;
}
class LobbyCatalog {
  LobbyCatalog._();
  static const friendlyTeen = LobbyCategory(mode: LobbyMode.friendly, age: LobbyAge.teen, title: 'دوستانه • نوجوان', description: 'بدون رتبه و امتیاز؛ فضای مناسب زیر ۱۸ سال.', primary: RadicalTheme.violet, diamond: DiamondType.teen);
  static const friendlyAdult = LobbyCategory(mode: LobbyMode.friendly, age: LobbyAge.adult, title: 'دوستانه • بزرگسال', description: 'دورهمی آزاد با محتوای کامل مافیا.', primary: RadicalTheme.gold, diamond: DiamondType.blue);
  static const rankedTeen = LobbyCategory(mode: LobbyMode.ranked, age: LobbyAge.teen, title: 'امتیازی • نوجوان', description: 'رقابتی و رتبه‌ای با محتوای مناسب زیر ۱۸ سال.', primary: RadicalTheme.crimsonBright, diamond: DiamondType.teen);
  static const rankedAdult = LobbyCategory(mode: LobbyMode.ranked, age: LobbyAge.adult, title: 'امتیازی • بزرگسال', description: 'لیگ، رتبه و سناریوهای کامل مافیا.', primary: RadicalTheme.goldBright, diamond: DiamondType.radical);
  static const all = [friendlyTeen, friendlyAdult, rankedTeen, rankedAdult];
  static LobbyCategory of(LobbyMode mode, LobbyAge age) => all.firstWhere((x) => x.mode == mode && x.age == age);
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
  static LobbyLabelDefinition of(LobbyLabel id) => all.firstWhere((x) => x.id == id);
}
class LobbyPlayerLabel {
  final String playerId, playerName; final String? avatarAsset; final bool isLeader, isStaff; final int rating; final Set<LobbyLabel> groupLabels;
  const LobbyPlayerLabel({required this.playerId, required this.playerName, this.avatarAsset, this.isLeader = false, this.isStaff = false, this.rating = 0, this.groupLabels = const {}});
  bool hasGroupLabel(LobbyLabel label) => groupLabels.contains(label);
}
class LobbyChatMessage {
  final String id, lobbyId, senderId, senderName, content; final DateTime? sentAt; final LobbyChatMessageType type; final Map<String, List<String>> reactions;
  const LobbyChatMessage({required this.id, required this.lobbyId, required this.senderId, required this.senderName, required this.content, required this.sentAt, this.type = LobbyChatMessageType.text, this.reactions = const {}});
  String get text => content; String? get emoji => type == LobbyChatMessageType.emoji ? content : null; String? get sticker => type == LobbyChatMessageType.sticker ? content : null; bool get system => type == LobbyChatMessageType.system;
  LobbyChatMessage copyWith({String? id, String? lobbyId, String? senderId, String? senderName, String? content, Object? sentAt = _keep, LobbyChatMessageType? type, Map<String, List<String>>? reactions}) => LobbyChatMessage(id: id ?? this.id, lobbyId: lobbyId ?? this.lobbyId, senderId: senderId ?? this.senderId, senderName: senderName ?? this.senderName, content: content ?? this.content, sentAt: identical(sentAt, _keep) ? this.sentAt : sentAt as DateTime?, type: type ?? this.type, reactions: reactions ?? this.reactions);
  LobbyChatMessage react(String reaction, String playerId) { final copy = <String, List<String>>{for (final e in reactions.entries) e.key: [...e.value]}; copy.putIfAbsent(reaction, () => []).add(playerId); return copyWith(reactions: copy); }
  static const _keep = Object();
}
typedef LobbyMessage = LobbyChatMessage;
class LobbyChatStore {
  LobbyChatStore._(); static final Map<String, List<LobbyChatMessage>> _messages = {};
  static List<LobbyChatMessage> messagesFor(String id) => List.unmodifiable(_messages[id] ?? const []);
  static void seed(String id, String owner) { if (_messages.containsKey(id)) return; _messages[id] = [LobbyChatMessage(id: '${id}_system_start', lobbyId: id, senderId: 'system', senderName: 'سیستم', content: '$owner لابی را ساخت.', sentAt: DateTime.now(), type: LobbyChatMessageType.system)]; }
  static bool canRead(String id, String player, LobbyDefinition lobby) => lobby.id == id && lobby.hasPlayer(player);
  static bool canWrite(String id, String player, LobbyDefinition lobby) => canRead(id, player, lobby) && lobby.permissionsFor(player).contains(LobbyPermission.sendChat);
  static LobbyChatMessage? send({required LobbyDefinition lobby, required String senderId, required String senderName, String text = '', String? emoji, String? sticker}) { if (!canWrite(lobby.id, senderId, lobby)) return null; final content = emoji ?? sticker ?? text.trim(); if (content.isEmpty) return null; final type = emoji != null ? LobbyChatMessageType.emoji : sticker != null ? LobbyChatMessageType.sticker : LobbyChatMessageType.text; final m = LobbyChatMessage(id: '${lobby.id}_${DateTime.now().microsecondsSinceEpoch}', lobbyId: lobby.id, senderId: senderId, senderName: senderName, content: content, sentAt: DateTime.now(), type: type); _messages.putIfAbsent(lobby.id, () => []).add(m); return m; }
}
class LobbyDefinition {
  final String id, name, ownerId; final LobbyCategory category; final LobbyLabel label; final bool locked, staffOnly; final List<LobbyPlayerLabel> players;
  const LobbyDefinition({required this.id, required this.name, required this.category, required this.label, required this.ownerId, this.locked = false, this.staffOnly = false, this.players = const []});
  LobbyDefinition copyWith({String? name, LobbyCategory? category, LobbyLabel? label, String? ownerId, bool? locked, bool? staffOnly, List<LobbyPlayerLabel>? players}) => LobbyDefinition(id: id, name: name ?? this.name, category: category ?? this.category, label: label ?? this.label, ownerId: ownerId ?? this.ownerId, locked: locked ?? this.locked, staffOnly: staffOnly ?? this.staffOnly, players: players ?? this.players);
  bool hasPlayer(String id) => players.any((p) => p.playerId == id); LobbyPlayerLabel? player(String id) => players.where((p) => p.playerId == id).firstOrNull;
  Set<LobbyPermission> permissionsFor(String id) { final p = player(id); if (p == null) return const {}; if (p.isLeader) return const {LobbyPermission.viewChat, LobbyPermission.sendChat, LobbyPermission.react, LobbyPermission.kick, LobbyPermission.lock, LobbyPermission.startGame}; return const {LobbyPermission.viewChat, LobbyPermission.sendChat, LobbyPermission.react}; }
}
class LobbyEngine { const LobbyEngine(); bool canJoin(LobbyDefinition lobby, LobbyPlayerLabel p) => !lobby.staffOnly || p.isStaff; LobbyDefinition join(LobbyDefinition lobby, LobbyPlayerLabel p) { if (lobby.locked || !canJoin(lobby, p)) throw StateError('Player cannot join this lobby.'); return lobby.hasPlayer(p.playerId) ? lobby : lobby.copyWith(players: [...lobby.players, p]); } LobbyDefinition leave(LobbyDefinition lobby, String id) => lobby.copyWith(players: lobby.players.where((p) => p.playerId != id).toList()); LobbyDefinition setLocked(LobbyDefinition lobby, String actor, bool locked) { if (!lobby.permissionsFor(actor).contains(LobbyPermission.lock)) throw StateError('Lock permission denied.'); return lobby.copyWith(locked: locked); } }
class RadicalStaffDirectory { RadicalStaffDirectory._(); static const members = [LobbyPlayerLabel(playerId: 'staff_01', playerName: 'رادیکال • مدیر', isStaff: true, rating: 9999), LobbyPlayerLabel(playerId: 'staff_02', playerName: 'رادیکال • ناظر', isStaff: true, rating: 9800), LobbyPlayerLabel(playerId: 'staff_03', playerName: 'رادیکال • پشتیبان', isStaff: true, rating: 9500)]; static bool isStaff(String id) => members.any((m) => m.playerId == id); static LobbyPlayerLabel? member(String id) => members.where((m) => m.playerId == id).firstOrNull; }
class RadicalDiamondDefinition { final DiamondType type; final String name, emoji, usage; final Color primary, secondary; const RadicalDiamondDefinition({required this.type, required this.name, required this.emoji, required this.primary, required this.secondary, required this.usage}); }
class RadicalDiamonds {
  RadicalDiamonds._();
  static const all = [
    RadicalDiamondDefinition(type: DiamondType.blue, name: 'الماس رادیکال', emoji: '◆', primary: RadicalTheme.gold, secondary: RadicalTheme.goldBright, usage: 'لابی‌های دوستانه'),
    RadicalDiamondDefinition(type: DiamondType.radical, name: 'الماس رادیکال', emoji: '◆', primary: RadicalTheme.violet, secondary: RadicalTheme.goldBright, usage: 'لابی‌های امتیازی و VIP'),
    RadicalDiamondDefinition(type: DiamondType.teen, name: 'الماس رادیکال نوجوان', emoji: '✦', primary: RadicalTheme.violet, secondary: RadicalTheme.goldBright, usage: 'لابی‌های نوجوانان'),
    RadicalDiamondDefinition(type: DiamondType.adult, name: 'الماس رادیکال بزرگسال', emoji: '◆', primary: RadicalTheme.crimsonBright, secondary: RadicalTheme.goldBright, usage: 'لابی‌های بزرگسالان'),
  ];
  static RadicalDiamondDefinition of(DiamondType type) => all.firstWhere((x) => x.type == type);
  static bool supports(LobbyCategory category, DiamondType type) => switch (category.mode) { LobbyMode.friendly => category.age == LobbyAge.teen ? type == DiamondType.teen : type == DiamondType.blue, LobbyMode.ranked => type == DiamondType.radical || (category.age == LobbyAge.teen && type == DiamondType.teen) || (category.age == LobbyAge.adult && type == DiamondType.adult) };
}
class LobbyStoreItem { final String id, name; final int price; final DiamondType currency; final bool vip; const LobbyStoreItem({required this.id, required this.name, required this.price, required this.currency, this.vip = false}); }
class LobbyStoreCatalog {
  LobbyStoreCatalog._();
  static const regular = [LobbyStoreItem(id: 'avatar_basic', name: 'آواتار کلاسیک', price: 100, currency: DiamondType.blue), LobbyStoreItem(id: 'sticker_party', name: 'استیکر دورهمی', price: 50, currency: DiamondType.blue), LobbyStoreItem(id: 'teen_sticker_pack', name: 'پک استیکر نوجوان', price: 75, currency: DiamondType.teen)];
  static const vip = [LobbyStoreItem(id: 'avatar_radical', name: 'آواتار رادیکال', price: 100, currency: DiamondType.radical, vip: true), LobbyStoreItem(id: 'lobby_vip', name: 'ورود VIP', price: 250, currency: DiamondType.radical, vip: true), LobbyStoreItem(id: 'scenario_special', name: 'سناریوی ویژه', price: 500, currency: DiamondType.radical, vip: true), LobbyStoreItem(id: 'adult_scenario_pack', name: 'پک سناریوی بزرگسال', price: 450, currency: DiamondType.adult, vip: true)];
}
extension _FirstOrNull<T> on Iterable<T> { T? get firstOrNull => isEmpty ? null : first; }
