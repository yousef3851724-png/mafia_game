/// مدل‌های دسترسی و ناظر هوشمند لابی مافیا رادیکال.
///
/// این لایه عمداً اختیار محدود دارد: ناظر هوشمند فقط تحلیل و پیشنهاد می‌دهد
/// و تصمیم‌های مدیریتی نهایی در اختیار نقش‌های انسانی مجاز است.
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
/// بدون اینترنت و API Key کار می‌کند و فقط نتیجه تحلیل را برمی‌گرداند.
/// اتصال به سرویس AI سمت سرور می‌تواند بعداً پشت همین قرارداد انجام شود.
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

class LobbyPermission {
  LobbyPermission._();

  static LobbyMemberRole roleOf({
    required String playerId,
    required String creatorId,
    required String managerId,
  }) {
    if (playerId == creatorId) return LobbyMemberRole.creator;
    if (playerId == managerId) return LobbyMemberRole.manager;
    return LobbyMemberRole.player;
  }

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
    final targetRole = roleOf(
      playerId: targetId,
      creatorId: creatorId,
      managerId: managerId,
    );

    if (targetRole == LobbyMemberRole.creator) return false;
    if (targetRole == LobbyMemberRole.manager &&
        actorRole != LobbyMemberRole.creator) {
      return false;
    }

    return actorRole == LobbyMemberRole.creator ||
        (actorRole == LobbyMemberRole.manager &&
            targetRole == LobbyMemberRole.player);
  }

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

  static bool canChangeManager({
    required String actorId,
    required String creatorId,
  }) {
    return actorId == creatorId;
  }
}
