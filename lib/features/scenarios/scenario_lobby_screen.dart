import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('لابی سناریو')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          SegmentedButton<ScenarioMode>(
            segments: const [
              ButtonSegment(value: ScenarioMode.friendly, label: Text('دوستانه')),
              ButtonSegment(value: ScenarioMode.ranked, label: Text('امتیازی')),
            ],
            selected: {_mode},
            onSelectionChanged: (value) => setState(() {
              _mode = value.first;
              _selectedScenarioId = _availableScenarios.isEmpty ? null : _availableScenarios.first.id;
            }),
          ),
          const SizedBox(height: 18),
          Text('تعداد بازیکن: $_playerCount'),
          Slider(min: 6, max: 20, divisions: 14, value: _playerCount.toDouble(), onChanged: (value) => setState(() => _playerCount = value.round())),
          const SizedBox(height: 10),
          if (_availableScenarios.isNotEmpty)
            DropdownButtonFormField<String>(
              value: _selectedScenarioId,
              decoration: const InputDecoration(labelText: 'سناریو'),
              items: [for (final scenario in _availableScenarios) DropdownMenuItem(value: scenario.id, child: Text(scenario.title))],
              onChanged: (value) => setState(() => _selectedScenarioId = value),
            ),
          if (_customScenarios.isNotEmpty) ...[
            const SizedBox(height: 18),
            DropdownButtonFormField<String>(
              value: _selectedCustomId,
              decoration: const InputDecoration(labelText: 'سناریوی اختصاصی'),
              items: [for (final scenario in _customScenarios) DropdownMenuItem(value: scenario.id, child: Text(scenario.title))],
              onChanged: (value) => setState(() => _selectedCustomId = value),
            ),
          ],
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () {
              final scenario = _selectedScenario;
              final custom = _selectedCustom;
              if (scenario == null && custom == null) return;
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => RadicalGameScreen(scenario: scenario, customScenario: custom, playerCount: _playerCount)));
            },
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text('شروع بازی'),
          ),
        ],
      ),
    );
  }
}
