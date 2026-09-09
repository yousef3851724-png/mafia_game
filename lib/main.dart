import 'package:flutter/material.dart';

void main() => runApp(const MafiaLobby());

class MafiaLobby extends StatelessWidget {
  const MafiaLobby({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'مایفا رادیکال',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0a0e14),
        primaryColor: const Color(0xFFd4af87),
      ),
      home: const LobbyScreen(),
    );
  }
}

class LobbyScreen extends StatefulWidget {
  const LobbyScreen({super.key});

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  String selectedRole = 'citizen';
  final List<Map<String, dynamic>> roles = [
    {'label': '👤 شهروند', 'value': 'citizen'},
    {'label': '💉 دکتر', 'value': 'doctor'},
    {'label': '🔍 کارآگاه', 'value': 'detective'},
    {'label': '🔪 مافیا', 'value': 'mafia'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // برچسب VPN
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green[700],
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Text(
                  '🔒 ۱۰۰٪ VPN',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ),
              const SizedBox(height: 16),
              // عنوان
              const Text(
                'مایفا رادیکال',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFd4af87),
                ),
              ),
              const Text(
                'به بازی مافیا خوش آمدید!',
                style: TextStyle(fontSize: 18, color: Color(0xFFaab)),
              ),
              const SizedBox(height: 30),
              // انتخاب نقش
              const Text(
                '🎭 نقش خود را انتخاب کنید',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFd4af87)),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: roles.map((role) {
                  return ChoiceChip(
                    label: Text(role['label']!),
                    selected: selectedRole == role['value'],
                    onSelected: (sel) {
                      setState(() {
                        selectedRole = role['value']!;
                      });
                    },
                    backgroundColor: const Color(0xFF2a3448),
                    selectedColor: const Color(0xFFd4af87),
                    labelStyle: TextStyle(
                      color: selectedRole == role['value'] ? Colors.black : Colors.white,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 30),
              // دکمه شروع
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // فعلاً پیغام بده
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('شروع بازی با نقش ${selectedRole}'),
                        backgroundColor: const Color(0xFFd4af87),
                      ),
                    );
                    // بعداً می‌تونی منطق بازی رو اینجا اضافه کنی
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFd4af87),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(60),
                    ),
                    textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  child: const Text('▶ شروع بازی'),
                ),
              ),
              const SizedBox(height: 20),
              // وضعیت نمایشی (فعلاً خالی)
              const Expanded(
                child: Center(
                  child: Text(
                    '⏳ منتظر شروع بازی...',
                    style: TextStyle(color: Color(0xFF8892a8)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}