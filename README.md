# 🎭 مافیا رادیکال (Mafia Radical)

اپلیکیشن موبایل اندروید برای اجرای بازی مافیا رادیکال — نسخه‌ی «گرداننده هوشمند»:
به‌جای کارت‌های فیزیکی، این اپ نقش‌ها را مدیریت می‌کند، فازهای شب/روز را با تایمر
پیش می‌برد، رأی‌گیری را انجام می‌دهد و نتیجه نهایی را اعلام می‌کند.

## 📦 وضعیت پروژه

این پروژه به‌صورت مرحله‌ای (Section به Section) ساخته می‌شود:

- ✅ **Section-01 — زیرساخت پروژه** (همین بخش): پیکربندی، تم، دیتابیس، storage،
  روتینگ، DI، لاگر.
- ⏳ **Section-02** (بعدی): مدل‌های داده (Player، Role، GameSession)، منطق
  تخصیص نقش‌ها، Riverpod Providers.
- ⏳ **Section-03**: صفحات UI (Splash، Home، Setup، Role Reveal).
- ⏳ **Section-04**: منطق فاز شب/روز/رأی‌گیری + تایمر + صدا/ویبره.
- ⏳ **Section-05**: صفحه نتیجه، تاریخچه بازی‌ها، راهنمای نقش‌ها، تنظیمات.
- ⏳ **Section-06**: آماده‌سازی نهایی انتشار (آیکون، Splash Screen، امضای
  اپ، build APK/AAB برای Google Play).

## 🛠 پیش‌نیازها

- Flutter SDK نسخه 3.22 یا بالاتر (`flutter --version`)
- Android Studio (برای SDK و شبیه‌ساز/دستگاه واقعی)
- یک دستگاه اندروید یا امولاتور با API 23 به بالا

## 🚀 راه‌اندازی

```bash
# 1. نصب پکیج‌ها
flutter pub get

# 2. اجرای اپ روی دستگاه/امولاتور متصل
flutter run

# 3. ساخت خروجی نهایی برای انتشار (بعد از تکمیل همه Sectionها)
flutter build apk --release
# یا برای Google Play:
flutter build appbundle --release
```

## 📁 ساختار پروژه (Section-01)

```
lib/
├── main.dart                     # نقطه ورود اپ
├── app.dart                      # ویجت ریشه (MaterialApp.router)
├── core/
│   ├── constants/                # ثابت‌های عمومی و قوانین بازی
│   ├── utils/                    # extensionها و validatorها
│   └── errors/                   # Exception و Failure classes
├── config/                       # پیکربندی محیط اجرا (dev/prod)
├── router/                       # مسیریابی با go_router
├── theme/                        # رنگ، فونت، تم تاریک
├── database/                     # SQLite (sqflite) برای تاریخچه بازی‌ها
├── storage/                      # SharedPreferences + Secure Storage
├── logger/                       # لاگر مرکزی
└── dependency_injection/         # get_it container
```

## 🎨 هویت بصری

فضای تیره و دراماتیک (قرمز خونی + طلایی + بنفش مرموز)، فونت فارسی
Vazirmatn، و پشتیبانی کامل راست‌به‌چپ (RTL).

> ⚠️ نکته: فونت‌های Vazirmatn باید از
> [این لینک رسمی](https://github.com/rastikerdar/vazirmatn/releases) دانلود
> و در `assets/fonts/` قرار بگیرند (فایل‌های Regular، Medium، Bold).
> همچنین آیکون اپ (`app_icon.png`) و لوگوی اسپلش باید در `assets/images/`
> قرار داده شوند تا `flutter_launcher_icons` و `flutter_native_splash`
> بتوانند آن‌ها را پردازش کنند.

## 📝 لایسنس

این پروژه برای استفاده شخصی/تجاری شما ساخته شده است.
