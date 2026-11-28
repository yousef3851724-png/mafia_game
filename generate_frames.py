import os

frames = [
    ("bronze", "#8B7355", "برنز"),      # Bronze
    ("silver", "#C0C0C0", "نقره"),      # Silver
    ("gold", "#FFD700", "طلا"),         # Gold
    ("platinum", "#E5E4E2", "پلاتین"),  # Platinum
    ("diamond", "#B9F2FF", "الماس"),    # Diamond
    ("legendary", "#FF6B9D", "افسانه ای"), # Legendary
]

os.makedirs("assets/frames", exist_ok=True)

for name, color, farsi in frames:
    svg = f'''<svg viewBox="0 0 200 200" xmlns="http://www.w3.org/2000/svg">
  <!-- Outer glow -->
  <circle cx="100" cy="100" r="95" fill="none" stroke="{color}" stroke-width="3" opacity="0.5"/>
  
  <!-- Main frame -->
  <circle cx="100" cy="100" r="90" fill="none" stroke="{color}" stroke-width="4"/>
  
  <!-- Inner ring -->
  <circle cx="100" cy="100" r="85" fill="none" stroke="{color}" stroke-width="1" opacity="0.6"/>
  
  <!-- Decorative elements -->
  <circle cx="100" cy="25" r="3" fill="{color}"/>
  <circle cx="175" cy="100" r="3" fill="{color}"/>
  <circle cx="100" cy="175" r="3" fill="{color}"/>
  <circle cx="25" cy="100" r="3" fill="{color}"/>
  
  <!-- Text -->
  <text x="100" y="110" font-size="14" text-anchor="middle" fill="{color}" font-weight="bold">{farsi}</text>
</svg>'''
    
    with open(f"assets/frames/frame_{name}.svg", "w", encoding="utf-8") as f:
        f.write(svg)
    print(f"✅ frame_{name}.svg created")

print("\n🎉 تمام فریم ها بنایا گیا!")
