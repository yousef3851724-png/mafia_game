import 'package:flutter/material.dart';

import '../../core/theme/radical_theme.dart';
import '../lobbies/lobby_hub_screen.dart';
import '../lobbies/lobby_domain.dart';

class ClassesScreen extends StatelessWidget {
  const ClassesScreen({super.key});

  void _open(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const LobbyHubScreen(ownerId: 'local_creator'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const categories = <LobbyCategory>[
      LobbyCatalog.friendlyTeen,
      LobbyCatalog.friendlyAdult,
      LobbyCatalog.rankedTeen,
      LobbyCatalog.rankedAdult,
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: RadicalTheme.ink,
        appBar: AppBar(
          backgroundColor: RadicalTheme.panel,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'کلاس‌های نبرد مافیا',
            style: TextStyle(
              color: RadicalTheme.goldBright,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: RadicalTheme.goldBright),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
            children: [
              const Text(
                'نوع لابی را دقیق انتخاب کن',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: RadicalTheme.goldBright,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'دوستانه و امتیازی، هرکدام با تفکیک کامل نوجوان و بزرگسال.',
                textAlign: TextAlign.center,
                style: TextStyle(color: RadicalTheme.smoke, fontSize: 12),
              ),
              const SizedBox(height: 18),
              for (final category in categories) ...[
                _buildCard(
                  title: category.title,
                  sub: category.description,
                  icon: category.isRanked ? Icons.emoji_events_rounded : Icons.groups_rounded,
                  color: category.primary,
                  ageLabel: category.isAdult ? '۱۸+' : 'زیر ۱۸',
                  modeLabel: category.isRanked ? 'امتیازی' : 'دوستانه',
                  onTap: _open,
                ),
                const SizedBox(height: 12),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required String sub,
    required IconData icon,
    required Color color,
    required String ageLabel,
    required String modeLabel,
    required void Function(BuildContext) onTap,
  }) {
    return Builder(
      builder: (context) => Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onTap(context),
          borderRadius: BorderRadius.circular(20),
          child: Ink(
            padding: const EdgeInsets.all(17),
            decoration: BoxDecoration(
              color: RadicalTheme.panel,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withValues(alpha: .42)),
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        sub,
                        style: const TextStyle(
                          color: RadicalTheme.smoke,
                          fontSize: 11,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _Tag(label: modeLabel, color: color),
                          const SizedBox(width: 6),
                          _Tag(label: ageLabel, color: color),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, color: color, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color color;
  const _Tag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w900),
      ),
    );
  }
}
