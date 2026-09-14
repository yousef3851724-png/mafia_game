import 'package:flutter/material.dart';

enum LobbyMode { friendly, ranked }
enum LobbyAge { teen, adult }
enum LobbyLabel { radical, pros, newcomers, vip }
enum DiamondType { blue, radical, teen, adult }

enum LobbyPermission { viewChat, sendChat, react, kick, lock, startGame, viewStats, admin }

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
  static const friendlyTeen = LobbyCategory(mode: LobbyMode.friendly, age: LobbyAge.teen, title: 'دوستانه • نوجوان', description: 'بدون رتبه و امتیاز؛ فضای ملایم برای زیر ۱۸ سال.', primary: Color(0xFF69C6B2), diamond: DiamondType.teen);
  static const friendlyAdult = LobbyCategory(mode: LobbyMode.friendly, age: LobbyAge.adult, title: 'دوستانه • بزرگسال', description: 'دورهمی آزاد با محتوای کامل مافیا.', primary: Color(0xFF5BA7D9), diamond: DiamondType.blue);
  static const rankedTeen = LobbyCategory(mode: LobbyMode.ranked, age: LobbyAge.teen, title: 'امتیازی • نوجوان', description: 'رقابتی و رتبه‌ای با محتوای مناسب زیر ۱۸ سال.', primary: Color(0xFFB5D56A), diamond: DiamondType.teen);
  static const rankedAdult = LobbyCategory(mode: LobbyMode.ranked, age: LobbyAge.adult, title: 'امتیازی • بزرگسال', description: 'لیگ، رتبه و سناریوهای کامل مافیا.', primary: Color(0xFFE3B873), diamond: DiamondType.adult);
  static const all = [friendlyTeen, friendlyAdult, rankedTeen, rankedAdult];
  static LobbyCategory of(LobbyMode mode, LobbyAge age) => all.firstWhere((item) => item.mode == mode && item.age == age);
}

class LobbyLabelDefinition {
  final LobbyLabel id; final String title; final IconData icon; final Color color;
  const LobbyLabelDefinition(this.id, this.title, this.icon, this.color);
}
class LobbyLabels {
  LobbyLabels._();
  static const all = [
    LobbyLabelDefinition(LobbyLabel.radical, 'لابی رادیکال', Icons.whatshot_rounded, Color(0xFFE3B873)),
    LobbyLabelDefinition(LobbyLabel.pros, 'لابی حرفه‌ای‌ها', Icons.workspace_premium_rounded, Color(0xFF9A72D9)),
    LobbyLabelDefinition(LobbyLabel.newcomers, 'لابی تازه‌کارها', Icons.school_rounded, Color(0xFF69C6B2)),
    LobbyLabelDefinition(LobbyLabel.vip, 'لابی VIP', Icons.diamond_rounded, Color(0xFFFFDFA0)),
  ];
  static LobbyLabelDefinition of(LobbyLabel id) => all.firstWhere((item) => item.id == id);
}

class LobbyPlayerLabel {
  final String playerId; final String playerName; final String? avatarAsset; final bool isLeader; final bool isStaff; final int rating;
  const LobbyPlayerLabel({required this.playerId, required this.playerName, this.avatarAsset, this.isLeader = false, this.isStaff = false, this.rating = 0});
}

class LobbyMessage {
  final String id; final String lobbyId; final String senderId; final String senderName; final String text; final DateTime? sentAt; final bool system; final String? emoji; final String? sticker; final int reactions;
  const LobbyMessage({required this.id, required this.lobbyId, required this.senderId, required this.senderName, required this.text, required this.sentAt, this.system = false, this.emoji, this.sticker, this.reactions = 0});
}

class LobbyDefinition {
  final String id; final String name; final LobbyCategory category; final LobbyLabel label; final String ownerId; final bool locked; final bool staffOnly; final List<LobbyPlayerLabel> players;
  const LobbyDefinition({required this.id, required this.name, required this.category, required this.label, required this.ownerId, this.locked = false, this.staffOnly = false, this.players = const []});
  LobbyDefinition copyWith({String? name, LobbyCategory? category, LobbyLabel? label, String? ownerId, bool? locked, bool? staffOnly, List<LobbyPlayerLabel>? players}) => LobbyDefinition(id: id, name: name ?? this.name, category: category ?? this.category, label: label ?? this.label, ownerId: ownerId ?? this.ownerId, locked: locked ?? this.locked, staffOnly: staffOnly ?? this.staffOnly, players: players ?? this.players);
  bool hasPlayer(String playerId) => players.any((player) => player.playerId == playerId);
  LobbyPlayerLabel? player(String playerId) => players.where((p) => p.playerId == playerId).firstOrNull;
  Set<LobbyPermission> permissionsFor(String playerId) {
    final member = player(playerId);
    if (member == null) return const {};
    if (member.isStaff && staffOnly) return LobbyPermission.values.toSet();
    if (member.isLeader) return const {LobbyPermission.viewChat, LobbyPermission.sendChat, LobbyPermission.react, LobbyPermission.kick, LobbyPermission.lock, LobbyPermission.startGame};
    return const {LobbyPermission.viewChat, LobbyPermission.sendChat, LobbyPermission.react};
  }
}

