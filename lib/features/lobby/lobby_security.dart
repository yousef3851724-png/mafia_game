/// قوانین امنیتی و مدیریت لابی Mafia Radical.
///
/// این لایه مستقل از UI است تا بعداً بتوان بدون تغییر ویجت‌ها منطق را عوض کرد
/// و تصمیم‌های مدیریتی نهایی در اختیار نقش‌های لابی باشد.

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

/// وضعیت بررسی یک پیام فلگ‌شده توسط مدیر/سازنده.
enum LobbyModerationDecision {
  pending,
  approved,
  dismissed,
  actioned,
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

/// یک پیام فلگ‌شده که منتظر تصمیم مدیر یا سازنده لابی است.
class LobbyFlaggedMessage {
  final String id;
  final String senderId;
  final String message;
  final LobbyModerationResult result;
  final DateTime createdAt;
  final LobbyModerationDecision decision;

  const LobbyFlaggedMessage({
    required this.id,
    required this.senderId,
    required this.message,
    required this.result,
    required this.createdAt,
    this.decision = LobbyModerationDecision.pending,
  });

  LobbyFlaggedMessage copyWith({LobbyModerationDecision? decision}) {
    return LobbyFlaggedMessage(
      id: id,
      senderId: senderId,
      message: message,
      result: result,
      createdAt: createdAt,
      decision: decision ?? this.decision,
    );
  }
}

/// ناظر هوشمند محلی.
///
/// این نسخه بدون اینترنت و بدون API Key کار می‌کند.
/// مدیریت آن (روشن/خاموش کردن، ویرایش کلمات، بررسی پیام‌های فلگ‌شده)
/// فقط در اختیار سازنده یا مدیر لابی است.
class LobbyAiModerator {
  LobbyAiModerator._();

  static bool _enabled = true;

  static final List<String> _warningWords = [
    'احمق',
    'نادان',
    'بی شعور',
    'بی‌شعور',
    'خفه',
    'دروغگو',
    'دروغ گو',
  ];

  static final List<String> _seriousWords = [
    'فحش',
    'تهدید',
  ];

  static final List<LobbyFlaggedMessage> _flaggedMessages = [];

  static bool get isEnabled => _enabled;

  static List<String> get warningWords => List.unmodifiable(_warningWords);

  static List<String> get seriousWords => List.unmodifiable(_seriousWords);

  static List<LobbyFlaggedMessage> get flaggedMessages =>
      List.unmodifiable(_flaggedMessages);

  static bool _canManage({
    required String actorId,
    required String creatorId,
    required String managerId,
  }) {
    final role = LobbyPermission.roleOf(
      playerId: actorId,
      creatorId: creatorId,
      managerId: managerId,
    );
    return role == LobbyMemberRole.creator || role == LobbyMemberRole.manager;
  }

  /// روشن یا خاموش کردن ناظر هوشمند. فقط مدیر یا سازنده مجاز است.
  static bool setEnabled(
    bool value, {
    required String actorId,
    required String creatorId,
    required String managerId,
  }) {
    if (!_canManage(actorId: actorId, creatorId: creatorId, managerId: managerId)) {
      return false;
    }
    _enabled = value;
    return true;
  }

  /// افزودن کلمه به لیست هشدار. فقط مدیر یا سازنده مجاز است.
  static bool addWarningWord(
    String word, {
    required String actorId,
    required String creatorId,
    required String managerId,
  }) {
    if (!_canManage(actorId: actorId, creatorId: creatorId, managerId: managerId)) {
      return false;
    }
    final normalized = word.trim();
    if (normalized.isEmpty) return false;
    if (!_warningWords.contains(normalized)) {
      _warningWords.add(normalized);
    }
    return true;
  }

  /// حذف کلمه از لیست هشدار. فقط مدیر یا سازنده مجاز است.
  static bool removeWarningWord(
    String word, {
    required String actorId,
    required String creatorId,
    required String managerId,
  }) {
    if (!_canManage(actorId: actorId, creatorId: creatorId, managerId: managerId)) {
      return false;
    }
    return _warningWords.remove(word.trim());
  }

  /// افزودن کلمه به لیست جدی. فقط مدیر یا سازنده مجاز است.
  static bool addSeriousWord(
    String word, {
    required String actorId,
    required String creatorId,
    required String managerId,
  }) {
    if (!_canManage(actorId: actorId, creatorId: creatorId, managerId: managerId)) {
      return false;
    }
    final normalized = word.trim();
    if (normalized.isEmpty) return false;
    if (!_seriousWords.contains(normalized)) {
      _seriousWords.add(normalized);
    }
    return true;
  }

