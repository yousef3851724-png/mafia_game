<<<<<<< HEAD
cd ~/mafia_game && cat << 'EOF' > README.md
# 🎭 Mafia Radical (AI-Powered)

یک پلتفرم مدرن و بلادرنگ برای بازی گروهی مافیا با مدیریت خودکار هوش مصنوعی، رابط کاربری تاریک و تعاملی.

---

## 🌟 ویژگی‌های کلیدی

- 🤖 **AI Game Master:** مدیریت کامل سناریوها، شمارش آرا، مدیریت زمان شب/روز و راوی خودکار مبتنی بر هوش مصنوعی.
- ⚡ **Realtime Engine:** ارتباط پایدار با تأخیر نزدیک به صفر بر بستر Socket.io و Node.js.
- 🎨 **Modern Dark UI:** تم اختصاصی Cyberpunk/Dark با فریم‌های متحرک آواتار و جلوه‌های نوری نئونی.
- 🛡️ **Clean Architecture:** ساختار ماژولار و تفکیک‌شده لایه‌ها در فلاتر (Router, Storage, DI, Features).

---

## 🏗️ جریان منطقی بازی (Game Flow)

\`\`\`mermaid
flowchart TD
    subgraph Client [کلاینت فلاتر - Flutter Client]
        A([شروع بازی / لابی]) --> B[GameTableScreen: چیدمان میز و صندلی‌ها]
        B --> C{بررسی فاز جاری بازی}
        
        C -->|فاز شب| D[Night Action: کنش‌های شبانه نقش‌ها]
        C -->|فاز روز / گفت‌وگو| E[Day Discussion: تایمر نوبت و چت]
        C -->|فاز رأی‌گیری| F[Voting Phase: ثبت رأی خروج / دفاعیه]
    end

    subgraph Server_and_AI [سرور و هوش مصنوعی]
        D -->|ارسال انتخاب‌ها با سوکت| Srv[سرور مرکزی Socket.io]
        E -->|پایان زمان گفت‌وگو| Srv
        F -->|شمارش آرا| Srv
        
        Srv --> AI[AI Game Master / Narrator]
        AI -->|تولید روایت سناریو و اعلام نتایج شب| Srv
        Srv -->|پخش وضعیت جدید GameState| B
    end

    subgraph State_Check [پایان بازی]
        Srv --> Check{آیا شرط برد محقق شد؟}
        Check -->|تعداد مافیا = شهروند| MWin[برد مافیا 🔴]
        Check -->|تمام مافیاها حذف شدند| CWin[برد شهروند 🟢]
        Check -->|خیر| C
    end
\`\`\`

---

## 🌳 نقشه ساختار پروژه (Project Architecture)

\`\`\`text
mafia_game/
│
├── .github/
│   └── workflows/
│       └── flutter_ci.yml             # پایپ‌لاین CI/CD
│
├── assets/
│   ├── animations/                    # انیمیشن‌های Lottie و Rive
│   ├── audio/                         # افکت‌های صوتی گوینده و اتمسفر شب
│   └── frames/                        # تکسچر و اسپرایت‌های فریم‌های اختصاصی
│
├── lib/
│   ├── main.dart                      # نقطه ورود برنامه
│   │
│   ├── core/                          # هسته مشترک
│   │   ├── constants/
│   │   │   ├── app_colors.dart        # پالت رنگ نئونی و تم تاریک
│   │   │   └── frame_catalog.dart     # کاتالوگ فریم‌های آواتار
│   │   ├── network/
│   │   │   └── socket_client.dart     # کلاینت ارتباط بلادرنگ
│   │   └── widgets/
│   │       ├── branding/
│   │       │   └── game_logo_widget.dart   # لوگوی متحرک
│   │       └── frames/
│   │           └── animated_avatar_frame.dart # فریم انیمیشنی دور آواتار
│   │
│   └── features/                      # معماری بر اساس قابلیت (Feature-First)
│       ├── ai_master/                 # ماژول راوی و قضاوت هوش مصنوعی
│       ├── cosmetics/                 # ویترین فریم‌ها و سفارشی‌سازی
│       └── game/                      # لاجیک و صفحات اصلی بازی
│           ├── domain/entities/
│           │   └── game_models.dart   # انام‌های نقش‌ها، تیم‌ها و فازها
│           └── presentation/screens/
│               └── game_table_screen.dart # میز تعاملی صندلی‌ها
│
└── pubspec.yaml                       # پکیج‌ها و تنظیمات پروژه
\`\`\`

---

## 🎭 ساختار درختی نقش‌ها و تیم‌ها

\`\`\`text
Roles & Teams
├── 🔴 تیم مافیا (Mafia Team)
│   ├── 👑 پدرخوانده (Godfather) ── استعلام منفی، شلیک نهایی
│   ├── 💉 دکتر لکتر (Dr. Lecter) ── نجات اعضای مافیا در شب
│   └── 🗡️ مافیای ساده (Simple Mafia) ── مشارکت در رأی‌گیری شب
│
├── 🟢 تیم شهروند (Citizen Team)
│   ├── 🩺 دکتر (Doctor) ── نجات شهروند هدف شلیک
│   ├── 🔍 کارآگاه (Detective) ── استعلام هویت مافیا در شب
│   ├── 🎯 تک‌تیرانداز (Sniper) ── شلیک به مافیا در شب
│   └── 👥 شهروند ساده (Simple Citizen) ── تحلیل و رأی‌گیری روز
│
└── ⚪ مستقل (Neutral)
    └── 🃏 جوکر ── پیروزی با شرایط خاص
\`\`\`

---

👤 **توسعه‌دهنده:** امیرعلی — Mobile Developer (Flutter / Android / Unity)
EOF
git add README.md
git commit -m "docs: add full mermaid flowchart, role map and project tree structure"
git push origin main
=======
>>>>>>> 3fb420d (Complete Part A: Offline Pass and Play core gameplay loop)
