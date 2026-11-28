#!/usr/bin/env bash
set -e

echo "== 1. حذف workflow دیپلوی (چون Auto-Deploy کافی است) =="
git rm -f .github/workflows/render-deploy.yml 2>/dev/null || true

echo "== 2. پاک‌سازی فایل‌های حساس از گیت =="
printf '.cloudflared*.json\n.cloudflare*.json\nbackend/cloudflare_token.tf\nclaude-code-starter-kit/\nserver.log\n' >> .gitignore
sort -u .gitignore -o .gitignore

echo "== 3. commit و push =="
git add .gitignore
PRE_COMMIT_ALLOW_NO_CONFIG=1 git commit -m "chore: finalize render setup" || true
git pull --rebase origin main
git push

echo "== 4. تست سرور Render =="
curl -s -m 90 -o /dev/null -w "health status: %{http_code}\n" https://mafia-radical-api.onrender.com/health || echo "سرور جواب نداد"

echo "== 5. وضعیت workflowها =="
ls .github/workflows/