  /// حذف کلمه از لیست جدی. فقط مدیر یا سازنده مجاز است.
  static bool removeSeriousWord(
    String word, {
    required String actorId,
    required String creatorId,
    required String managerId,
  }) {
    if (!_canManage(actorId: actorId, creatorId: creatorId, managerId: managerId)) {
      return false;
    }
    return _seriousWords.remove(word.trim());
  }

  /// تحلیل یک پیام. اگر ناظر خاموش باشد، همیشه نتیجه «سالم» برمی‌گردد.
  /// اگر senderId داده شود و پیام هشدار/جدی باشد، به صف بررسی مدیر اضافه می‌شود.
  static LobbyModerationResult analyze(String message, {String? senderId}) {
    if (!_enabled) {
      return const LobbyModerationResult(
        level: LobbyModerationLevel.clean,
        reason: 'نظارت هوشمند غیرفعال است.',
      );
    }

    final normalized = message.trim().toLowerCase();

    if (normalized.isEmpty) {
      return const LobbyModerationResult(
        level: LobbyModerationLevel.clean,
        reason: 'پیام خالی است.',
      );
    }

    LobbyModerationResult result = const LobbyModerationResult(
      level: LobbyModerationLevel.clean,
      reason: 'مورد مشکوکی شناسایی نشد.',
    );

    for (final word in _seriousWords) {
      if (normalized.contains(word)) {
        result = LobbyModerationResult(
          level: LobbyModerationLevel.serious,
          reason: 'رفتار نامناسب شناسایی شد: $word',
        );
        break;
      }
    }

    if (!result.shouldWarn) {
      for (final word in _warningWords) {
        if (normalized.contains(word)) {
          result = LobbyModerationResult(
            level: LobbyModerationLevel.warning,
            reason: 'احتمال بی‌احترامی شناسایی شد: $word',
          );
          break;
        }
      }
    }

    if (result.shouldWarn && senderId != null) {
      _flaggedMessages.add(
        LobbyFlaggedMessage(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          senderId: senderId,
          message: message,
          result: result,
          createdAt: DateTime.now(),
        ),
      );
    }

    return result;
  }

  /// مدیر یا سازنده درباره یک پیام فلگ‌شده تصمیم می‌گیرد.
  static bool resolveFlaggedMessage(
    String id,
    LobbyModerationDecision decision, {
    required String actorId,
    required String creatorId,
    required String managerId,
  }) {
    if (!_canManage(actorId: actorId, creatorId: creatorId, managerId: managerId)) {
      return false;
    }
    final index = _flaggedMessages.indexWhere((m) => m.id == id);
    if (index == -1) return false;
    _flaggedMessages[index] = _flaggedMessages[index].copyWith(decision: decision);
    return true;
  }

  /// پاک‌سازی پیام‌های فلگ‌شده‌ای که قبلاً تصمیم‌گیری شده‌اند.
  static void clearResolved() {
    _flaggedMessages.removeWhere(
      (m) => m.decision != LobbyModerationDecision.pending,
    );
  }
}

/// کنترل دسترسی اعضای لابی.
class LobbyPermission {
  LobbyPermission._();

  static LobbyMemberRole roleOf({
    required String playerId,
    required String creatorId,
    required String managerId,
  }) {
    if (playerId == creatorId) {
      return LobbyMemberRole.creator;
    }

    if (playerId == managerId) {
      return LobbyMemberRole.manager;
    }

    return LobbyMemberRole.player;
  }

  /// آیا این شخص می‌تواند شخص دیگری را اخراج کند؟
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

    // سازنده را هیچ‌کس نمی‌تواند اخراج کند.
    if (targetRole == LobbyMemberRole.creator) {
      return false;
    }

    // سازنده اختیار کامل مدیریت اعضا را دارد.
    if (actorRole == LobbyMemberRole.creator) {
      return true;
    }

    // مدیر فقط می‌تواند بازیکن عادی را اخراج کند.
    if (actorRole == LobbyMemberRole.manager &&
        targetRole == LobbyMemberRole.player) {
      return true;
    }

    // بازیکن عادی اجازه اخراج ندارد.
    return false;
  }

  /// آیا این شخص می‌تواند هدف را بن کند؟
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

  /// فقط سازنده می‌تواند مدیر جدید تعیین کند.
  static bool canChangeManager({
    required String actorId,
    required String creatorId,
  }) {
    return actorId == creatorId;
  }
}
