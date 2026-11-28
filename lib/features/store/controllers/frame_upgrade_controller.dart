import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FrameUpgrade {
  final String id;
  final String name;
  final String type;
  final int diamondCost;
  final String description;

  FrameUpgrade({
    required this.id,
    required this.name,
    required this.type,
    required this.diamondCost,
    required this.description,
  });
}

class FrameUpgradeState {
  final List<String> purchasedUpgrades;
  final bool isLoading;
  final String? error;

  FrameUpgradeState({
    required this.purchasedUpgrades,
    this.isLoading = false,
    this.error,
  });

  FrameUpgradeState copyWith({
    List<String>? purchasedUpgrades,
    bool? isLoading,
    String? error,
  }) {
    return FrameUpgradeState(
      purchasedUpgrades: purchasedUpgrades ?? this.purchasedUpgrades,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class FrameUpgradeController extends StateNotifier<FrameUpgradeState> {
  FrameUpgradeController()
      : super(FrameUpgradeState(purchasedUpgrades: [])) {
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final upgrades = prefs.getStringList('purchased_upgrades') ?? [];
      state = state.copyWith(purchasedUpgrades: upgrades);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> purchaseUpgrade(String upgradeId) async {
    try {
      state = state.copyWith(isLoading: true);
      final prefs = await SharedPreferences.getInstance();
      
      final upgrades = state.purchasedUpgrades;
      if (!upgrades.contains(upgradeId)) {
        upgrades.add(upgradeId);
      }

      await prefs.setStringList('purchased_upgrades', upgrades);
      state = state.copyWith(
        purchasedUpgrades: upgrades,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
}

final frameUpgradeProvider =
    StateNotifierProvider<FrameUpgradeController, FrameUpgradeState>(
  (_) => FrameUpgradeController(),
);
