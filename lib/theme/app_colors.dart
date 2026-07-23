import 'package:flutter/material.dart';

/// پالت رنگی اپ - فضای تیره و دراماتیک متناسب با حس‌وحال بازی مافیا
class AppColors {
  AppColors._();

  static const Color background = Color(0xFF0D0B14);
  static const Color surface = Color(0xFF17141F);
  static const Color surfaceVariant = Color(0xFF211D2C);

  static const Color primary = Color(0xFFB3122E); // قرمز خونی مافیا
  static const Color primaryDark = Color(0xFF7A0C1F);
  static const Color secondary = Color(0xFFD4AF37); // طلایی
  static const Color accent = Color(0xFF6E4BC9); // بنفش مرموز

  static const Color mafiaColor = Color(0xFFB3122E);
  static const Color citizenColor = Color(0xFF2E7D5B);
  static const Color independentColor = Color(0xFFD4AF37);

  static const Color textPrimary = Color(0xFFF5F3F7);
  static const Color textSecondary = Color(0xFFA9A4B5);
  static const Color divider = Color(0xFF2C2838);

  static const Color success = Color(0xFF2E7D5B);
  static const Color error = Color(0xFFE53E3E);
  static const Color warning = Color(0xFFE0A526);

  static const LinearGradient nightGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0D0B14), Color(0xFF1B1730)],
  );

  static const LinearGradient bloodGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryDark, primary],
  );

  // ---------- وضعیت بازیکن دور میز ----------
  static const Color statusReady = Color(0xFF3FBF52); // نقطه سبز: آماده/زنده
  static const Color statusNotReady = Color(0xFFE23A3A); // نقطه قرمز: منتظر/حذف

  // ---------- اقتصاد درون‌برنامه‌ای ----------
  static const Color coinColor = Color(0xFFF0C75E);
  static const Color diamondColor = Color(0xFF4FC3F7);
  static const Color vipColor = Color(0xFFD4AF37);

  // ---------- قاب طلایی دور آواتار ----------
  static const LinearGradient goldFrameGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF7E08A), Color(0xFFC79A2E), Color(0xFF8C6A16)],
  );

  static const LinearGradient goldButtonGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFFC79A2E), Color(0xFFF0C75E), Color(0xFFC79A2E)],
  );

  // ---------- برچسب تیم/کلن (رنگ متغیر بر اساس نقش) ----------
  static const Color teamMafiaTag = Color(0xFF7A0C1F);
  static const Color teamCitizenTag = Color(0xFF1F4E42);
  static const Color teamNightTag = Color(0xFF1F3B5C);
  static const Color teamDarkFamilyTag = Color(0xFF4B2E7A);

  static const Color panelBackground = Color(0xCC0D0B14); // پنل نیمه‌شفاف چت
  static const Color inputFill = Color(0xFF1C1826);
}
