import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/radical_theme.dart';
import '../scenarios/realistic_avatar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _name = 'بازیکن رادیکال';
  String _avatar = 'شهروند مرد';
  int _level = 1;
  int _xp = 0;
  int _coins = 0;
  int _played = 0;
  int _won = 0;
  int _lost = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _name = prefs.getString('player_name') ?? 'بازیکن رادیکال';
      _avatar = prefs.getString('selected_avatar') ?? 'شهروند مرد';
      _level = prefs.getInt('player_level') ?? 1;
      _xp = prefs.getInt('player_xp') ?? 0;
      _coins = prefs.getInt('player_coins') ?? 0;
      _played = prefs.getInt('games_played') ?? 0;
      _won = prefs.getInt('games_won') ?? 0;
      _lost = prefs.getInt('games_lost') ?? 0;
    });
  }

  Future<void> _editName() async {
    final controller = TextEditingController(text: _name);
    final value = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('نام بازیکن'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 24,
          textDirection: TextDirection.rtl,
          decoration: const InputDecoration(hintText: 'نام خودت را وارد کن'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('انصراف')),
          FilledButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: const Text('ذخیره')),
        ],
      ),
    );
    controller.dispose();
    if (value == null || value.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('player_name', value);
    if (mounted) setState(() => _name = value);
  }

  @override
  Widget build(BuildContext context) {
    final requiredXp = 100 + ((_level - 1) * 50);
    final progress = (requiredXp <= 0 ? 0.0 : (_xp % requiredXp) / requiredXp).clamp(0.0, 1.0);
    final rate = _played == 0 ? 0 : ((_won / _played) * 100).round();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: RadicalScaffold(
        appBar: AppBar(title: const Text('پروفایل')),
        padded: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 30),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: RadicalTheme.glass(accent: true),
              child: Column(
                children: [
                  RealisticAvatar(role: _avatarRole(_avatar), female: _avatar.contains('زن'), size: 124),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(child: Text(_name, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w900))),
                      IconButton(onPressed: _editName, icon: const Icon(Icons.edit_rounded), tooltip: 'ویرایش نام'),
                    ],
                  ),
                  Text(_avatar, style: const TextStyle(color: RadicalTheme.smoke)),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(child: _InfoPill(icon: Icons.workspace_premium_rounded, label: 'سطح', value: '$_level')),
                      const SizedBox(width: 10),
                      Expanded(child: _InfoPill(icon: Icons.monetization_on_rounded, label: 'سکه', value: '$_coins')),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Align(alignment: Alignment.centerRight, child: Text('پیشرفت سطح • $_xp XP', style: const TextStyle(color: RadicalTheme.smoke, fontSize: 12))),
                  const SizedBox(height: 7),
                  ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(value: progress, minHeight: 8)),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const Text('آمار بازی', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(height: 10),
            Row(children: [
              _StatCard(title: 'بازی', value: '$_played'),
              const SizedBox(width: 9),
              _StatCard(title: 'برد', value: '$_won'),
              const SizedBox(width: 9),
              _StatCard(title: 'باخت', value: '$_lost'),
              const SizedBox(width: 9),
              _StatCard(title: 'نرخ برد', value: '$rate%'),
            ]),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(color: RadicalTheme.panel, borderRadius: BorderRadius.circular(22), border: Border.all(color: RadicalTheme.line)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('هویت رادیکال', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17)),
                const SizedBox(height: 8),
                const Text('آواتار، فریم، استیکر و آمار بازیکن در همین پروفایل مدیریت می‌شوند.', style: TextStyle(color: RadicalTheme.smoke, height: 1.45)),
                const SizedBox(height: 14),
                SizedBox(width: double.infinity, child: OutlinedButton.icon(onPressed: _editName, icon: const Icon(Icons.badge_outlined), label: const Text('ویرایش نام و هویت'))),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

String _avatarRole(String value) {
  if (value.contains('دلقک')) return 'دلقک';
  if (value.contains('جوکر')) return 'جوکر';
  if (value.contains('قاتل')) return 'قاتل مستقل';
  if (value.contains('زامبی')) return 'زامبی';
  if (value.contains('مافیا')) return 'مافیا';
  if (value.contains('پدر')) return 'پدرخوانده';
  if (value.contains('دکتر')) return 'دکتر';
  if (value.contains('کارآگاه')) return 'کارآگاه';
  return 'شهروند';
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoPill({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
    decoration: BoxDecoration(color: RadicalTheme.panel, borderRadius: BorderRadius.circular(16), border: Border.all(color: RadicalTheme.line)),
    child: Row(children: [Icon(icon, size: 20, color: RadicalTheme.goldBright), const SizedBox(width: 8), Text(label, style: const TextStyle(color: RadicalTheme.smoke, fontSize: 12)), const Spacer(), Text(value, style: const TextStyle(fontWeight: FontWeight.w900))]),
  );
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;

  const _StatCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 4),
      decoration: BoxDecoration(color: RadicalTheme.panel, borderRadius: BorderRadius.circular(16), border: Border.all(color: RadicalTheme.line)),
      child: Column(children: [Text(value, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: RadicalTheme.goldBright)), const SizedBox(height: 3), Text(title, style: const TextStyle(color: RadicalTheme.smoke, fontSize: 10))]),
    ),
  );
}
