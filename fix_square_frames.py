import os

# رنگ‌های اصلی برای fire, lightning, neon (بر اساس کاتالوگ Flutter)
fixes = [
    ("fire",      "#FF3D00", "#FF9100"),  # نارنجی/قرمز
    ("lightning", "#00E5FF", "#2979FF"),  # فیروزه‌ای/آبی
    ("neon",      "#FF007F", "#00F0FF"),  # صورتی/سایان
]

os.makedirs("assets/frames", exist_ok=True)

for name, main, accent in fixes:
    svg = f'''<svg viewBox="0 0 200 200" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <radialGradient id="glow_{name}" cx="50%" cy="50%" r="50%">
      <stop offset="85%" stop-color="{main}" stop-opacity="0"/>
      <stop offset="100%" stop-color="{main}" stop-opacity="0.35"/>
    </radialGradient>
  </defs>

  <!-- Outer glow -->
  <circle cx="100" cy="100" r="98" fill="url(#glow_{name})"/>

  <!-- Main ring -->
  <circle cx="100" cy="100" r="92" fill="none" stroke="{main}" stroke-width="4"/>

  <!-- Accent ring -->
  <circle cx="100" cy="100" r="86" fill="none" stroke="{accent}" stroke-width="2" opacity="0.75"/>

  <!-- Decorative dots -->
  <circle cx="100" cy="10" r="3.5" fill="{main}"/>
  <circle cx="190" cy="100" r="3.5" fill="{accent}"/>
  <circle cx="100" cy="190" r="3.5" fill="{main}"/>
  <circle cx="10" cy="100" r="3.5" fill="{accent}"/>
</svg>'''
    with open(f"assets/frames/frame_{name}.svg", "w", encoding="utf-8") as f:
        f.write(svg)
    print(f"✅ frame_{name}.svg اصلاح شد")
