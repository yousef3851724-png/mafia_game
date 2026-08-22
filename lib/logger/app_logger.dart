import 'dart:math';
import '../models/role_model.dart';

class RoleAssigner {
  static List<Role> assignRoles(int playerCount) {
    if (playerCount < 5) {
      throw Exception('حداقل ۵ بازیکن نیاز است.');
    }

    List<Role> roles = [];
    int mafiaCount = (playerCount / 3).floor();
    if (mafiaCount < 1) mafiaCount = 1;

    int specialCount = 3; // doctor + detective + joker
    int citizenCount = playerCount - mafiaCount - specialCount;

    // اضافه کردن نقش‌های ثابت
    roles.add(Role.mafia);
    roles.add(Role.doctor);
    roles.add(Role.detective);
    roles.add(Role.joker);

    // اضافه کردن مافیاهای باقی‌مانده
    for (int i = 1; i < mafiaCount; i++) {
      roles.add(Role.mafia);
    }

    // اضافه کردن شهروندان
    for (int i = 0; i < citizenCount; i++) {
      roles.add(Role.citizen);
    }

    // تصادفی کردن لیست
    roles.shuffle(Random());
    return roles;
  }

  static Map<int, Role> assignRolesToPlayers(List<String> playerNames) {
    List<Role> roles = assignRoles(playerNames.length);
    Map<int, Role> playerRoles = {};
    for (int i = 0; i < playerNames.length; i++) {
      playerRoles[i] = roles[i];
    }
    return playerRoles;
  }
}
