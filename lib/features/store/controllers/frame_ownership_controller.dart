import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/radical_frame_tier.dart';
import '../../lobbies/diamond_state.dart';

class FrameOwnershipState {
  final List<RadicalFrameTier> ownedFrames;
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
    List<RadicalFrameTier>? ownedFrames,
    RadicalFrameTier? equippedFrame,
    bool? isLoading,
    String? error,
  }) {
    return FrameOwnershipState(
      ownedFrames: ownedFrames ?? this.ownedFrames,
      equippedFrame: equippedFrame ?? this.equippedFrame,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class FrameOwnershipController extends StateNotifier<FrameOwnershipState> {
  final Ref ref;

  FrameOwnershipController(this.ref)
      : super(FrameOwnershipState(
          ownedFrames: [RadicalFrameTier.none],
          equippedFrame: RadicalFrameTier.none,
        )) {
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ownedJson = prefs.getStringList('owned_frames') ?? [];
      final equippedIndex =
          prefs.getInt('equipped_frame') ?? RadicalFrameTier.none.index;

      final owned = ownedJson
          .map((e) => RadicalFrameTier.values
              .firstWhere((t) => t.name == e, orElse: () => RadicalFrameTier.none))
          .toList();

      final equipped = RadicalFrameTier.values.firstWhere(
        (t) => t.tierIndex == equippedIndex,
        orElse: () => RadicalFrameTier.none,
      );

      state = state.copyWith(ownedFrames: owned, equippedFrame: equipped);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> purchaseFrameWithDiamonds(RadicalFrameTier tier) async {
    try {
      state = state.copyWith(isLoading: true);

      final diamondWallet = ref.read(diamondControllerProvider);
      if (diamondWallet.canSpend(tier.diamondPrice)) {
        ref.read(diamondControllerProvider.notifier).spend(tier.diamondPrice);
        await equipFrame(tier);
      } else {
        state = state.copyWith(
          error: 'الماس کافی نیست',
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> equipFrame(RadicalFrameTier tier) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final owned = state.ownedFrames;

      if (!owned.contains(tier)) {
        owned.add(tier);
      }

      await prefs.setStringList(
        'owned_frames',
        owned.map((e) => e.name).toList(),
      );
      await prefs.setInt('equipped_frame', tier.tierIndex);

      state = state.copyWith(
        ownedFrames: owned,
        equippedFrame: tier,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> unequipFrame() async {
    await equipFrame(RadicalFrameTier.none);
  }
}

final frameOwnershipProvider =
    StateNotifierProvider<FrameOwnershipController, FrameOwnershipState>(
  (ref) => FrameOwnershipController(ref),
);
