#!/usr/bin/env python3
"""اجرا از ریشهٔ پروژه:  python wire_avatars.py /path/to/avatars_new.zip"""
import sys, os, re, zipfile, shutil
P = {
1:12000,2:8000,3:28000,4:10000,5:20000,6:36000,7:32000,
8:5000,9:7000,10:15000,11:24000,12:40000,13:28000,14:45000,
15:20000,16:18000,17:24000,18:5000,19:10000,20:32000,21:36000,
22:12000,23:15000,24:8000,25:5000,26:55000,27:18000,28:60000,
29:12000,30:10000,31:48000,32:20000,33:45000,34:28000,35:40000,
36:50000,37:52000,38:55000,39:7000,40:15000,41:62000,42:42000,
43:4000,44:38000,45:24000,46:12000,47:20000,48:30000,49:26000,
50:6000,51:8000,52:5000,53:70000,54:35000,55:18000,56:22000,
57:3000,58:30000,59:14000,60:16000,61:10000,62:24000,63:34000,
64:38000,65:6000,66:46000,67:20000,68:9000,69:26000,70:22000,
71:22000,72:44000,73:20000,74:42000,75:48000,76:40000,
77:18000,78:46000,79:52000,80:38000,81:50000,82:58000,
83:24000,84:26000,85:56000,86:54000,87:28000,88:60000,
89:36000,90:44000,91:32000,92:50000,93:62000,94:52000,
95:34000,96:65000,97:30000,98:58000,99:68000,100:64000}

if len(sys.argv)<2: sys.exit('usage: python wire_avatars.py avatars_new.zip')
zp=sys.argv[1]
if not os.path.exists('pubspec.yaml'): sys.exit('pubspec.yaml پیدا نشد؛ از ریشهٔ پروژه اجرا کنید')
dst='assets/avatars_v2'; os.makedirs(dst,exist_ok=True)
n=0
with zipfile.ZipFile(zp) as z:
    for i in z.namelist():
        if i.endswith('.png'):
            open(os.path.join(dst,os.path.basename(i)),'wb').write(z.read(i)); n+=1
print('extracted',n,'->',dst)
# pubspec
t=open('pubspec.yaml',encoding='utf-8').read()
if 'assets/avatars_v2/' not in t:
    shutil.copy('pubspec.yaml','pubspec.yaml.bak')
    lines=t.split('\n'); done=False
    for k,l in enumerate(lines):
        if re.match(r'^\s{2}assets:\s*$',l):
            ind='    '
            if k+1<len(lines):
                mm=re.match(r'^(\s+)-',lines[k+1])
                if mm: ind=mm.group(1)
            lines.insert(k+1,ind+'- assets/avatars_v2/'); done=True; break
    if not done:
        for k,l in enumerate(lines):
            if re.match(r'^flutter:\s*$',l):
                lines[k+1:k+1]=['  assets:','    - assets/avatars_v2/']; done=True; break
    if not done: lines+=['flutter:','  assets:','    - assets/avatars_v2/']
    open('pubspec.yaml','w',encoding='utf-8').write('\n'.join(lines)); print('pubspec updated (backup: pubspec.yaml.bak)')
else: print('pubspec already has avatars_v2')
# dart catalog
os.makedirs('lib/data',exist_ok=True)
d=["// تولیدشده توسط wire_avatars.py",
"class AvatarItem {",
"  final String id;",
"  final String asset;",
"  final int price; // سکه",
"  const AvatarItem(this.id, this.asset, this.price);",
"}","",
"const List<AvatarItem> kAvatarCatalog = ["]
for i in range(1,101):
    d.append("  AvatarItem('avatar_%03d', 'assets/avatars_v2/avatar_%03d.png', %d),"%(i,i,P[i]))
d+=["];","",
"AvatarItem? avatarById(String id) {",
"  for (final a in kAvatarCatalog) { if (a.id == id) return a; }",
"  return null;",
"}","",
"String toPersianPrice(int v) {",
"  final s = v.toString();",
"  final b = StringBuffer();",
"  for (var i = 0; i < s.length; i++) {",
"    if (i > 0 && (s.length - i) % 3 == 0) b.write('٬');",
"    b.write(String.fromCharCode(0x06F0 + int.parse(s[i])));",
"  }",
"  return b.toString();",
"}"]
open('lib/data/avatar_catalog.dart','w',encoding='utf-8').write('\n'.join(d)+'\n')
print('wrote lib/data/avatar_catalog.dart')
# scan old catalog
print('\n--- فایل‌هایی که احتمالاً کاتالوگ/قیمت قدیمی آواتار دارند ---')
hits=[]
for root,_,fs in os.walk('lib'):
    for f in fs:
        if f.endswith('.dart') and f!='avatar_catalog.dart':
            p=os.path.join(root,f)
            try: txt=open(p,encoding='utf-8').read()
            except: continue
            c=len(re.findall(r'avatar',txt,re.I))
            if c and re.search(r'price|قیمت',txt,re.I): hits.append((c,p))
for c,p in sorted(hits,reverse=True)[:10]: print(c,p)
print('\nبعد از این: خروجی بالا را بفرستید تا اتصال به فروشگاه را دقیق وصل کنم.')
