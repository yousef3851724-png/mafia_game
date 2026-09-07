cd ~/mafia_game

cat << 'EOF' > README.md
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
```mermaid
graph TD
Start([ورود به لابی]) --> Setup[تشکیل اتاق و پیوستن بازیکنان]
Setup --> RoleAssign[تخصیص تصادفی نقش‌ها توسط AI]
RoleAssign --> NightPhase[آغاز فاز شب]

subgraph شب
NightPhase --> MafiaWake[بیدارباش مافیا و انتخاب تارگت]
MafiaWake --> DoctorWake[بیدارباش دکتر و نجات]
DoctorWake --> DetectiveWake[استعلام کارآگاه]
DetectiveWake --> NightResolution[محاسبه نتایج شب توسط هوش مصنوعی]
end

NightResolution --> DayPhase[آغاز فاز روز و گزارش راوی]

subgraph روز
DayPhase --> SpeakingTurn[نوبت‌های صحبت و چالش]
SpeakingTurn --> Voting[رأی‌گیری عمومی]
Voting --> Defense[دفاعیه متهمان]
Defense --> FinalVote[رأی خروج نهایی]
end

FinalVote --> WinCheck{بررسی شرط پیروزی}
WinCheck -- ادامه بازی --> NightPhase
WinCheck -- مافیا برابر شهروند --> MafiaWin([پیروزی مافیا])
WinCheck -- حذف همه مافیاها --> CitizenWin([پیروزی شهروندان])
بخش	فناوری
کلاینت موبایل	Flutter (Dart)
مدیریت مسیرها و وضعیت	GoRouter + GetIt + SharedPreferences
سرور بلادرنگ	Node.js + Socket.io
هاستینگ / بک‌اند	Firebase / Docker / FastAPI# دریافت مخزن
git clone https://github.com/yousef3851724-png/mafia_game.git

# ورود به پوشه
cd mafia_game

# دریافت وابستگی‌ها
flutter pub get

# اجرای پروژه
flutter run
👤 توسعه‌دهنده: امیرعلی — Mobile Developer (Flutter / Android / Unity)

EOF
