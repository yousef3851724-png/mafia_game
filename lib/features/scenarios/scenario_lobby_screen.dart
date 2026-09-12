import 'package:flutter/material.dart';

import 'custom_scenario_system.dart';
import 'scenario_catalog.dart';
import 'scenario_game_screen.dart';

class ScenarioLobbyScreen extends StatefulWidget {
  final String ownerId;

  const ScenarioLobbyScreen({
    super.key,
    required this.ownerId,
  });

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
    setState(() => _customScenarios = items);
  }

  List<ScenarioDefinition> get _availableScenarios =>
      ScenarioCatalog.forMode(_mode);

  ScenarioDefinition? get _selectedScenario =>
      _selectedScenarioId == null ? null : ScenarioCatalog.byId(_selectedScenarioId!);

  CustomScenario? get _selectedCustom => _selectedCustomId == null
      ? null
      : _customScenarios.where((item) => item.id == _selectedCustomId).firstOrNull;

  void _changeMode(ScenarioMode mode) {
    setState(() {
      _mode = mode;
      _selectedCustomId = null;
      final scenarios = ScenarioCatalog.forMode(mode);
      _selectedScenarioId = scenarios.isEmpty ? null : scenarios.first.id;
      if (_selectedScenario != null) {
        _playerCount = _selectedScenario!.minPlayers;
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
    if (created == null || !mounted) return;
    await _loadCustomScenarios();
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
          builder: (_) => ScenarioGameScreen(
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
        builder: (_) => ScenarioGameScreen(
          scenario: selected,
          mode: _mode,
          playerCount: _playerCount,
        ),
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selectedScenario;
    final custom = _selectedCustom;
    final minPlayers = custom?.playerCount ?? selected?.minPlayers ?? 6;
    final maxPlayers = custom?.playerCount ?? selected?.maxPlayers ?? 20;

    return Scaffold(
      appBar: AppBar(
        title: const Text('انتخاب سناریو و ساخت لابی'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Center(child: Text('💎 ${DiamondManager.balance}')),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ModeSelector(mode: _mode, onChanged: _changeMode),
          const SizedBox(height: 16),
          const Text('سناریوها', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ..._availableScenarios.map(_scenarioCard),
          const SizedBox(height: 8),
          _customBuilderCard(),
          if (_customScenarios.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text('سناریوهای دست‌ساز من', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ..._customScenarios.map(_customScenarioCard),
          ],
          const SizedBox(height: 20),
          if (custom != null)
            Card(
              child: ListTile(
                leading: const Icon(Icons.bookmark),
                title: Text(custom.name),
                subtitle: Text('${custom.playerCount} نفر • دوستانه • Deck اختصاصی'),
              ),
            )
          else if (selected != null) ...[
            Text('ظرفیت: ${selected.minPlayers} تا ${selected.maxPlayers} نفر'),
            if (selected.minPlayers != selected.maxPlayers)
              Slider(
                value: _playerCount.toDouble().clamp(
                  selected.minPlayers.toDouble(),
                  selected.maxPlayers.toDouble(),
                ),
                min: selected.minPlayers.toDouble(),
                max: selected.maxPlayers.toDouble(),
                divisions: selected.maxPlayers - selected.minPlayers,
                label: '$_playerCount نفر',
                onChanged: (value) => setState(() => _playerCount = value.round()),
              )
            else
              Text('تعداد ثابت: $_playerCount نفر'),
          ],
          if (_mode == ScenarioMode.ranked)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Text('🏆 امتیازی: فقط بازپرس، تکاور و مذاکره، دقیقاً ۱۰ نفره.'),
              ),
            ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _startGame,
            icon: const Icon(Icons.play_arrow),
            label: Text(custom == null ? 'ساخت لابی و شروع بازی' : 'شروع سناریوی دست‌ساز'),
          ),
        ],
      ),
    );
  }

  Widget _scenarioCard(ScenarioDefinition scenario) {
    final selected = _selectedScenarioId == scenario.id && _selectedCustomId == null;
    return Card(
      child: ListTile(
        selected: selected,
        leading: Icon(
          scenario.family == ScenarioFamily.modern ? Icons.auto_awesome : Icons.style,
        ),
        title: Text(scenario.title),
        subtitle: Text(scenario.description),
        trailing: Text('${scenario.minPlayers}-${scenario.maxPlayers}'),
        onTap: () => _selectScenario(scenario),
      ),
    );
  }

  Widget _customBuilderCard() {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.construction),
        title: const Text('ساخت سناریوی دست‌ساز'),
        subtitle: const Text('فقط دوستانه • هزینه ساخت: ۵۰ 💎 • ظرفیت ۶ تا ۲۰ نفر'),
        trailing: const Icon(Icons.chevron_left),
        onTap: _openCustomBuilder,
      ),
    );
  }

  Widget _customScenarioCard(CustomScenario scenario) {
    final selected = _selectedCustomId == scenario.id;
    return Card(
      child: ListTile(
        selected: selected,
        leading: const Icon(Icons.bookmark),
        title: Text(scenario.name),
        subtitle: Text('${scenario.playerCount} نفر • دوستانه • ذخیره‌شده برای شما'),
        onTap: () => _selectCustom(scenario),
      ),
    );
  }
}

