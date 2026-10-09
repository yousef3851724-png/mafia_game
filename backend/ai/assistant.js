'use strict';

/** Safe, deterministic FAQ answers; no external AI provider or API key required. */
const FAQ = [
  { keys: ['قانون', 'قوانین', 'چطور بازی'], answer: 'قوانین دقیق باید از تنظیمات رسمی اتاق تعیین شود. در نسخه فعلی آزمایشی، بازی شامل شب، روز، رأی‌گیری و بررسی نتیجه است.' },
  { keys: ['نقش', 'دکتر', 'کارآگاه', 'مافیا'], answer: 'نقش‌های نمونه نسخه آزمایشی شامل مافیا، شهروند، دکتر و کارآگاه است. تعداد و قواعد نقش‌ها باید پیش از انتشار با قوانین نهایی بازی هماهنگ شود.' },
  { keys: ['سکه', 'الماس', 'خرید', 'پرداخت'], answer: 'این دستیار هیچ سکه، الماس، خرید یا پرداختی را تغییر نمی‌دهد. وضعیت اقتصاد بازی باید فقط از سرویس امن سرور و پس از پیاده‌سازی حساب و پایگاه داده مدیریت شود.' },
  { keys: ['گزارش', 'تخلف', 'تقلب', 'توهین'], answer: 'برای گزارش تخلف، شناسه اتاق، نام بازیکن و شرح کوتاه اتفاق را ثبت کنید. این نسخه هنوز سامانه گزارش‌دهی و بررسی انسانی کامل ندارد.' },
];

function answerQuestion(question) {
  const q = String(question ?? '').trim().toLocaleLowerCase('fa');
  if (!q) return { answer: 'سؤال خود را بنویسید.', topic: 'empty' };
  const match = FAQ.find((item) => item.keys.some((key) => q.includes(key)));
  return match
    ? { answer: match.answer, topic: match.keys[0] }
    : { answer: 'پاسخ مطمئنی برای این سؤال در راهنمای فعلی ندارم. لطفاً آن را به پشتیبانی گزارش کنید.', topic: 'unknown' };
}

module.exports = { answerQuestion };
