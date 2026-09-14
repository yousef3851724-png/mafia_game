import 'package:flutter/material.dart';
import '../../core/widgets/radical_scaffold.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) => RadicalScaffold(appBar: AppBar(title: const Text('پروفایل')), padded: true, child: Column(children: const [CircleAvatar(radius: 42, backgroundColor: Color(0xFF211D16), child: Icon(Icons.person_rounded, color: Color(0xFFFFDFA0), size: 46)), SizedBox(height: 14), Text('بازیکن رادیکال', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)), SizedBox(height: 6), Text('هویت، آمار و تنظیمات بازیکن') ]));
}
