import 'package:flutter/foundation.dart';

enum AppTeam { city, mafia }
enum PlayerAge { teen, adult }
enum PlayerLabel { leader, radicalStaff, radicalLobby, professionals, newcomers, vip }
enum DiamondType { blue, radical, teen, adult }

@immutable
class DiamondWallet {
  final int blue;
  final int radical;
  final int teen;
  final int adult;
  const DiamondWallet({this.blue = 0, this.radical = 0, this.teen = 0, this.adult = 0});
  int balance(DiamondType type) => switch (type) { DiamondType.blue => blue, DiamondType.radical => radical, DiamondType.teen => teen, DiamondType.adult => adult };
  DiamondWallet add(DiamondType type, int amount) => copyWith(type, balance(type) + amount);
  DiamondWallet spend(DiamondType type, int amount) => balance(type) < amount ? this : copyWith(type, balance(type) - amount);
  bool canSpend(DiamondType type, int amount) => amount >= 0 && balance(type) >= amount;
  DiamondWallet copyWith(DiamondType type, int value) => switch (type) { DiamondType.blue => DiamondWallet(blue: value, radical: radical, teen: teen, adult: adult), DiamondType.radical => DiamondWallet(blue: blue, radical: value, teen: teen, adult: adult), DiamondType.teen => DiamondWallet(blue: blue, radical: radical, teen: value, adult: adult), DiamondType.adult => DiamondWallet(blue: blue, radical: radical, teen: teen, adult: value) };
}

@immutable
class PlayerLabels {
  final Set<PlayerLabel> values;
  const PlayerLabels([this.values = const {}]);
  bool has(PlayerLabel label) => values.contains(label);
  PlayerLabels add(PlayerLabel label) => PlayerLabels({...values, label});
  PlayerLabels remove(PlayerLabel label) => PlayerLabels({...values}..remove(label));
}

@immutable
class AppRole {
  final String id;
  final String name;
  final AppTeam team;
  final String description;
  final bool hasNightAction;
  final bool teenAllowed;
  final bool adultOnly;
  const AppRole({required this.id, required this.name, required this.team, required this.description, required this.hasNightAction, this.teenAllowed = true, this.adultOnly = false});
}

const appRoles = <String, AppRole>{
  'مافیا': AppRole(id: 'mafia', name: 'مافیا', team: AppTeam.mafia, description: 'عضو تیم مافیا و دارای شلیک شبانه.', hasNightAction: true),
  'پدرخوانده': AppRole(id: 'godfather', name: 'پدرخوانده', team: AppTeam.mafia, description: 'رهبر مافیا و تصمیم‌گیر شلیک شبانه.', hasNightAction: true),
  'دکتر': AppRole(id: 'doctor', name: 'دکتر', team: AppTeam.city, description: 'هر شب یک بازیکن را نجات می‌دهد.', hasNightAction: true),
  'کارآگاه': AppRole(id: 'detective', name: 'کارآگاه', team: AppTeam.city, description: 'هر شب هویت یک بازیکن را استعلام می‌کند.', hasNightAction: true),
  'شهروند': AppRole(id: 'citizen', name: 'شهروند', team: AppTeam.city, description: 'در روز با تحلیل و رأی‌گیری به شهر کمک می‌کند.', hasNightAction: false),
  'جوکر': AppRole(id: 'joker', name: 'جوکر', team: AppTeam.city, description: 'نقش ویژه مستقل برای سناریوهای مدرن.', hasNightAction: false),
  'محافظ': AppRole(id: 'guard', name: 'محافظ', team: AppTeam.city, description: 'از یک بازیکن در شب محافظت می‌کند.', hasNightAction: true),
  'تکاور': AppRole(id: 'commando', name: 'تکاور', team: AppTeam.city, description: 'نقش ویژه شهروندی با قابلیت شبانه.', hasNightAction: true),
  'مذاکره': AppRole(id: 'negotiator', name: 'مذاکره', team: AppTeam.city, description: 'نقش ویژه سناریوی مذاکره.', hasNightAction: true),
  'بازپرس': AppRole(id: 'investigator', name: 'بازپرس', team: AppTeam.city, description: 'نقش تحقیقاتی سناریوی بازپرس.', hasNightAction: true),
};

AppRole roleForName(String name) => appRoles[name] ?? AppRole(id: name, name: name, team: AppTeam.city, description: 'نقش ویژه سناریو.', hasNightAction: false);

@immutable
class AvatarItem {
  final String id;
  final String name;
  final int priceDiamonds;
  final String assetPath;
  final DiamondType currency;
  final bool vipOnly;
  const AvatarItem({required this.id, required this.name, required this.priceDiamonds, required this.assetPath, this.currency = DiamondType.blue, this.vipOnly = false});
}

@immutable
class Player {
  final String id;
  final String name;
  final AppRole role;
  final AvatarItem avatar;
  final bool alive;
  final int votesReceived;
  final PlayerAge age;
  final PlayerLabels labels;
  final DiamondWallet wallet;
  final int rating;
  final String league;

  const Player({required this.id, required this.name, required this.role, required this.avatar, this.alive = true, this.votesReceived = 0, this.age = PlayerAge.adult, this.labels = const PlayerLabels(), this.wallet = const DiamondWallet(), this.rating = 0, this.league = 'Bronze'});
  bool get isLeader => labels.has(PlayerLabel.leader);
  bool get isRadicalStaff => labels.has(PlayerLabel.radicalStaff);
  bool get isVip => labels.has(PlayerLabel.vip);
  Player copyWith({AppRole? role, AvatarItem? avatar, bool? alive, int? votesReceived, PlayerAge? age, PlayerLabels? labels, DiamondWallet? wallet, int? rating, String? league}) => Player(id: id, name: name, role: role ?? this.role, avatar: avatar ?? this.avatar, alive: alive ?? this.alive, votesReceived: votesReceived ?? this.votesReceived, age: age ?? this.age, labels: labels ?? this.labels, wallet: wallet ?? this.wallet, rating: rating ?? this.rating, league: league ?? this.league);
}
