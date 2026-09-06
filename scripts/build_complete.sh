#!/bin/bash
set -e

echo "=========================================="
echo "  شروع فرآیند ساخت کامل پروژه مافیا  "
echo "=========================================="

# ۱. رفتن به پوشه‌ی پروژه (اگه توش نیستی)
cd ~/mafia_game

# ۲. پاکسازی کش قبلی
echo ">>> پاکسازی کش..."
flutter clean

# ۳. دریافت وابستگی‌ها
echo ">>> دریافت وابستگی‌ها..."
flutter pub get

# ۴. تحلیل کد (بررسی خطاهای احتمالی)
echo ">>> تحلیل کد..."
flutter analyze

# ۵. ساخت APK نهایی (Release)
echo ">>> ساخت APK نهایی..."
flutter build apk --release

# ۶. کپی APK به پوشه‌ی Downloads گوشی
APK_PATH="build/app/outputs/flutter-apk/app-release.apk"
DEST_PATH="/sdcard/Download/mafia_game.apk"
if [ -f "$APK_PATH" ]; then
    cp "$APK_PATH" "$DEST_PATH"
    echo "✅ APK با موفقیت به مسیر زیر کپی شد:"
    echo "   $DEST_PATH"
else
    echo "❌ خطا: فایل APK ساخته نشد!"
    exit 1
fi

# ۷. نمایش پیام نهایی
echo "=========================================="
echo "  ساخت کامل شد! فایل APK آماده‌ی نصب است."
echo "  می‌توانید آن را از پوشه‌ی Downloads نصب کنید."
echo "=========================================="
