import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/radical_frame_tier.dart';

class FrameOwnershipState {
  final Set<RadicalFrameTier> ownedFrames;
  final RadicalFrameTier equippedFrame;
  final bool isLoading;
  final String? error;

  FrameOwnershipState({
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
        error: error ?? this.error,
      );

  Map<String, dynamic> toJson() => {
    'owned': ownedFrames.map((f) => f.name).toList(),
    'equipped': equippedFrame.name,
  };

  static FrameOwnershipState fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return FrameOwnershipState(
        ownedFrames: {RadicalFrameTier.none},
        equippedFrame: RadicalFrameTier.none,
      );
    }

    final ownedNames = (json['owned'] as List<dynamic>?)?.cast<String>() ?? [];
    final owned = ownedNames
        .map((name) => RadicalFrameTier.getByName(name) ?? RadicalFrameTier.none)
        .toSet();

    final equippedName = json['equipped'] as String? ?? 'none';
    final equipped =
        RadicalFrameTier.getByName(equippedName) ?? RadicalFrameTier.none;

    return FrameOwnershipState(
      ownedFrames: owned.isEmpty ? {RadicalFrameTier.none} : owned,
      equippedFrame: equipped,
    );
  }
}

class FrameOwnershipController
    extends StateNotifier<FrameOwnershipState> {
  final SharedPreferences prefs;

  static const String _storageKey = 'frame_ownership_v2';

  FrameOwnershipController({
    required this.prefs,
  }) : super(FrameOwnershipState.fromJson(_loadFromPrefs(prefs)));

  static Map<String, dynamic>? _loadFromPrefs(SharedPreferences prefs) {
    final json = prefs.getString(_storageKey);
    if (json == null) return null;
    try {
      final ownedMatch = RegExp(r'"owned":\[(.*?)\]').firstMatch(json);
      final equippedMatch = RegExp(r'"equipped":"([^"]*)"').firstMatch(json);

      final ownedStr = ownedMatch?.group(1) ?? '';
      final ownedList = ownedStr.isEmpty
          ? <String>[]
          : ownedStr.split(',').map((s) => s.trim().replaceAll('"', ''));

      final equipped = equippedMatch?.group(1) ?? 'none';

      return {
        'owned': ownedList.toList(),
        'equipped': equipped,
      };
    } catch (_) {
      return null;
    }
  }

  Future<bool> purchaseFrame(RadicalFrameTier tier) async {
    if (state.ownedFrames.contains(tier)) {
      return false;
    }

    final updated = state.copyWith(
      ownedFrames: {...state.ownedFrames, tier},
    );
    state = updated;
    await _save();
    return true;
  }

  Future<bool> equipFrame(RadicalFrameTier tier) async {
    if (!state.ownedFrames.contains(tier)) {
      return false;
    }

    state = state.copyWith(equippedFrame: tier);
    await _save();
    return true;
  }

  Future<bool> unequipFrame() async {
    state = state.copyWith(equippedFrame: RadicalFrameTier.none);
    await _save();
    return true;
  }

  bool isOwned(RadicalFrameTier tier) => state.ownedFrames.contains(tier);

  bool isEquipped(RadicalFrameTier tier) => state.equippedFrame == tier;

  List<RadicalFrameTier> getOwnedSorted() {
    return state.ownedFrames
        .where((f) => f != RadicalFrameTier.none)
        .toList()
      ..sort((a, b) => a.index.compareTo(b.index));
  }

  Future<void> _save() async {
    final json = state.toJson();
    final ownedStr = (json['owned'] as List)
        .map((f) => '"$f"')
        .join(',');
    final jsonStr =
        '{"owned":[$ownedStr],"equipped":"${json['equipped']}"}';
    await prefs.setString(_storageKey, jsonStr);
  }

  Future<void> reset() async {
    state = FrameOwnershipState(
      ownedFrames: {RadicalFrameTier.none},
      equippedFrame: RadicalFrameTier.none,
    );
    await prefs.remove(_storageKey);
  }
}

final frameOwnershipProvider =
    StateNotifierProvider<FrameOwnershipController, FrameOwnershipState>(
  (ref) => FrameOwnershipController(
    prefs: SharedPreferences.getInstance() as SharedPreferences,
  ),
);
