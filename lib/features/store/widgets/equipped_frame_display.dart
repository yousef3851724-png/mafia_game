import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/radical_theme.dart';
import '../../core/widgets/radical_scaffold.dart';
import '../store/widgets/equipped_frame_display.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _name = 'بازیکن رادیکال';
  int _level = 1;

  @override
  Widget build(BuildContext context) {
    return RadicalScaffold(
      title: 'پروفایل',
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: RadicalTheme.ink.withOpacity(0.1),
                      border: Border.all(color: RadicalTheme.gold, width: 2),
                    ),
                    child: const Center(child: Icon(Icons.person, size: 50)),
                  ),
                  const SizedBox(height: 16),
                  Text(_name, style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: RadicalTheme.gold)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('فریم فعال', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: RadicalTheme.gold)),
                  const SizedBox(height: 16),
                  const Center(child: EquippedFrameDisplay(size: 120, showLabel: true)),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}