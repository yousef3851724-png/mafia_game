import 'package:flutter/material.dart';

import 'custom_scenario_system.dart';
import 'scenario_catalog.dart';

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

  List<ScenarioDefinition> get _availableScenarios =>
      ScenarioCatalog.forMode(_mode);

  ScenarioDefinition? get _selectedScenario =>
      ScenarioCatalog.byId(_selectedScenarioId ?? '');

  void _changeMode(ScenarioMode mode) {
    setState(() {
      _mode = mode;
      final scenarios = ScenarioCatalog.forMode(mode);
      _selectedScenarioId = scenarios.isEmpty ? null : scenarios.first.id;
      if (_selectedScenario?.minPlayers != null) {
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
      _selectedScenarioId = 'custom_${created.id}';
      _playerCount = created.playerCount;
    });
  }

  void _startLobby() {
    final selected = _selectedScenario;
    final isCustom = selected == null &&
        _customScenarios.any((item) => 'custom_${item.id}' == _selectedScenarioId);

    if (!isCustom && selected == null) {
      _showMessage('ابتدا یک سناریو انتخاب کنید.');
      return;
    }

    if (!isCustom &&
        !ScenarioCatalog.canStart(
          scenarioId: selected!.id,
          mode: _mode,
          playerCount: _playerCount,
        )) {
      _showMessage('تعداد بازیکن با ظرفیت این سناریو هماهنگ نیست.');
      return;
    }

    if (_mode == ScenarioMode.ranked && _playerCount != 10) {
      _showMessage('تمام بازی‌های امتیازی دقیقاً ۱۰ نفره هستند.');
      return;
    }

    _showMessage(
      'لابی آماده شد: ${isCustom ? 'سناریوی دست‌ساز' : selected!.title} | $_playerCount نفر | ${_mode == ScenarioMode.ranked ? 'امتیازی' : 'دوستانه'}',
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selectedScenario;

    return Scaffold(
      appBar: AppBar(
        title: const Text('انتخاب سناریو و ساخت لابی'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Center(
              child: Text('💎 ${DiamondManager.balance}'),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ModeSelector(mode: _mode, onChanged: _changeMode),
          const SizedBox(height: 16),
          const Text(
            'سناریوها',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ..._availableScenarios.map(_scenarioCard),
          const SizedBox(height: 8),
          _customBuilderCard(),
          if (_customScenarios.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              'سناریوهای دست‌ساز من',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ..._customScenarios.map(_customScenarioCard),
          ],
          const SizedBox(height: 20),
          if (selected != null) ...[
            Text('ظرفیت: ${selected.minPlayers} تا ${selected.maxPlayers} نفر'),
            Slider(
              value: _playerCount.toDouble().clamp(
                    selected.minPlayers.toDouble(),
                    selected.maxPlayers.toDouble(),
                  ),
              min: selected.minPlayers.toDouble(),
              max: selected.maxPlayers.toDouble(),
              divisions: selected.maxPlayers - selected.minPlayers,
              label: '$_playerCount نفر',
              onChanged: (value) => setState(() {
                _playerCount = value.round();
              }),
            ),
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
            onPressed: _startLobby,
            icon: const Icon(Icons.play_arrow),
            label: const Text('ساخت و ورود به لابی'),
          ),
        ],
      ),
    );
  }

  Widget _scenarioCard(ScenarioDefinition scenario) {
    final selected = _selectedScenarioId == scenario.id;
    return Card(
      child: ListTile(
        selected: selected,
        leading: Icon(
          scenario.family == ScenarioFamily.modern
              ? Icons.auto_awesome
              : Icons.style,
        ),
        title: Text(scenario.title),
        subtitle: Text(scenario.description),
        trailing: Text('${scenario.minPlayers}-${scenario.maxPlayers}'),
        onTap: () => setState(() {
          _selectedScenarioId = scenario.id;
          _playerCount = scenario.minPlayers;
        }),
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
    final selected = _selectedScenarioId == 'custom_${scenario.id}';
    return Card(
      child: ListTile(
        selected: selected,
        leading: const Icon(Icons.bookmark),
        title: Text(scenario.name),
        subtitle: Text('${scenario.playerCount} نفر • دوستانه • ذخیره‌شده برای شما'),
        onTap: () => setState(() {
          _selectedScenarioId = 'custom_${scenario.id}';
          _playerCount = scenario.playerCount;
        }),
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
  State<CustomScenarioBuilderScreen> createState() =>
      _CustomScenarioBuilderScreenState();
}

class _CustomScenarioBuilderScreenState
    extends State<CustomScenarioBuilderScreen> {
  final _nameController = TextEditingController();
  int _playerCount = 10;
  late List<String> _roles;

  @override
  void initState() {
    super.initState();
    _roles = List<String>.filled(_playerCount, 'شهروند');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _resizeRoles(int count) {
    final next = List<String>.from(_roles);
    if (next.length < count) {
      next.addAll(List<String>.filled(count - next.length, 'شهروند'));
    } else {
      next.removeRange(count, next.length);
    }
    setState(() {
      _playerCount = count;
      _roles = next;
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

    final before = DiamondManager.balance;
    final success = await CustomScenarioStore.create(
      ownerId: widget.ownerId,
      name: name,
      playerCount: _playerCount,
      roles: _roles,
    );

    if (!mounted) return;
    if (success) {
      final items = await CustomScenarioStore.loadForOwner(widget.ownerId);
      final created = items.isNotEmpty
          ? items.last
          : CustomScenario(
              id: '',
              ownerId: widget.ownerId,
              name: name,
              playerCount: _playerCount,
              roles: List<String>.from(_roles),
              createdAt: DateTime.now(),
            );
      _show('سناریو ساخته شد و ۵۰ الماس از $before به ${DiamondManager.balance} رسید.');
      Navigator.pop(context, created);
    } else {
      _show('ساخت سناریو انجام نشد؛ الماس شما کسر نشد.');
    }
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
                  const SizedBox(height: 12),
                  const Text('این سناریو فقط در حالت دوستانه قابل استفاده است.'),
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
          const Text(
            'Deck نقش‌ها',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          for (int i = 0; i < _roles.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: TextField(
                controller: TextEditingController(text: _roles[i]),
                decoration: InputDecoration(
                  labelText: 'نقش ${i + 1}',
                  border: const OutlineInputBorder(),
                ),
                onChanged: (value) => _roles[i] = value,
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
