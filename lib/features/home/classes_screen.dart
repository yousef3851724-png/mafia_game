import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/radical_theme.dart';
import '../../core/theme/radical_colors.dart';
import '../lobbies/lobby_hub_screen.dart';
import '../scenario/scenario_selection_screen.dart';

class ClassesScreen extends ConsumerWidget {
  const ClassesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: RadicalColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: RadicalColors.surfaceDark,
        elevation: 0,
        centerTitle: true,
        title: const Text('کلاس‌های نبرد مافیا', style: TextStyle(color: RadicalColors.goldAccent, fontWeight: FontWeight.bold)),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: RadicalColors.goldAccent), onPressed: () => Navigator.of(context).pop()),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              Text('حالت بازی مورد نظر خود را انتخاب کنید', textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 14)),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: [
                    _buildCard(context, 'بازی دوستانه', 'ورود سریع به لابی‌های فعال، گفتگو و بازی آزاد', Icons.groups_rounded, const Color(0xFF1E88E5), () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LobbyHubScreen(ownerId: 'local_creator')))),
                    const SizedBox(height: 12),
                    _buildCard(context, 'رقابتی رنکد (Ranked)', 'ثبت امتیاز، ارتقای رتبه و نبرد با حرفه‌ای‌ها', Icons.military_tech_rounded, RadicalColors.goldAccent, () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LobbyHubScreen(ownerId: 'local_creator')))),
                    const SizedBox(height: 12),
                    _buildCard(context, 'سناریوهای اختصاصی', 'پدرخوانده، شب مافیا، بازپرس و سناریوهای دست‌ساز', Icons.auto_stories_rounded, RadicalColors.crimsonPrimary, () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ScenarioSelectionScreen()))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext ctx, String title, String sub, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: RadicalColors.surfaceDark, borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withValues(alpha: 0.4))),
        child: Row(children: [Icon(icon, color: color, size: 32), const SizedBox(width: 16), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)), Text(sub, style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12))])), Icon(Icons.arrow_forward_ios_rounded, color: color, size: 16)]),
      ),
    );
  }
}
