# 🐺 Mafia Radical

اپلیکیشن Flutter برای اجرای حرفه‌ای بازی مافیا، مدیریت لابی، تخصیص نقش، جریان شب/روز، رأی‌گیری و نمایش نتیجه بازی.

**Current release:** `1.0.0+3`

## وضعیت نسخه نهایی

- ✅ Home → Scenario → Game flow
- ✅ تخصیص نقش واقعاً تصادفی
- ✅ Leader و Radical Staff روی میز
- ✅ چیدمان پایدار تا ۲۰ بازیکن
- ✅ Game Engine برای شب، روز، رأی‌گیری و برد
- ✅ تست‌های Flutter و تحلیل CI
- ✅ Android launcher branding
- ✅ Production signing workflow جداگانه و امن

---

## 🧱 ساختار پروژه

```text
mafia_game/
├── .github/
│   └── workflows/
│       ├── build.yml
│       ├── integrate-scenario-lobby.yml
│       └── release.yml
├── android/
│   ├── app/
│   │   ├── build.gradle.kts
│   │   └── src/
│   │       ├── debug/AndroidManifest.xml
│   │       └── main/
│   │           ├── AndroidManifest.xml
│   │           ├── kotlin/com/yousef/mafia_radical/MainActivity.kt
│   │           └── res/
│   │               ├── drawable/
│   │               ├── drawable-v21/
│   │               └── mipmap-{mdpi,hdpi,xhdpi,xxhdpi,xxxhdpi}/
│   └── ... Flutter/Gradle project files
├── assets/
│   └── images/
├── lib/
│   ├── main.dart
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_assets.dart
│   │   │   ├── app_theme.dart
│   │   │   └── frame_catalog.dart
│   │   ├── game_manager.dart
│   │   ├── models/
│   │   │   ├── app_models.dart
│   │   │   └── game_models.dart
│   │   ├── theme/
│   │   │   └── radical_theme.dart
│   │   └── widgets/
│   │       ├── avatar_frame_widget.dart
│   │       ├── branding/
│   │       └── frames/
│   ├── database/
│   └── features/
│       ├── cosmetics/
│       ├── game/
│       │   ├── data/
│       │   ├── domain/
│       │   ├── presentation/
│       │   ├── game_engine.dart
│       │   ├── game_module.dart
│       │   ├── game_state.dart
│       │   └── player_avatar.dart
│       ├── gameplay/
│       ├── home/
│       ├── lobbies/
│       ├── lobby/
│       ├── pass_and_play/
│       ├── scenarios/
│       ├── setup/
│       ├── store/
│       └── victory/
├── scripts/
│   └── setup_game_feature.sh
├── .gitignore
├── .metadata
├── analysis_options.yaml
├── BUILD_RELEASE_TRIGGER.md
├── BUILD_RELEASE_TRIGGER_2.md
├── CHANGELOG.md
├── pubspec.yaml
└── README.md
```

### نقش فایل‌های کلیدی

| مسیر | مسئولیت |
|---|---|
| `lib/main.dart` | bootstrap برنامه، `ProviderScope`، Theme و Home screen |
| `lib/core/constants/app_assets.dart` | مسیرها و ثابت‌های asset |
| `lib/core/constants/app_theme.dart` | رنگ‌ها و ثابت‌های بصری پایه |
| `lib/core/constants/frame_catalog.dart` | کاتالوگ فریم‌های آواتار |
| `lib/core/models/app_models.dart` | مدل‌های عمومی اپ، تیم، سن، label و wallet |
| `lib/core/models/game_models.dart` | مدل‌های بازی، Player، Role و Team |
| `lib/core/game_manager.dart` | هماهنگ‌کننده سطح بالای جریان بازی |
| `lib/core/theme/radical_theme.dart` | Material theme و visual system اصلی |
| `lib/core/widgets/avatar_frame_widget.dart` | رندر آواتار و frame |
| `lib/features/game/game_engine.dart` | قوانین و عملیات اصلی Game Engine |
| `lib/features/game/game_state.dart` | state و transitionهای بازی |
| `lib/features/game/game_module.dart` | wiring/module مربوط به Game feature |
| `lib/features/game/player_avatar.dart` | نمایش avatar بازیکن در Game feature |
| `lib/features/game/domain/` | entity و serviceهای domain؛ شامل engine دامنه |
| `lib/features/game/data/` | لایه data/repository برای Game feature |
| `lib/features/game/presentation/` | screen و widgetهای UI مربوط به بازی |
| `lib/features/home/` | صفحه Home و شروع جریان بازی |
| `lib/features/scenarios/` | انتخاب و نمایش سناریوها و عناصر مرتبط |
| `lib/features/setup/` | تنظیم بازیکنان و شروع session |
| `lib/features/pass_and_play/` | نمایش امن نقش‌ها به بازیکنان در حالت pass-and-play |
| `lib/features/lobbies/` | state و سیستم لابی/برچسب‌ها/اقتصاد لابی |
| `lib/features/lobby/` | اجزای جریان لابی |
| `lib/features/gameplay/` | اجزای gameplay presentation/logic |
| `lib/features/victory/` | نمایش تیم/نتیجه برنده |
| `lib/features/cosmetics/` | قابلیت‌های ظاهری و cosmetics |
| `lib/features/store/` | بخش فروشگاه |
| `lib/database/` | زیرساخت ذخیره‌سازی database |
| `assets/images/` | تصاویر و assetهای اپ |
| `android/app/build.gradle.kts` | Android application config، versioning و release signing |
| `.github/workflows/build.yml` | CI: analyze، test، build APK و provenance |
| `.github/workflows/integrate-scenario-lobby.yml` | CI integration سناریو/لابی |
| `.github/workflows/release.yml` | production signed APK + signature verification + GitHub Release |
| `pubspec.yaml` | package name، version، dependencies و asset/icon/splash config |
| `CHANGELOG.md` | تاریخچه release |

