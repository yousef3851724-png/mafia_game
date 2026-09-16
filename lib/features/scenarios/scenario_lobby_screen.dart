import 'package:flutter/material.dart';

import '../../core/theme/radical_theme.dart';
import 'custom_scenario_system.dart';
import 'radical_game_screen.dart';
import 'scenario_catalog.dart';

class ScenarioLobbyScreen extends StatefulWidget {
  final String ownerId;
  const ScenarioLobbyScreen({super.key, this.ownerId = 'local_creator'});

  @override
  State<ScenarioLobbyScreen> createState() => _ScenarioLobbyScreenState();
}

class _ScenarioLobbyScreenState extends State<ScenarioLobbyScreen> {
  ScenarioMode _mode = ScenarioMode.friendly;
  String? _selectedScenarioId = 'classic';
  String? _selectedCustomId;
  int _playerCount = 10;
  List<CustomScenario> _customScenarios = const [];
  bool _loadingCustom = true;

  @override
  void initState() {
    super.initState();
    _loadCustomScenarios();
  }

  Future<void> _loadCustomScenarios() async {
    await DiamondManager.load();
    final items = await CustomScenarioStore.loadForOwner(widget.ownerId);
    if (!mounted) return;
    setState(() {
      _customScenarios = items;
      _loadingCustom = false;
    });
  }

  List<ScenarioDefinition> get _availableScenarios => ScenarioCatalog.forMode(_mode);

  ScenarioDefinition? get _selectedScenario {
    final id = _selectedScenarioId;
    if (id == null) return null;
    for (final scenario in _availableScenarios) {
      if (scenario.id == id) return scenario;
    }
    return ScenarioCatalog.byId(id);
  }

  CustomScenario? get _selectedCustom {
    final id = _selectedCustomId;
    if (id == null) return null;
    for (final item in _customScenarios) {
      if (item.id == id) return item;
    }
    return null;
  }

  void _setMode(ScenarioMode mode) {
    final scenarios = ScenarioCatalog.forMode(mode);
    setState(() {
      _mode = mode;
      _selectedScenarioId = scenarios.isEmpty ? null : scenarios.first.id;
    });
  }

