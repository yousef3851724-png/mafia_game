/// این فایل برای حالت آنلاین (Section بعدی) استفاده می‌شود.
/// در حال حاضر اپ به صورت آفلاین (اپ گرداننده) کار می‌کند و به سرور نیازی نیست.
class EnvConfig {
  EnvConfig._();

  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: '',
  );

  static const bool onlineModeEnabled = bool.fromEnvironment(
    'ONLINE_MODE',
    defaultValue: false,
  );
}
