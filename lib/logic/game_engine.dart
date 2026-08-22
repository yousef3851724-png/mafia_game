import '../models/role_model.dart';

class GameEngine {
  Map<int, Role> playerRoles;
  List<int> alivePlayers;
  Map<int, int> votes;
  bool isNight = true;
  int nightCounter = 0;
  int? lastKilledPlayer;
  int? healedPlayer;
  int? investigatedPlayer;
  bool? isInvestigatedMafia;

  GameEngine({required this.playerRoles}) {
    alivePlayers = playerRoles.keys.toList();
    votes = {};
  }

  // کشتن توسط مافیا
  void killPlayer(int playerId) {
    if (alivePlayers.contains(playerId) &&
        playerRoles[playerId] != Role.mafia &&
        playerId != healedPlayer) {
      alivePlayers.remove(playerId);
      lastKilledPlayer = playerId;
    }
  }

  // نجات توسط دکتر
  void healPlayer(int playerId) {
    if (alivePlayers.contains(playerId)) {
      healedPlayer = playerId;
    }
  }

  // بررسی توسط کارآگاه
  bool investigatePlayer(int playerId) {
    if (alivePlayers.contains(playerId)) {
      investigatedPlayer = playerId;
      isInvestigatedMafia = playerRoles[playerId] == Role.mafia;
      return isInvestigatedMafia!;
    }
    return false;
  }

  // شروع رأی‌گیری روز
  void startVoting(Map<int, int> newVotes) {
    votes = newVotes;
    int maxVotes = 0;
    int? killedPlayer;

    votes.forEach((playerId, voteCount) {
      if (voteCount > maxVotes) {
        maxVotes = voteCount;
        killedPlayer = playerId;
      }
    });

    if (killedPlayer != null && alivePlayers.contains(killedPlayer)) {
      // اگر دلقک رأی بیاورد، دلقک برنده می‌شود
      if (playerRoles[killedPlayer] == Role.joker) {
        alivePlayers.clear(); // بازی تمام شد، دلقک برنده
      } else {
        alivePlayers.remove(killedPlayer);
      }
    }
  }

  // چک کردن پایان بازی
  bool isGameOver() {
    int mafiaCount = 0;
    int nonMafiaCount = 0;

    for (int id in alivePlayers) {
      if (playerRoles[id] == Role.mafia) {
        mafiaCount++;
      } else {
        nonMafiaCount++;
      }
    }

    return (mafiaCount == 0 || mafiaCount >= nonMafiaCount);
  }

  // برنده بازی
  String getWinner() {
    if (alivePlayers.isEmpty) return 'دلقک 🤡';

    int mafiaCount = 0;
    int nonMafiaCount = 0;

    for (int id in alivePlayers) {
      if (playerRoles[id] == Role.mafia) {
        mafiaCount++;
      } else {
        nonMafiaCount++;
      }
    }

    if (mafiaCount == 0) return 'شهروندان 🏆';
    if (mafiaCount >= nonMafiaCount) return 'مافیا 🔪';
    return 'در حال انجام';
  }

  // تغییر شب/روز
  void toggleDayNight() {
    isNight = !isNight;
    if (isNight) {
      nightCounter++;
      healedPlayer = null;
      investigatedPlayer = null;
      isInvestigatedMafia = null;
    } else {
      lastKilledPlayer = null;
    }
    votes.clear();
  }

  // گرفتن نقش یک بازیکن
  Role? getPlayerRole(int playerId) {
    return playerRoles[playerId];
  }
}
