#!/usr/bin/env python3
"""اجرا از ریشهٔ پروژه: python mr_catalog_patch.py"""
import os, shutil, sys
target=None
for root,_,fs in os.walk('lib'):
    for f in fs:
        if f.endswith('.dart'):
            p=os.path.join(root,f)
            if 'class AvatarCatalog' in open(p,encoding='utf-8').read(): target=p
if not target: sys.exit('class AvatarCatalog پیدا نشد')
s=open(target,encoding='utf-8').read()
if 'avatars_v2' in s: sys.exit('قبلاً patch شده')
a=s.index('class AvatarCatalog'); i=s.index('{',a); d=0
for j in range(i,len(s)):
    if s[j]=='{': d+=1
    elif s[j]=='}':
        d-=1
        if d==0: break
new='''class AvatarCatalog {
  static const int count = 100;
  static List<String> get all => List.generate(count, path);

  static String path(int index) {
    final n = (index + 1).toString().padLeft(3, '0');
    return 'assets/avatars_v2/avatar_$n.png';
  }
}'''
shutil.copy(target,target+'.bak')
open(target,'w',encoding='utf-8').write(s[:a]+new+s[j+1:])
print('patched',target,'(backup: .bak)')
print('\n--- جاهایی که هنوز مسیر/تعداد قدیمی دارند ---')
os.system("grep -rn -E 'set_70|set_29|count = 99|< 99|== 99|<= 99' lib --include=*.dart | grep -v '.bak'")
