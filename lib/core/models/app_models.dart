import 'package:flutter/foundation.dart';

enum AppTeam { city, mafia }

@immutable
class AppRole {
  final String id;
  final String name;
  final AppTeam team;
  final String description;
  final bool hasNightAction;

  const AppRole({
    required this.id,
    required this.name,
    required this.team,
    required this.description,
    required this.hasNightAction,
  });
}

const appRoles = <String, AppRole>{
  'مافیا': AppRole(id: 'mafia', name: 'مافیا', team: AppTeam.mafia, description: 'عضو تیم مافیا و دارای شلیک شبانه.', hasNightAction: true),
  'پدرخوانده': AppRole(id: 'godfather', name: 'پدرخوانده', team: AppTeam.mafia, description: 'رهبر مافیا و تصمیم‌گیر شلیک شبانه.', hasNightAction: true),
  'دکتر': AppRole(id: 'doctor', name: 'دکتر', team: AppTeam.city, description: 'هر شب یک بازیکن را نجات می‌دهد.', hasNightAction: true),
  'کارآگاه': AppRole(id: 'detective', name: 'کارآگاه', team: AppTeam.city, description: 'هر شب هویت یک بازیکن را استعلام می‌کند.', hasNightAction: true),
  'شهروند': AppRole(id: 'citizen', name: 'شهروند', team: AppTeam.city, description: 'در روز با تحلیل و رأی‌گیری به شهر کمک می‌کند.', hasNightAction: false),
  'جوکر': AppRole(id: 'joker', name: 'جوکر', team: AppTeam.city, description: 'نقش ویژه مستقل برای سناریوهای مدرن.', hasNightAction: false),
  'محافظ': AppRole(id: 'guard', name: 'محافظ', team: AppTeam.city, description: 'از یک بازیکن در شب محافظت می‌کند.', hasNightAction: true),
  'تکاور': AppRole(id: 'commando', name: 'تکاور', team: AppTeam.city, description: 'نقش ویژه شهروندی با قابلیت شبانه در سناریوی مربوط.', hasNightAction: true),
  'مذاکره': AppRole(id: 'negotiator', name: 'مذاکره', team: AppTeam.city, description: 'نقش ویژه سناریوی مذاکره.', hasNightAction: true),
  'بازپرس': AppRole(id: 'investigator', name: 'بازپرس', team: AppTeam.city, description: 'نقش تحقیقاتی سناریوی بازپرس.', hasNightAction: true),
};

AppRole roleForName(String name) {
  return appRoles[name] ?? AppRole(
    id: name,
    name: name,
    team: AppTeam.city,
    description: 'نقش ویژه سناریو.',
    hasNightAction: false,
  );
}

@immutable
class AvatarItem {
  final String id;
  final String name;
  final int priceDiamonds;
  final String assetPath;

  const AvatarItem({
    required this.id,
    required this.name,
    required this.priceDiamonds,
    required this.assetPath,
  });
}

@immutable
class Player {
  final String id;
  final String name;
  final AppRole role;
  final AvatarItem avatar;
  final bool alive;
  final int votesReceived;

  const Player({
    required this.id,
    required this.name,
    required this.role,
    required this.avatar,
    this.alive = true,
    this.votesReceived = 0,
  });

  Player copyWith({AppRole? role, AvatarItem? avatar, bool? alive, int? votesReceived}) {
    return Player(
      id: id,
      name: name,
      role: role ?? this.role,
      avatar: avatar ?? this.avatar,
      alive: alive ?? this.alive,
      votesReceived: votesReceived ?? this.votesReceived,
    );
  }
}
