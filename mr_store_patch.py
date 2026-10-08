#!/usr/bin/env python3
"""اجرا از ریشهٔ پروژه: python patch_store.py"""
import re, os, sys, shutil
F='lib/features/store/store_items.dart'
if not os.path.exists(F): sys.exit(F+' پیدا نشد')
if not os.path.exists('lib/data/avatar_catalog.dart'): sys.exit('اول wire_avatars.py را اجرا کنید')
t=open(F,encoding='utf-8').read()
if 'kAvatarCatalog' in t: sys.exit('قبلاً patch شده')
m=re.search(r'  static final List<StoreItem> avatars = List\.generate\(.*?\n  \);\n',t,re.S)
if not m: sys.exit('بلاک avatars پیدا نشد؛ دست نزدم')
new='''  static final List<StoreItem> avatars = List.generate(
    kAvatarCatalog.length,
    (i) => StoreItem(
      id: 'av${(i + 1).toString().padLeft(2, '0')}',
      category: StoreCategory.avatar,
      nameFa: 'آواتار ${i + 1}',
      price: kAvatarCatalog[i].price,
      assetPath: kAvatarCatalog[i].asset,
      currency: StoreCurrency.coins,
    ),
  );
'''
pkg=re.search(r'^name:\s*(\S+)',open('pubspec.yaml').read(),re.M).group(1)
imp="import 'package:%s/data/avatar_catalog.dart';\n"%pkg
shutil.copy(F,F+'.bak')
t=t[:m.start()]+new+t[m.end():]
imps=list(re.finditer(r"^import .*;\n",t,re.M))
pos=imps[-1].end() if imps else 0
t=t[:pos]+imp+t[pos:]
open(F,'w',encoding='utf-8').write(t)
print('patched',F,'(backup: .bak)')
print('\n--- تعریف AvatarCatalog ---')
for root,_,fs in os.walk('lib'):
    for f in fs:
        if f.endswith('.dart'):
            p=os.path.join(root,f); s=open(p,encoding='utf-8').read()
            if 'class AvatarCatalog' in s:
                i=s.index('class AvatarCatalog'); print(p); print(s[i:i+900])
