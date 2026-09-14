import 'package:flutter/material.dart';
import '../../core/widgets/radical_scaffold.dart';

class StoreScreen extends StatelessWidget {
  const StoreScreen({super.key});

  @override
  Widget build(BuildContext context) => RadicalScaffold(
        appBar: AppBar(title: const Text('فروشگاه')),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: ListView(
          children: const [
            Text('فروشگاه رادیکال', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
            SizedBox(height: 8),
            Text('آواتار، استیکر و آیتم‌های ویژه'),
            SizedBox(height: 20),
            _StoreItem(title: 'آواتار رادیکال', icon: Icons.person_rounded),
            _StoreItem(title: 'پک استیکر', icon: Icons.emoji_emotions_rounded),
            _StoreItem(title: 'آیتم VIP', icon: Icons.workspace_premium_rounded),
          ],
        ),
      );
}

class _StoreItem extends StatelessWidget {
  final String title;
  final IconData icon;
  const _StoreItem({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) => Card(
        child: ListTile(
          leading: const Icon(Icons.person_rounded, color: Color(0xFFE3B873)),
          title: Text(title),
          trailing: const Icon(Icons.chevron_left_rounded),
        ),
      );
}