class CustomScenarioBuilderScreen extends StatefulWidget {
  final String ownerId;

  const CustomScenarioBuilderScreen({
    super.key,
    required this.ownerId,
  });

  @override
  State<CustomScenarioBuilderScreen> createState() => _CustomScenarioBuilderScreenState();
}

class _CustomScenarioBuilderScreenState extends State<CustomScenarioBuilderScreen> {
  final _nameController = TextEditingController();
  int _playerCount = 10;
  late List<TextEditingController> _roleControllers;

  @override
  void initState() {
    super.initState();
    _roleControllers = List.generate(
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
      next.add(i < old.length ? old[i] : TextEditingController(text: 'شهروند'));
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
      roles: _roleControllers.map((controller) => controller.text).toList(),
    );

    if (!mounted) return;
    if (!success) {
      _show('ساخت سناریو انجام نشد؛ الماس شما کسر نشد.');
      return;
    }

    final items = await CustomScenarioStore.loadForOwner(widget.ownerId);
    final created = items.firstWhere(
      (item) => item.name == name,
      orElse: () => items.last,
    );
    Navigator.pop(context, created);
  }

  void _show(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ساخت سناریوی دست‌ساز')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('💎 هزینه ساخت: ۵۰ الماس'),
                  const SizedBox(height: 4),
                  Text('موجودی: ${DiamondManager.balance} الماس'),
                  const SizedBox(height: 8),
                  const Text('سناریوی دست‌ساز فقط در حالت دوستانه قابل استفاده است.'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'نام سناریو',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Text('تعداد بازیکن: $_playerCount'),
          Slider(
            value: _playerCount.toDouble(),
            min: 6,
            max: 20,
            divisions: 14,
            label: '$_playerCount',
            onChanged: (value) => _resizeRoles(value.round()),
          ),
          const SizedBox(height: 8),
          const Text('Deck نقش‌ها', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          for (int i = 0; i < _roleControllers.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: TextField(
                controller: _roleControllers[i],
                decoration: InputDecoration(
                  labelText: 'نقش ${i + 1}',
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _create,
            icon: const Icon(Icons.diamond),
            label: const Text('ساخت سناریو با ۵۰ الماس'),
          ),
        ],
      ),
    );
  }
}

class _ModeSelector extends StatelessWidget {
  final ScenarioMode mode;
  final ValueChanged<ScenarioMode> onChanged;

  const _ModeSelector({required this.mode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<ScenarioMode>(
      segments: const [
        ButtonSegment(
          value: ScenarioMode.friendly,
          icon: Icon(Icons.groups),
          label: Text('دوستانه'),
        ),
        ButtonSegment(
          value: ScenarioMode.ranked,
          icon: Icon(Icons.emoji_events),
          label: Text('امتیازی'),
        ),
      ],
      selected: {mode},
      onSelectionChanged: (value) => onChanged(value.first),
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
