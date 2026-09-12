<<<<<<< HEAD
/// مدل‌های دسترسی و ناظر هوشمند لابی مافیا رادیکال.
///
/// این لایه عمداً اختیار محدود دارد: ناظر هوشمند فقط تحلیل و پیشنهاد می‌دهد
/// و تصمیم‌های مدیریتی نهایی در اختیار نقش‌های انسانی مجاز است.
=======
/// قوانین امنیتی و مدیریت لابی Mafia Radical.
///
/// این لایه مستقل از UI است تا بعداً بتوان آن را به سرور واقعی متصل کرد.

>>>>>>> 508b1ca (fix: upgrade AGP to 8.11.1 and Gradle to 8.13)
enum LobbyMemberRole {
  creator,
  manager,
  player,
}

enum LobbyModerationLevel {
  clean,
  warning,
  serious,
}

class LobbyBan {
  final String playerId;
  final String bannedBy;
  final String reason;
  final DateTime createdAt;

  const LobbyBan({
    required this.playerId,
    required this.bannedBy,
    required this.reason,
    required this.createdAt,
  });
}

class LobbyModerationResult {
  final LobbyModerationLevel level;
  final String reason;

  const LobbyModerationResult({
    required this.level,
    required this.reason,
  });

  bool get shouldWarn =>
      level == LobbyModerationLevel.warning ||
      level == LobbyModerationLevel.serious;

  bool get isSerious => level == LobbyModerationLevel.serious;
}

/// ناظر هوشمند محلی.
///
<<<<<<< HEAD
/// بدون اینترنت و API Key کار می‌کند و فقط نتیجه تحلیل را برمی‌گرداند.
/// اتصال به سرویس AI سمت سرور می‌تواند بعداً پشت همین قرارداد انجام شود.
=======
/// این نسخه بدون اینترنت و بدون API Key کار می‌کند.
/// بعداً می‌توان همین interface را به سرویس AI سمت سرور متصل کرد.
>>>>>>> 508b1ca (fix: upgrade AGP to 8.11.1 and Gradle to 8.13)
class LobbyAiModerator {
  LobbyAiModerator._();

  static const List<String> _warningWords = [
    'احمق',
    'نادان',
    'بی شعور',
    'بی‌شعور',
    'خفه',
    'دروغگو',
    'دروغ گو',
  ];

  static const List<String> _seriousWords = [
    'فحش',
    'تهدید',
  ];

  static LobbyModerationResult analyze(String message) {
    final normalized = message.trim().toLowerCase();

    if (normalized.isEmpty) {
      return const LobbyModerationResult(
        level: LobbyModerationLevel.clean,
        reason: 'پیام خالی است.',
      );
    }

    for (final word in _seriousWords) {
      if (normalized.contains(word)) {
        return LobbyModerationResult(
          level: LobbyModerationLevel.serious,
          reason: 'رفتار نامناسب شناسایی شد: $word',
        );
      }
    }

    for (final word in _warningWords) {
      if (normalized.contains(word)) {
        return LobbyModerationResult(
          level: LobbyModerationLevel.warning,
          reason: 'احتمال بی‌احترامی شناسایی شد: $word',
        );
      }
    }

    return const LobbyModerationResult(
      level: LobbyModerationLevel.clean,
      reason: 'مورد مشکوکی شناسایی نشد.',
    );
  }
}

<<<<<<< HEAD
=======
/// کنترل دسترسی اعضای لابی.
>>>>>>> 508b1ca (fix: upgrade AGP to 8.11.1 and Gradle to 8.13)
class LobbyPermission {
  LobbyPermission._();

  static LobbyMemberRole roleOf({
    required String playerId,
    required String creatorId,
    required String managerId,
  }) {
<<<<<<< HEAD
    if (playerId == creatorId) return LobbyMemberRole.creator;
    if (playerId == managerId) return LobbyMemberRole.manager;
    return LobbyMemberRole.player;
  }

=======
    if (playerId == creatorId) {
      return LobbyMemberRole.creator;
    }

    if (playerId == managerId) {
      return LobbyMemberRole.manager;
    }

    return LobbyMemberRole.player;
  }

  /// آیا این شخص می‌تواند شخص دیگری را اخراج کند؟
>>>>>>> 508b1ca (fix: upgrade AGP to 8.11.1 and Gradle to 8.13)
  static bool canKick({
    required String actorId,
    required String targetId,
    required String creatorId,
    required String managerId,
  }) {
    final actorRole = roleOf(
      playerId: actorId,
      creatorId: creatorId,
      managerId: managerId,
    );
<<<<<<< HEAD
=======

>>>>>>> 508b1ca (fix: upgrade AGP to 8.11.1 and Gradle to 8.13)
    final targetRole = roleOf(
      playerId: targetId,
      creatorId: creatorId,
      managerId: managerId,
    );

<<<<<<< HEAD
    if (targetRole == LobbyMemberRole.creator) return false;
=======
    // هیچ‌کس سازنده را نمی‌تواند اخراج کند.
    if (targetRole == LobbyMemberRole.creator) {
      return false;
    }

    // بازیکن عادی نمی‌تواند مدیر را اخراج کند.
>>>>>>> 508b1ca (fix: upgrade AGP to 8.11.1 and Gradle to 8.13)
    if (targetRole == LobbyMemberRole.manager &&
        actorRole != LobbyMemberRole.creator) {
      return false;
    }

<<<<<<< HEAD
    return actorRole == LobbyMemberRole.creator ||
        (actorRole == LobbyMemberRole.manager &&
            targetRole == LobbyMemberRole.player);
  }

=======
    // مدیر می‌تواند بازیکن عادی را مدیریت کند.
    if (actorRole == LobbyMemberRole.manager &&
        targetRole == LobbyMemberRole.player) {
      return true;
    }

    // سازنده اختیار کامل مدیریت اعضا را دارد.
    if (actorRole == LobbyMemberRole.creator) {
      return true;
    }

    return false;
  }

  /// آیا این شخص می‌تواند هدف را بن کند؟
>>>>>>> 508b1ca (fix: upgrade AGP to 8.11.1 and Gradle to 8.13)
  static bool canBan({
    required String actorId,
    required String targetId,
    required String creatorId,
    required String managerId,
  }) {
    return canKick(
      actorId: actorId,
      targetId: targetId,
      creatorId: creatorId,
      managerId: managerId,
    );
  }

<<<<<<< HEAD
=======
  /// فقط سازنده می‌تواند مدیر جدید تعیین کند.
>>>>>>> 508b1ca (fix: upgrade AGP to 8.11.1 and Gradle to 8.13)
  static bool canChangeManager({
    required String actorId,
    required String creatorId,
  }) {
    return actorId == creatorId;
  }
}
