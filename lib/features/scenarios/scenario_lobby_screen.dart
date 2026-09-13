import 'package:flutter/material.dart';

import 'custom_scenario_system.dart';
import 'radical_game_screen.dart';
import 'scenario_catalog.dart';

class ScenarioLobbyScreen extends StatefulWidget {
  final String ownerId;
  const ScenarioLobbyScreen({super.key, required this.ownerId});

  @override
  State<ScenarioLobbyScreen> createState() => _ScenarioLobbyScreenState();
}

class _ScenarioLobbyScreenState extends State<ScenarioLobbyScreen> {
  ScenarioMode _mode = ScenarioMode.friendly;
  String? _selectedScenarioId = 'classic';
  String? _selectedCustomId;
  int _playerCount = 10;
  List<CustomScenario> _customScenarios = const [];

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
    });
  }

  List<ScenarioDefinition> get _availableScenarios => ScenarioCatalog.forMode(_mode);

  ScenarioDefinition? get _selectedScenario {
    final id = _selectedScenarioId;
    return id == null ? null : ScenarioCatalog.byId(id);
  }

  CustomScenario? get _selectedCustom {
    final id = _selectedCustomId;
    if (id == null) return null;
    for (final item in _customScenarios) {
      if (item.id == id) return item;
    }
    return null;
  }

  void _changeMode(ScenarioMode mode) {
    final scenarios = ScenarioCatalog.forMode(mode);
    setState(() {
      _mode = mode;
      _selectedCustomId = null;
      _selectedScenarioId = scenarios.isEmpty ? null : scenarios.first.id;
      if (scenarios.isNotEmpty) {
        _playerCount = scenarios.first.minPlayers;
      }
    });
  }

  Future<void> _openCustomBuilder() async {
    final created = await Navigator.push<CustomScenario>(
      context,
      MaterialPageRoute(
        builder: (_) => CustomScenarioBuilderScreen(ownerId: widget.ownerId),
      ),
    );
    if (!mounted || created == null) return;
    await _loadCustomScenarios();
    if (!mounted) return;
    setState(() {
      _mode = ScenarioMode.friendly;
      _selectedScenarioId = null;
      _selectedCustomId = created.id;
      _playerCount = created.playerCount;
    });
  }

  void _selectScenario(ScenarioDefinition scenario) {
    setState(() {
      _selectedCustomId = null;
      _selectedScenarioId = scenario.id;
      _playerCount = scenario.minPlayers;
    });
  }

  void _selectCustom(CustomScenario scenario) {
    setState(() {
      _mode = ScenarioMode.friendly;
      _selectedScenarioId = null;
      _selectedCustomId = scenario.id;
      _playerCount = scenario.playerCount;
    });
  }

  void _startGame() {
    final custom = _selectedCustom;
    final selected = _selectedScenario;
    if (custom == null && selected == null) {
      _showMessage('ابتدا یک سناریو انتخاب کنید.');
      return;
    }

    if (custom != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RadicalGameScreen(
            customScenario: custom,
            mode: ScenarioMode.friendly,
            playerCount: custom.playerCount,
          ),
        ),
      );
      return;
    }

    if (!ScenarioCatalog.canStart(
      scenarioId: selected!.id,
      mode: _mode,
      playerCount: _playerCount,
    )) {
      _showMessage('تعداد بازیکن با ظرفیت این سناریو هماهنگ نیست.');
      return;
    }

    if (_mode == ScenarioMode.ranked && _playerCount != 10) {
      _showMessage('بازی امتیازی دقیقاً ۱۰ نفره است.');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RadicalGameScreen(
          scenario: selected,
          mode: _mode,
          playerCount: _playerCount,
        ),
      ),
    );
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selectedScenario;
    final custom = _selectedCustom;
    final count = custom?.playerCount ?? _playerCount;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF07090F),
        appBar: AppBar(
          title: const Text(
            'انتخاب سناریو و ساخت لابی',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          actions: [
            Container(
              margin: const EdgeInsets.only(left: 14, top: 10, bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF171B25),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  '💎 ${DiamondManager.balance}',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
          children: [
            _LobbyHero(mode: _mode, onMode: _changeMode),
            const SizedBox(height: 22),
            const Text(
              'سناریوها',
              style: TextStyle(fontSize: 23, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 5),
            const Text(
              'سبک بازی خودت را انتخاب کن؛ هر سناریو قوانین و نقش‌های مخصوص دارد.',
              style: TextStyle(color: Color(0x99FFFFFF)),
            ),
            const SizedBox(height: 14),
            for (final scenario in _availableScenarios) _scenarioCard(scenario),
            const SizedBox(height: 8),
            _customBuilderCard(),
            if (_customScenarios.isNotEmpty) ...[
              const SizedBox(height: 20),
              const Text(
                'سناریوهای دست‌ساز من',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),
              for (final scenario in _customScenarios)
                _customScenarioCard(scenario),
            ],
            const SizedBox(height: 20),
            if (custom != null)
              _SelectedPanel(
                title: custom.name,
                subtitle: '${custom.playerCount} نفر • دوستانه • Deck اختصاصی',
                icon: Icons.bookmark_rounded,
              )
            else if (selected != null) ...[
              _SelectedPanel(
                title: selected.title,
                subtitle:
                    '${selected.minPlayers} تا ${selected.maxPlayers} نفر • ${_mode == ScenarioMode.ranked ? 'امتیازی' : 'دوستانه'}',
                icon: Icons.verified_rounded,
              ),
              const SizedBox(height: 12),
              if (selected.minPlayers != selected.maxPlayers) ...[
                Row(
                  children: [
                    const Icon(
                      Icons.groups_rounded,
                      size: 20,
                      color: Color(0xFFE3B873),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'تعداد بازیکن: $count',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
                Slider(
                  value: _playerCount
                      .toDouble()
                      .clamp(selected.minPlayers.toDouble(), selected.maxPlayers.toDouble()),
                  min: selected.minPlayers.toDouble(),
                  max: selected.maxPlayers.toDouble(),
                  divisions: selected.maxPlayers - selected.minPlayers,
                  label: '$_playerCount نفر',
                  onChanged: (value) {
                    setState(() {
                      _playerCount = value.round();
                    });
                  },
                ),
              ] else
                Text(
                  'تعداد ثابت: $_playerCount نفر',
                  style: const TextStyle(color: Color(0xB3FFFFFF)),
                ),
            ],
            if (_mode == ScenarioMode.ranked)
              const Padding(
                padding: EdgeInsets.only(top: 12),
                child: _RankedInfo(),
              ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _startGame,
              icon: const Icon(Icons.play_arrow_rounded),
              label: Padding(
                padding: const EdgeInsets.symmetric(vertical: 7),
                child: Text(
                  custom == null ? 'ساخت لابی و شروع بازی' : 'شروع سناریوی دست‌ساز',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _scenarioCard(ScenarioDefinition scenario) {
    final selected = _selectedScenarioId == scenario.id && _selectedCustomId == null;
    final modern = scenario.family == ScenarioFamily.modern;

    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Material(
        color: selected ? const Color(0xFF211D16) : const Color(0xFF10141D),
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          onTap: () => _selectScenario(scenario),
          borderRadius: BorderRadius.circular(22),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: selected ? const Color(0xFFE3B873) : const Color(0x1AFFFFFF),
                width: selected ? 1.4 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: LinearGradient(
                      colors: modern
                          ? const [Color(0xFF3A2430), Color(0xFF171C28)]
                          : const [Color(0xFF332D20), Color(0xFF151821)],
                    ),
                  ),
                  child: Icon(
                    modern ? Icons.auto_awesome_rounded : Icons.style_rounded,
                    color: selected ? const Color(0xFFE3B873) : const Color(0xB3FFFFFF),
                    size: 29,
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              scenario.title,
                              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
                            ),
                          ),
                          if (selected)
                            const Icon(
                              Icons.check_circle_rounded,
                              color: Color(0xFFE3B873),
                              size: 20,
                            ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        scenario.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Color(0x99FFFFFF), height: 1.35),
                      ),
                      const SizedBox(height: 9),
                      Wrap(
                        spacing: 7,
                        children: [
                          _Pill('${scenario.minPlayers}-${scenario.maxPlayers} نفر', Icons.groups_rounded),
                          _Pill(
                            modern ? 'مدرن' : 'کلاسیک',
                            modern ? Icons.bolt_rounded : Icons.local_police_outlined,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _customBuilderCard() {
    return Material(
      color: const Color(0xFF16131D),
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: _openCustomBuilder,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0x553F365A)),
          ),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: const Color(0x332C2450),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: const Icon(Icons.auto_fix_high_rounded, color: Color(0xFFD9B7FF), size: 28),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ساخت سناریوی دست‌ساز', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                    SizedBox(height: 4),
                    Text('۵۰ 💎 • دوستانه • ظرفیت ۶ تا ۲۰ نفر', style: TextStyle(color: Color(0x99FFFFFF))),
                  ],
                ),
              ),
              const Icon(Icons.chevron_left_rounded, color: Color(0x99FFFFFF)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _customScenarioCard(CustomScenario scenario) {
    final selected = _selectedCustomId == scenario.id;
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: selected ? const Color(0xFFE3B873) : const Color(0x1AFFFFFF),
          ),
        ),
        tileColor: selected ? const Color(0xFF211D16) : const Color(0xFF10141D),
        leading: const Icon(Icons.bookmark_rounded, color: Color(0xFFE3B873)),
        title: Text(scenario.name, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text('${scenario.playerCount} نفر • دوستانه • ذخیره‌شده برای شما'),
        trailing: selected ? const Icon(Icons.check_circle, color: Color(0xFFE3B873)) : null,
        onTap: () => _selectCustom(scenario),
      ),
    );
  }
}

class _LobbyHero extends StatelessWidget {
  final ScenarioMode mode;
  final ValueChanged<ScenarioMode> onMode;

  const _LobbyHero({required this.mode, required this.onMode});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFF30241A), Color(0xFF171A25), Color(0xFF10131B)],
        ),
        border: Border.all(color: Color(0x44E3B873)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🎭 اتاق عملیات', style: TextStyle(color: Color(0xFFE3B873), fontWeight: FontWeight.w900, fontSize: 13)),
          const SizedBox(height: 8),
          const Text('سناریوت را انتخاب کن\nو میز بازی را بچین.', style: TextStyle(fontSize: 27, fontWeight: FontWeight.w900, height: 1.12)),
          const SizedBox(height: 8),
          const Text('هر تصمیم تو، مسیر بازی را تغییر می‌دهد.', style: TextStyle(color: Color(0x99FFFFFF))),
          const SizedBox(height: 18),
          SegmentedButton<ScenarioMode>(
            segments: const [
              ButtonSegment(value: ScenarioMode.friendly, icon: Icon(Icons.groups_rounded), label: Text('دوستانه')),
              ButtonSegment(value: ScenarioMode.ranked, icon: Icon(Icons.emoji_events_rounded), label: Text('امتیازی')),
            ],
            selected: {mode},
            onSelectionChanged: (values) => onMode(values.first),
          ),
        ],
      ),
    );
  }
}

class _SelectedPanel extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _SelectedPanel({required this.title, required this.subtitle, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF121720),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x44E3B873)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: const Color(0x22E3B873), borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, color: const Color(0xFFE3B873)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('انتخاب فعلی', style: TextStyle(color: Color(0x99FFFFFF), fontSize: 11)),
                const SizedBox(height: 2),
                Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17)),
                const SizedBox(height: 3),
                Text(subtitle, style: const TextStyle(color: Color(0x99FFFFFF))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RankedInfo extends StatelessWidget {
  const _RankedInfo();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0x221F6A52),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x3347C99A)),
      ),
      child: const Row(
        children: [
          Icon(Icons.emoji_events_rounded, color: Color(0xFF6FE0B6)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'امتیازی: این حالت دقیقاً ۱۰ نفره است و برای رقابت رتبه‌ای طراحی شده.',
              style: TextStyle(color: Color(0xB3FFFFFF), height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  final IconData icon;

  const _Pill(this.text, this.icon);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.055),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(width: 1),
          Icon(icon, size: 13, color: Color(0x99FFFFFF)),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(fontSize: 11, color: Color(0x99FFFFFF), fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class CustomScenarioBuilderScreen extends StatefulWidget {
  final String ownerId;

  const CustomScenarioBuilderScreen({super.key, required this.ownerId});

  @override
  State<CustomScenarioBuilderScreen> createState() => _CustomScenarioBuilderScreenState();
}

class _CustomScenarioBuilderScreenState extends State<CustomScenarioBuilderScreen> {
  final TextEditingController _nameController = TextEditingController();
  int _playerCount = 10;
  late List<TextEditingController> _roleControllers;

  @override
  void initState() {
    super.initState();
    _roleControllers = List<TextEditingController>.generate(
      _playerCount,
      (_) => TextEditingController(text: 'شهروند'),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    for (final controller in _roleControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _resizeRoles(int count) {
    final old = _roleControllers;
    final next = <TextEditingController>[];

    for (int i = 0; i < count; i++) {
      if (i < old.length) {
        next.add(old[i]);
      } else {
        next.add(TextEditingController(text: 'شهروند'));
      }
    }

    for (int i = count; i < old.length; i++) {
      old[i].dispose();
    }

    setState(() {
      _playerCount = count;
      _roleControllers = next;
    });
  }

  Future<void> _create() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _show('نام سناریو را وارد کنید.');
      return;
    }
    if (!DiamondManager.canCreateCustomScenario()) {
      _show('برای ساخت سناریوی دست‌ساز حداقل ۵۰ الماس لازم است.');
      return;
    }

    final success = await CustomScenarioStore.create(
      ownerId: widget.ownerId,
      name: name,
      playerCount: _playerCount,
      roles: _roleControllers.map((controller) => controller.text.trim()).toList(),
    );

    if (!mounted) return;
    if (!success) {
      _show('ساخت سناریو انجام نشد؛ الماس شما کسر نشد.');
      return;
    }

    final items = await CustomScenarioStore.loadForOwner(widget.ownerId);
    if (!mounted) return;

    CustomScenario? created;
    for (final item in items) {
      if (item.name == name) {
        created = item;
        break;
      }
    }

    if (created == null && items.isNotEmpty) {
      created = items.last;
    }

    if (created == null) {
      _show('سناریو ساخته شد اما بازیابی آن ناموفق بود.');
      return;
    }

    Navigator.pop(context, created);
  }

  void _show(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF07090F),
        appBar: AppBar(
          title: const Text('ساخت سناریوی دست‌ساز', style: TextStyle(fontWeight: FontWeight.w900)),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(17),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: const LinearGradient(colors: [Color(0xFF2D2119), Color(0xFF141821)]),
                border: Border.all(color: Color(0x44E3B873)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('💎 ۵۰ الماس برای ساخت', style: TextStyle(color: Color(0xFFE3B873), fontWeight: FontWeight.w900)),
                  SizedBox(height: 6),
                  Text('سناریوی اختصاصی خودت را بساز و نقش‌ها را خودت بچین.', style: TextStyle(color: Color(0x99FFFFFF))),
                ],
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'نام سناریو', prefixIcon: Icon(Icons.edit_rounded)),
            ),
            const SizedBox(height: 18),
            Text('تعداد بازیکن: $_playerCount', style: const TextStyle(fontWeight: FontWeight.w800)),
            Slider(
              value: _playerCount.toDouble(),
              min: 6,
              max: 20,
              divisions: 14,
              label: '$_playerCount',
              onChanged: (value) => _resizeRoles(value.round()),
            ),
            const SizedBox(height: 8),
            const Text('Deck نقش‌ها', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            for (int i = 0; i < _roleControllers.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: TextField(
                  controller: _roleControllers[i],
                  decoration: InputDecoration(
                    labelText: 'نقش ${i + 1}',
                    prefixIcon: const Icon(Icons.badge_outlined),
                  ),
                ),
              ),
            const SizedBox(height: 10),
            FilledButton.icon(
              onPressed: _create,
              icon: const Icon(Icons.diamond_rounded),
              label: const Padding(
                padding: EdgeInsets.symmetric(vertical: 6),
                child: Text('ساخت سناریو با ۵۰ الماس'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