class RadicalStaffDirectory {
  RadicalStaffDirectory._();
  static const members = [
    LobbyPlayerLabel(playerId: 'staff_01', playerName: 'رادیکال • مدیر', isStaff: true, rating: 9999),
    LobbyPlayerLabel(playerId: 'staff_02', playerName: 'رادیکال • ناظر', isStaff: true, rating: 9800),
    LobbyPlayerLabel(playerId: 'staff_03', playerName: 'رادیکال • پشتیبان', isStaff: true, rating: 9500),
  ];
  static bool isStaff(String playerId) => members.any((member) => member.playerId == playerId);
  static LobbyPlayerLabel? member(String playerId) => members.where((member) => member.playerId == playerId).firstOrNull;
}

class LobbyChatStore {
  LobbyChatStore._(); static final Map<String, List<LobbyMessage>> _messages = {};
  static List<LobbyMessage> messagesFor(String lobbyId) => List.unmodifiable(_messages[lobbyId] ?? const []);
  static void seed(String lobbyId, String ownerName) { if (_messages.containsKey(lobbyId)) return; _messages[lobbyId] = [LobbyMessage(id: '${lobbyId}_system_start', lobbyId: lobbyId, senderId: 'system', senderName: 'سیستم', text: '$ownerName لابی را ساخت.', sentAt: DateTime.now(), system: true)]; }
  static void add(LobbyMessage message) => _messages.putIfAbsent(message.lobbyId, () => <LobbyMessage>[]).add(message);
}

class RadicalDiamondDefinition {
  final DiamondType type; final String name; final String emoji; final Color primary; final Color secondary; final String usage;
  const RadicalDiamondDefinition({required this.type, required this.name, required this.emoji, required this.primary, required this.secondary, required this.usage});
}
class RadicalDiamonds {
  RadicalDiamonds._();
  static const all = [
    RadicalDiamondDefinition(type: DiamondType.blue, name: 'الماس معمولی', emoji: '💎', primary: Color(0xFF55A9FF), secondary: Color(0xFF9BD2FF), usage: 'خریدهای عادی و لابی‌های دوستانه'),
    RadicalDiamondDefinition(type: DiamondType.radical, name: 'الماس رادیکال', emoji: '◆', primary: Color(0xFF9A72D9), secondary: Color(0xFFFFDFA0), usage: 'لابی‌های امتیازی، VIP و سناریوهای ویژه'),
    RadicalDiamondDefinition(type: DiamondType.teen, name: 'الماس نوجوانان', emoji: '✦', primary: Color(0xFF62D89A), secondary: Color(0xFFBFE7D1), usage: 'فقط امکانات لابی نوجوانان'),
    RadicalDiamondDefinition(type: DiamondType.adult, name: 'الماس بزرگسالان', emoji: '◆', primary: Color(0xFFED4D67), secondary: Color(0xFFFFDFA0), usage: 'فقط امکانات لابی بزرگسالان'),
  ];
  static RadicalDiamondDefinition of(DiamondType type) => all.firstWhere((item) => item.type == type);
  static bool supports(LobbyCategory category, DiamondType type) => switch (category.mode) {
    LobbyMode.friendly => category.age == LobbyAge.teen ? type == DiamondType.teen : type == DiamondType.blue || type == DiamondType.adult,
    LobbyMode.ranked => type == DiamondType.radical || (category.age == LobbyAge.teen && type == DiamondType.teen) || (category.age == LobbyAge.adult && type == DiamondType.adult),
  };
}

class LobbyStoreItem { final String id; final String name; final int price; final DiamondType currency; final bool vip; const LobbyStoreItem({required this.id, required this.name, required this.price, required this.currency, this.vip = false}); }
class LobbyStoreCatalog {
  LobbyStoreCatalog._();
  static const regular = [LobbyStoreItem(id: 'avatar_basic', name: 'آواتار کلاسیک', price: 100, currency: DiamondType.blue), LobbyStoreItem(id: 'sticker_party', name: 'استیکر دورهمی', price: 50, currency: DiamondType.blue)];
  static const vip = [LobbyStoreItem(id: 'avatar_radical', name: 'آواتار رادیکال', price: 100, currency: DiamondType.radical, vip: true), LobbyStoreItem(id: 'lobby_vip', name: 'ورود VIP', price: 250, currency: DiamondType.radical, vip: true), LobbyStoreItem(id: 'scenario_special', name: 'سناریوی ویژه', price: 500, currency: DiamondType.radical, vip: true)];
}

extension _FirstOrNull<T> on Iterable<T> { T? get firstOrNull => isEmpty ? null : first; }