> ساختار واقعی repository مبناست؛ README صرفاً معماری فرضی نیست. پوشه‌های `data/`, `domain/` و `presentation/` به‌صورت feature-oriented نگه‌داری شده‌اند تا رشد پروژه بدون مخلوط شدن UI و منطق بازی ممکن باشد.

---

## 🎮 جریان اصلی بازی

```text
Home
  ↓
Scenario Selection
  ↓
Setup / Lobby
  ↓
Random Role Assignment
  ↓
Game Table
  ↓
Night → Day → Voting → Resolution
  ↓
Victory
```

تخصیص نقش تصادفی است؛ قرار گرفتن چند بازیکن Mafia در صندلی‌های مجاور یک نتیجه معتبر تصادفی است و به معنی الگوی ثابت نیست.

---

## 🧪 اجرای محلی

### پیش‌نیازها

- Flutter stable
- Dart مطابق constraint موجود در `pubspec.yaml`
- Java 17
- Android SDK
- Android SDK/Gradle سازگار با نسخه Flutter نصب‌شده

### نصب dependencyها

```bash
flutter pub get
```

### تحلیل

```bash
flutter analyze --no-fatal-infos --no-fatal-warnings
```

### تست

```bash
flutter test
```

### اجرای توسعه‌ای

```bash
flutter run
```

### ساخت APK تست/CI

```bash
flutter build apk --release
```

خروجی:

```text
build/app/outputs/flutter-apk/app-release.apk
```

---

## 📦 Release Android

نسخه فعلی:

```text
versionName: 1.0.0
versionCode: 4
```

آیکون از `assets/images/app_icon.png` تولید می‌شود و تنظیمات launcher/splash در `pubspec.yaml` قرار دارد. Android همچنین resourceهای launcher تولیدشده را در `android/app/src/main/res/` نگه می‌دارد.

### امضای production

کلید release نباید داخل repository قرار بگیرد. workflow تولیدی از چهار GitHub Actions secret استفاده می‌کند:

```text
MAFIA_RELEASE_KEYSTORE_BASE64
MAFIA_RELEASE_STORE_PASSWORD
MAFIA_RELEASE_KEY_ALIAS
MAFIA_RELEASE_KEY_PASSWORD
```

سپس:

1. keystore فقط داخل runner ساخته می‌شود.
2. `android/key.properties` موقت ساخته می‌شود.
3. APK با release keystore build می‌شود.
4. `apksigner verify --verbose` اجرا می‌شود.
5. provenance attestation تولید می‌شود.
6. APK به GitHub Release متصل به tag منتشر می‌شود.
7. فایل‌های حساس در پایان job حذف می‌شوند.

برای release واقعی، tag را به شکل زیر ایجاد کنید:

```bash
git tag v1.0.0
git push origin v1.0.0
```

یا در GitHub از مسیر `Actions → Production Android Release → Run workflow`
آن را روی tag انتشار اجرا کنید. اجرای دستی روی branch عادی برای انتشار توصیه
نمی‌شود؛ ref انتخاب‌شده باید همان tag نسخه باشد.

**نکته امنیتی:** keystore، password و `key.properties` نباید commit شوند.
کلیدها و passwordهایی که قبلاً در این workspace وجود داشته‌اند افشاشده فرض
می‌شوند؛ پیش از انتشار باید در Google Play و GitHub Actions چرخش (rotate) شوند.

---

## 🔐 CI

`build.yml` برای هر push به `main` این مراحل را اجرا می‌کند:

1. Checkout
2. Java 17
3. Flutter stable
4. `flutter doctor`
5. `flutter pub get`
6. `flutter analyze`
7. `flutter test`
8. یک APK release با امضای debug فقط برای اعتبارسنجی build می‌سازد
9. وجود APK اعتبارسنجی را بررسی می‌کند

این APK برای توزیع نیست. فقط `release.yml` با secrets تولیدی مجاز به انتشار است.

برای production signing از `release.yml` استفاده می‌شود؛ این دو مسیر عمداً جدا هستند تا CI معمولی به secret release key وابسته نباشد.

---

## 🧭 نسخه‌های آینده

مواردی مثل authentication آنلاین، matchmaking، economy سروری، ranked/season backend، AI assistant و همگام‌سازی چنددستگاهی در معماری README قدیمی پروژه مطرح شده بودند، اما نباید با قابلیت‌های فعلی APK اشتباه گرفته شوند. این موارد **planned/future** هستند مگر اینکه در کد جاری پیاده‌سازی شده باشند.

---

## 📄 License

مجوز پروژه و مجوز استفاده از assetها باید پیش از انتشار عمومی در فایل `LICENSE`
و مستندات مربوط به assetها به‌صورت صریح ثبت شود. در وضعیت فعلی، انتشار عمومی
بدون تعیین مجوز یک گیت انتشارِ باز است.
