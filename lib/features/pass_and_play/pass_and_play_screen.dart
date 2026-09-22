import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/scenario_catalog.dart';
import '../../router/app_router.dart';

class PassAndPlayScreen extends StatefulWidget {
  const PassAndPlayScreen({super.key});

  @override
  State<PassAndPlayScreen> createState() => _PassAndPlayScreenState();
}

class _PassAndPlayScreenState extends State<PassAndPlayScreen> {
  String _scenarioId = 'classic';
  int _playerCount = 6;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('بازی گروهی (یک گوشی)'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('انتخاب سناریو:', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            DropdownButton<String>(
              value: _scenarioId,
              isExpanded: true,
              items: ScenarioCatalog.allScenarios
                  .map((s) => DropdownMenuItem(
                        value: s.id,
                        child: Text(s.displayNameFa),
                      ))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _scenarioId = v);
              },
            ),
            const SizedBox(height: 24),
            Text('تعداد بازیکن: $_playerCount',
                style: const TextStyle(fontSize: 16)),
            Slider(
              value: _playerCount.toDouble(),
              min: 5,
              max: 15,
              divisions: 10,
              label: '$_playerCount',
              onChanged: (v) => setState(() => _playerCount = v.round()),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                context.push(
                  '/pass-and-play/game/$_scenarioId/$_playerCount',
                );
              },
              child: const Text('شروع بازی'),
            ),
          ],
        ),
      ),
    );
  }
}
