import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/models/app_models.dart';
import '../../lobbies/diamond_state.dart';
import '../models/frame_upgrade.dart';
import 'frame_ownership_controller.dart';

class FrameUpgradeState {
  final Map<String, bool> purchasedUpgrades;
  final String? error;

  const FrameUpgradeState({this.purchasedUpgrades = const {}, this.error});

  FrameUpgradeState copyWith({
    Map<String, bool>? purchasedUpgrades,
    String? error,
  }) =>
      FrameUpgradeState(
        purchasedUpgrades: purchasedUpgrades ?? this.purchasedUpgrades,
        error: error,
      );
}

class FrameUpgradeController extends StateNotifier<FrameUpgradeState> {
  FrameUpgradeController({required this.prefs, required this.ref})
      : super(_load(prefs));

  final SharedPreferences prefs;
  final Ref ref;
  static const _storageKey = 'frame_upgrades_v1';

  static FrameUpgradeState _load(SharedPreferences prefs) {
    final raw = prefs.getString(_storageKey);
    if (raw == null) return const FrameUpgradeState();
    try {
      final value = jsonDecode(raw);
      if (value is Map) {
        return FrameUpgradeState(
          purchasedUpgrades: value.map(
            (key, value) => MapEntry(key.toString(), value == true),
          ),
        );
      }
    } catch (_) {}
    return const FrameUpgradeState();
  }

  Future<bool> purchaseUpgrade(FrameUpgrade upgrade) async {
    if (state.purchasedUpgrades[upgrade.id] == true) return false;

    final diamonds = ref.read(diamondControllerProvider.notifier);
    if (!diamonds.canSpend(
      type: DiamondType.blue,
      amount: upgrade.diamondCost,
    )) {
      state = state.copyWith(error: 'موجودی الماس آبی کافی نیست.');
      return false;
    }

    diamonds.spend(DiamondType.blue, upgrade.diamondCost);
    state = state.copyWith(
      purchasedUpgrades: {
        ...state.purchasedUpgrades,
        upgrade.id: true,
      },
      error: null,
    );
    await prefs.setString(_storageKey, jsonEncode(state.purchasedUpgrades));
    return true;
  }

  Future<void> reset() async {
    state = const FrameUpgradeState();
    await prefs.remove(_storageKey);
  }
}

final frameUpgradeProvider =
    StateNotifierProvider<FrameUpgradeController, FrameUpgradeState>((ref) {
  return FrameUpgradeController(
    prefs: ref.read(sharedPreferencesProvider),
    ref: ref,
  );
});