  void _start() {
    final scenario = _selectedScenario;
    final custom = _selectedCustom;
    if (scenario == null && custom == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RadicalGameScreen(
          scenario: scenario,
          customScenario: custom,
          playerCount: _playerCount,
          mode: _mode,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: RadicalTheme.ink,
        appBar: AppBar(
          title: const Text('لابی رادیکال'),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
        ),
        body: Stack(
          children: [
            const Positioned.fill(child: _LobbyAtmosphere()),
            ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
              children: [
                _hero(),
                const SizedBox(height: 14),
                _modeCard(),
                const SizedBox(height: 12),
                _scenarioCard(),
                const SizedBox(height: 12),
                _playerCard(),
                const SizedBox(height: 12),
                _customCard(),
              ],
            ),
            _startBar(),
          ],
        ),
      ),
    );
  }

  Widget _hero() => Container(
        padding: const EdgeInsets.all(18),
        decoration: RadicalTheme.glass(accent: true, radius: 24),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadicalTheme.goldButtonGradient,
                boxShadow: RadicalTheme.goldGlow(blur: 20, opacity: .18),
              ),
              child: const Icon(Icons.local_fire_department_rounded, color: RadicalTheme.ink, size: 29),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('میز بعدی را بساز', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
                  SizedBox(height: 5),
                  Text('حالت، سناریو و ظرفیت را انتخاب کن؛ سپس وارد میز سینمایی رادیکال شو.', style: TextStyle(color: RadicalTheme.smoke, height: 1.4, fontSize: 11)),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _modeCard() => _section(
        title: 'حالت بازی',
        icon: Icons.emoji_events_outlined,
        child: Row(
          children: [
            Expanded(child: _modeButton(ScenarioMode.friendly, 'دوستانه', 'بدون فشار امتیازی', Icons.groups_rounded)),
            const SizedBox(width: 10),
            Expanded(child: _modeButton(ScenarioMode.ranked, 'امتیازی', 'رقابتی و رسمی', Icons.workspace_premium_rounded)),
          ],
        ),
      );

  Widget _modeButton(ScenarioMode mode, String title, String subtitle, IconData icon) {
    final selected = _mode == mode;
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => _setMode(mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          gradient: selected ? RadicalTheme.goldButtonGradient : null,
          color: selected ? null : RadicalTheme.panel2,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: selected ? RadicalTheme.gold : RadicalTheme.line),
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? RadicalTheme.ink : RadicalTheme.gold, size: 22),
            const SizedBox(width: 9),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: TextStyle(color: selected ? RadicalTheme.ink : Colors.white, fontWeight: FontWeight.w900)),
                const SizedBox(height: 3),
                Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: selected ? RadicalTheme.ink.withValues(alpha: .72) : RadicalTheme.smoke, fontSize: 9)),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _scenarioCard() => _section(
        title: 'سناریوی اصلی',
        icon: Icons.menu_book_rounded,
        child: DropdownButtonFormField<String>(
          value: _availableScenarios.any((s) => s.id == _selectedScenarioId) ? _selectedScenarioId : null,
          decoration: _inputDecoration('انتخاب سناریو'),
          dropdownColor: RadicalTheme.panel2,
          items: [
            for (final scenario in _availableScenarios)
              DropdownMenuItem(value: scenario.id, child: Text(scenario.title)),
          ],
          onChanged: (value) => setState(() {
            _selectedScenarioId = value;
            _selectedCustomId = null;
          }),
        ),
      );

  Widget _playerCard() => _section(
        title: 'ظرفیت میز',
        icon: Icons.groups_rounded,
        child: Column(
          children: [
            Row(children: [
              const Text('تعداد بازیکن', style: TextStyle(fontWeight: FontWeight.w800)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
                decoration: BoxDecoration(color: RadicalTheme.gold.withValues(alpha: .10), borderRadius: BorderRadius.circular(14), border: Border.all(color: RadicalTheme.gold.withValues(alpha: .25))),
                child: Text('$_playerCount نفر', style: const TextStyle(color: RadicalTheme.gold, fontWeight: FontWeight.w900)),
              ),
            ]),
            Slider(
              min: 6,
              max: 20,
              divisions: 14,
              value: _playerCount.toDouble(),
              activeColor: RadicalTheme.gold,
              inactiveColor: RadicalTheme.line,
              onChanged: (value) => setState(() => _playerCount = value.round()),
            ),
            const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('۶', style: TextStyle(color: RadicalTheme.smoke, fontSize: 10)),
              Text('۲۰', style: TextStyle(color: RadicalTheme.smoke, fontSize: 10)),
            ]),
          ],
        ),
      );

  Widget _customCard() => _section(
        title: 'سناریوی اختصاصی',
        icon: Icons.auto_awesome_rounded,
        trailing: _loadingCustom ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : null,
        child: _customScenarios.isEmpty
            ? const Text('سناریوی اختصاصی ذخیره‌شده‌ای برای این سازنده وجود ندارد. سناریوی اصلی انتخاب‌شده اجرا می‌شود.', style: TextStyle(color: RadicalTheme.smoke, fontSize: 11, height: 1.5))
            : DropdownButtonFormField<String>(
                value: _customScenarios.any((s) => s.id == _selectedCustomId) ? _selectedCustomId : null,
                decoration: _inputDecoration('اختیاری'),
                dropdownColor: RadicalTheme.panel2,
                items: [
                  for (final scenario in _customScenarios)
                    DropdownMenuItem(value: scenario.id, child: Text(scenario.name)),
                ],
                onChanged: (value) => setState(() => _selectedCustomId = value),
              ),
      );

  Widget _section({required String title, required IconData icon, required Widget child, Widget? trailing}) => Container(
        padding: const EdgeInsets.all(16),
        decoration: RadicalTheme.glass(radius: 22),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(icon, color: RadicalTheme.gold, size: 19),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
            const Spacer(),
            if (trailing != null) trailing,
          ]),
          const SizedBox(height: 13),
          child,
        ]),
      );

  InputDecoration _inputDecoration(String label) => InputDecoration(
        labelText: label,
        filled: true,
        fillColor: RadicalTheme.panel2,
        labelStyle: const TextStyle(color: RadicalTheme.smoke),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: RadicalTheme.line)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: RadicalTheme.line)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: RadicalTheme.gold)),
      );

  Widget _startBar() => Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          decoration: BoxDecoration(color: RadicalTheme.panel.withValues(alpha: .98), border: const Border(top: BorderSide(color: RadicalTheme.line)), boxShadow: const [BoxShadow(color: Color(0x77000000), blurRadius: 24, offset: Offset(0, -8))]),
          child: SafeArea(
            top: false,
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: (_selectedScenario == null && _selectedCustom == null) ? null : _start,
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Padding(padding: EdgeInsets.symmetric(vertical: 5), child: Text('ساخت میز و ورود به بازی')),
              ),
            ),
          ),
        ),
      );
}

class _LobbyAtmosphere extends StatelessWidget {
  const _LobbyAtmosphere();

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -.55),
            radius: 1.25,
            colors: [Color(0xFF1A1A26), RadicalTheme.ink],
          ),
        ),
      );
}
