import 'package:flutter/material.dart';

import 'custom_scenario_manager.dart';

class CustomScenarioScreen extends StatefulWidget {
  final String ownerId;

  const CustomScenarioScreen({
    super.key,
    required this.ownerId,
  });

  @override
  State<CustomScenarioScreen> createState() => _CustomScenarioScreenState();
}

class _CustomScenarioScreenState extends State<CustomScenarioScreen> {
  final _titleController = TextEditingController();
  final _roleController = TextEditingController();
  int _playerCount = 10;
  final List<String> _roles = <String>[];
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _syncDefaultRoles();
    DiamondManager.load().then((_) {
      if (mounted) setState(() {});
    });
  }

  void _syncDefaultRoles() {
    const defaults = ['مافیا', 'شهروند', 'دکتر', 'کارآگاه'];
    _roles
      ..clear()
      ..addAll(defaults);
    while (_roles.length < _playerCount) {
      _roles.add('شهروند');
    }
    if (_roles.length > _playerCount) {
      _roles.removeRange(_playerCount, _roles.length);
    }
  }

  void _changePlayerCount(int value) {
    setState(() {
      _playerCount = value;
      _syncDefaultRoles();
    });
  }

  Future<void> _create() async {
    if (_saving) return;
    setState(() => _saving = true);

    final scenario = await CustomScenarioManager.create(
      ownerId: widget.ownerId,
      title: _titleController.text,
      playerCount: _playerCount,
      roles: _roles,
    );

    if (!mounted) return;
    setState(() => _saving = false);

    if (scenario == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            DiamondManager.canCreateCustomScenario()
                ? 'اطلاعات سناریو کامل نیست.'
                : 'برای ساخت سناریوی دست‌ساز ۵۰ الماس لازم است.',
          ),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('سناریو ساخته شد و برای شما ذخیره شد.')),
    );
    Navigator.pop(context, scenario);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _roleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ساخت سناریوی دست‌ساز')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.diamond, color: Colors.cyanAccent),
              title: const Text('هزینه ساخت'),
              subtitle: Text('۵۰ الماس • دوستانه فقط'),
              trailing: Text('${DiamondManager.diamonds} 💎'),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'نام سناریو',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Expanded(child: Text('تعداد بازیکن')),
              DropdownButton<int>(
                value: _playerCount,
                items: [
                  for (int count = 6; count <= 20; count++)
                    DropdownMenuItem(
                      value: count,
                      child: Text('$count نفر'),
                    ),
                ],
                onChanged: (value) {
                  if (value != null) _changePlayerCount(value);
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Deck سناریو',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          for (int index = 0; index < _roles.length; index++)
            ListTile(
              dense: true,
              leading: CircleAvatar(child: Text('${index + 1}')),
              title: Text(_roles[index]),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () async {
                  _roleController.text = _roles[index];
                  final role = await showDialog<String>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('ویرایش نقش'),
                      content: TextField(
                        controller: _roleController,
                        autofocus: true,
                        decoration: const InputDecoration(
                          labelText: 'نام نقش',
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('لغو'),
                        ),
                        FilledButton(
                          onPressed: () =>
                              Navigator.pop(context, _roleController.text),
                          child: const Text('ثبت'),
                        ),
                      ],
                    ),
                  );
                  if (role != null && role.trim().isNotEmpty) {
                    setState(() => _roles[index] = role.trim());
                  }
                },
              ),
            ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: _saving ? null : _create,
            icon: const Icon(Icons.add_circle_outline),
            label: Text(_saving ? 'در حال ساخت...' : 'ساخت سناریو با ۵۰ 💎'),
          ),
          const SizedBox(height: 8),
          const Text(
            'سناریوی ساخته‌شده فقط برای سازنده ذخیره می‌شود و برای بازی‌های دوستانه قابل استفاده مجدد است.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white60),
          ),
        ],
      ),
    );
  }
}
