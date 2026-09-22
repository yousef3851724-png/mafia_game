import 'package:flutter/material.dart';
import '../constants/app_theme.dart';

enum Team { mafia, citizen }

enum RoleType {
  godfather,
  simpleMafia,
  doctor,
  detective,
  sniper,
  simpleCitizen,
}

class Role {
  final RoleType type;
  final String nameFa;
  final Team team;
  final String description;
  final IconData icon;
  final Color color;

  const Role({
    required this.type,
    required this.nameFa,
    required this.team,
    required this.description,
    required this.icon,
    required this.color,
  });
}

const Map<RoleType, Role> kGameRoles = {
  RoleType.godfather: Role(
    type: RoleType.godfather,
    nameFa: 'پدرخوانده',
    team: Team.mafia,
    description: 'رئیس مافیا، استعلام او برای کارآگاه منفی است.',
    icon: Icons.security,
    color: AppColors.primaryRed,
  ),
  RoleType.simpleMafia: Role(
    type: RoleType.simpleMafia,
    nameFa: 'مافیای ساده',
    team: Team.mafia,
    description: 'عضو تیم مافیا و همراه در شلیک شب.',
    icon: Icons.theater_comedy,
    color: Color(0xFFFF5252),
  ),
  RoleType.doctor: Role(
    type: RoleType.doctor,
    nameFa: 'دکتر (پزشک)',
    team: Team.citizen,
    description: 'هر شب یک نفر را نجات می‌دهد.',
    icon: Icons.medical_services,
    color: AppColors.medicGreen,
  ),
  RoleType.detective: Role(
    type: RoleType.detective,
    nameFa: 'کارآگاه',
    team: Team.citizen,
    description: 'هر شب استعلام هویت یک نفر را می‌گیرد.',
    icon: Icons.search,
    color: AppColors.detectiveBlue,
  ),
  RoleType.sniper: Role(
    type: RoleType.sniper,
    nameFa: 'حرفه‌ای (اسنایپر)',
    team: Team.citizen,
    description: 'شلیک شب به مافیا؛ با تیر اشتباه خودش کشته می‌شود.',
    icon: Icons.crisis_alert,
    color: AppColors.goldYellow,
  ),
  RoleType.simpleCitizen: Role(
    type: RoleType.simpleCitizen,
    nameFa: 'شهروند ساده',
    team: Team.citizen,
    description: 'در فاز روز با تحلیل و رأی‌گیری به شهر کمک می‌کند.',
    icon: Icons.person,
    color: AppColors.accentCyan,
  ),
};

class Player {
  final String id;
  final String name;
  final Role role;
  bool isAlive;
  int votesReceived;

  Player({
    required this.id,
    required this.name,
    required this.role,
    this.isAlive = true,
    this.votesReceived = 0,
  });
}
