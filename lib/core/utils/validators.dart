class Validators {
  Validators._();

  /// اعتبارسنجی نام بازیکن
  static String? validatePlayerName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'نام بازیکن نمی‌تواند خالی باشد';
    }
    if (value.trim().length < 2) {
      return 'نام باید حداقل ۲ حرف باشد';
    }
    if (value.trim().length > 20) {
      return 'نام نباید بیشتر از ۲۰ حرف باشد';
    }
    return null;
  }

  /// اعتبارسنجی تعداد بازیکنان بر اساس محدوده مجاز بازی
  static String? validatePlayerCount(int count, {required int min, required int max}) {
    if (count < min) {
      return 'حداقل $min بازیکن لازم است';
    }
    if (count > max) {
      return 'حداکثر $max بازیکن مجاز است';
    }
    return null;
  }
}
