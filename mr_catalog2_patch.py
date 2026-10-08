#!/usr/bin/env python3
"""اجرا از ریشهٔ پروژه: python mr_catalog2_patch.py"""
import re, os, shutil, sys
F1='lib/core/models/radical_avatar_catalog.dart'
F2='lib/features/scenarios/realistic_avatar.dart'
for f in (F1,F2):
    if not os.path.exists(f): sys.exit(f+' پیدا نشد')
s=open(F1,encoding='utf-8').read()
if 'avatars_v2' in s: sys.exit('F1 قبلاً patch شده')
pat=re.compile(r"(RadicalAvatarAsset\(id: 'a(\d+)', assetPath: ')[^']*(')")
cnt=[0]
def rep(m):
    cnt[0]+=1
    return "%sassets/avatars_v2/avatar_%03d.png%s"%(m.group(1),int(m.group(2)),m.group(3))
s2=pat.sub(rep,s)
lines=s2.split('\n'); out=[]; added=False
for l in lines:
    out.append(l)
    if "id: 'a99'" in l and not added:
        out.append("    RadicalAvatarAsset(id: 'a100', assetPath: 'assets/avatars_v2/avatar_100.png', displayNameFa: 'آواتار 100'),"); added=True
if not added: sys.exit("خط a99 پیدا نشد؛ دست نزدم")
shutil.copy(F1,F1+'.bak'); open(F1,'w',encoding='utf-8').write('\n'.join(out))
print('F1: %d مسیر عوض شد + a100 اضافه شد'%cnt[0])
t=open(F2,encoding='utf-8').read()
old="'assets/avatars/set_70/avatar_${n.toString().padLeft(2, '0')}.png'"
new="'assets/avatars_v2/avatar_${n.toString().padLeft(3, '0')}.png'"
if old in t:
    shutil.copy(F2,F2+'.bak'); open(F2,'w',encoding='utf-8').write(t.replace(old,new)); print('F2 patched')
else: print('F2: الگو پیدا نشد، دستی نگاه کنید')
print('\n--- باقی‌ماندهٔ مسیرهای قدیمی ---')
os.system("grep -rn -E 'set_70|set_29' lib --include=*.dart")
print('(اگر چیزی بالا چاپ نشد، همه‌چیز یکدست است)')
