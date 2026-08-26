   routerConfig بگذار.

2. **فایل اگر نام متغیرت چیز دیگری است، همان را بگذار.

2. **فایل `pubspec.yaml` یا workflow هنوز خراب است**
   - `pubspec.yaml` نباید هیچ YAML مربوط به GitHub Actions داشته باشد.
   - فایل workflow باید فقط داخل `.github/workflows/` باشد.

3. **خطای Dart داخل کد**
   - مثلاً یک import اشتباه، پرانتز ناقص، یا کلاس/ویجت تعریف‌نشده.

---

## برای اطمینان، این فایل حد ازلی `lib/app.dart` را بگذار
اگر می‌خواهی کد اپ را از نو و بدون ریسک تست کنی، فعلاً این را جایگزین کن:
```dart
import 'package:flutter/material.dart';

class MafiaRadicalApp extends StatelessWidget {
  const MafiaRadicalApp({super.key});

  @override
  Widget build(BuildContext context) {
return MaterialApp(
debugShowCheckedModeBanner: false,
title: 'مافیا رادیکال',
home: const Scaffold(
body: Center(
child: Text('Mafia Radical'),
),
),
);
  }
}
