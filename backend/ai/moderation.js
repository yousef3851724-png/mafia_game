'use strict';

// Lightweight baseline only. It is not a replacement for human review or a trained model.
const patterns = [
  { category: 'threat', regex: /\b(می.?کشمت|می.?زنمت|تهدیدت می.?کنم)\b/i },
  { category: 'spam', regex: /(.)\1{11,}/u },
  { category: 'flood', regex: /https?:\/\/\S+/i },
];

function moderateChat(input) {
  const text = String(input ?? '').trim();
  if (!text) return { allowed: false, category: 'empty', reason: 'پیام خالی است.' };
  if (text.length > 500) return { allowed: false, category: 'length', reason: 'پیام بیش از حد طولانی است.' };
  for (const item of patterns) {
    if (item.regex.test(text)) {
      return { allowed: false, category: item.category, reason: 'این پیام برای بررسی یا اصلاح نگه داشته شد.' };
    }
  }
  return { allowed: true, category: 'ok', reason: null };
}

module.exports = { moderateChat };
