enum AppFlavor { dev, staging, production }

/// پیکربندی کلی اپ که در main_*.dart ست می‌شود
class AppConfig {
  static late AppFlavor flavor;
  static late bool enableLogging;
  static late bool enableCrashReporting;

  static void init({
    required AppFlavor appFlavor,
  }) {
    flavor = appFlavor;
    enableLogging = appFlavor != AppFlavor.production;
    enableCrashReporting = appFlavor == AppFlavor.production;
  }

  static bool get isProduction => flavor == AppFlavor.production;
  static bool get isDev => flavor == AppFlavor.dev;
}
