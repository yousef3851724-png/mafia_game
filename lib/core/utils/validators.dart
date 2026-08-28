class Validators {
  static String? validatePlayerName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'نام بازیکن نمی‌تواند خالی باشد';
    }
    if (value.trim().length < 2) {
      return 'نام باید حداقل ۲ حرف داشته باشد';
    }
    return null;
  }
}
