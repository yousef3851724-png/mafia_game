import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // بعد از ۲ ثانیه به صفحه بعد (خانه یا ستاپ) می‌رویم
    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        // فعلاً موقتاً از Navigator استفاده می‌کنیم تا GoRouter را در بخش بعدی تنظیم کنیم
        Navigator.pushReplacementNamed(context, '/home');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF1A1A1A), // پس‌زمینه تیره مافیایی
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_fire_department, color: Colors.red, size: 80),
            SizedBox(height: 20),
            Text(
              'Mafia Radical',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'در حال آماده‌سازی بازی...',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            SizedBox(height: 30),
            CircularProgressIndicator(color: Colors.red),
          ],
        ),
      ),
    );
  }
}
