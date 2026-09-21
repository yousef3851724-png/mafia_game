import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/radical_frame_tier.dart';
import '../../lobbies/diamond_state.dart';

class FrameOwnershipState {
  final Set<RadicalFrameTier> ownedFrames;
  final RadicalFrameTier equippedFrame;
  final bool isLoading;
  final String? error;

  const FrameOwnershipState({
    required this.ownedFrames,
    required this.equippedFrame,
    this.isLoading = false,
    this.error,
  });

  FrameOwnershipState copyWith({
    Set<RadicalFrameTier>? ownedFrames,
    RadicalFrameTier? equippedFrame,
    bool? isLoading,
    String? error,
  }) =>
      FrameOwnershipState(
        ownedFrames: ownedFrames ?? this.ownedFrames,
        equippedFrame: equippedFrame ?? this.equippedFrame,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );

  Map<String, dynamic> toJson() => {
        'owned': ownedFrames.map((f) => f.name).toList(),
        'equipped': equippedFrame.name,
      };

  static FrameOwnershipState fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const FrameOwnershipState(
        ownedFrames: {RadicalFrameTier.none},
        equippedFrame: RadicalFrameTier.none,
      );
    }

    final ownedNames =
        (json['owned'] as List<dynamic>?)?.whereType<String>().toList() ??
            const <String>[];
    final owned = ownedNames
        .map(RadicalFrameTier.getByName)
        .whereType<RadicalFrameTier>()
        .toSet();
    final equipped = RadicalFrameTier.getByName(
          json['equipped'] as String? ?? 'none',
        ) ??
        RadicalFrameTier.none;

    return FrameOwnershipState(
      ownedFrames: owned.isEmpty ? {RadicalFrameTier.none} : owned,
      equippedFrame: equipped,
    );
  }
}

class FrameOwnershipController extends StateNotifier<FrameOwnershipState> {
  FrameOwnershipController({required this.prefs, required this.ref})
      : super(FrameOwnershipState.fromJson(_loadFromPrefs(prefs)));

  final SharedPreferences prefs;
  final Ref ref;
  static const String _storageKey = 'frame_ownership_v2';

  static Map<String, dynamic>? _loadFromPrefs(SharedPreferences prefs) {
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (_) {
      return null;
    }
  }

  Future<bool> purchaseFrameWithDiamonds(RadicalFrameTier tier) async {
    if (tier == RadicalFrameTier.none || state.ownedFrames.contains(tier)) {
      return false;
    }

    final type = tier.diamondType;
    final cost = tier.diamondPrice;
    if (type == null || cost <= 0) return false;

    final diamonds = ref.read(diamondControllerProvider.notifier);
    if (!diamonds.canSpend(type: type, amount: cost)) {
      state = state.copyWith(error: 'موجودی الماس کافی نیست.');
      return false;
    }

    diamonds.spend(type, cost);
    state = state.copyWith(
      ownedFrames: {...state.ownedFrames, tier},
      error: null,
    );
    await _save();
    return true;
  }

  Future<bool> purchaseFrame(RadicalFrameTier tier) =>
      purchaseFrameWithDiamonds(tier);

  Future<bool> equipFrame(RadicalFrameTier tier) async {
    if (!state.ownedFrames.contains(tier)) return false;
    state = state.copyWith(equippedFrame: tier, error: null);
    await _save();
    return true;
  }

  Future<bool> unequipFrame() async {
    state = state.copyWith(equippedFrame: RadicalFrameTier.none, error: null);
    await _save();
    return true;
  }

  bool isOwned(RadicalFrameTier tier) => state.ownedFrames.contains(tier);
  bool isEquipped(RadicalFrameTier tier) => state.equippedFrame == tier;

  List<RadicalFrameTier> getOwnedSorted() => state.ownedFrames
      .where((f) => f != RadicalFrameTier.none)
      .toList()
    ..sort((a, b) => a.index.compareTo(b.index));

  Future<void> _save() async {
    await prefs.setString(_storageKey, jsonEncode(state.toJson()));
  }

  Future<void> reset() async {
    state = const FrameOwnershipState(
      ownedFrames: {RadicalFrameTier.none},
      equippedFrame: RadicalFrameTier.none,
    );
    await prefs.remove(_storageKey);
  }
}

final frameOwnershipProvider =
    StateNotifierProvider<FrameOwnershipController, FrameOwnershipState>((ref) {
  return FrameOwnershipController(
    prefs: ref.read(sharedPreferencesProvider),
    ref: ref,
  );
});

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw StateError(
    'SharedPreferences must be initialized before ProviderScope.',
  );
});
