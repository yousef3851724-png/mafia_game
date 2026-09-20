import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/frame_ownership_controller.dart';
import '../../../core/theme/radical_frame_tier.dart';

final frameIsOwnedProvider = StateProvider.family<bool, RadicalFrameTier>((ref, tier) {
  final ownership = ref.watch(frameOwnershipProvider);
  return ownership.ownedFrames.contains(tier);
});

final frameIsEquippedProvider = StateProvider.family<bool, RadicalFrameTier>((ref, tier) {
  final ownership = ref.watch(frameOwnershipProvider);
  return ownership.equippedFrame == tier;
});

final currentEquippedFrameProvider = StateProvider<RadicalFrameTier>((ref) {
  final ownership = ref.watch(frameOwnershipProvider);
  return ownership.equippedFrame;
});

final ownedFramesListProvider = StateProvider<List<RadicalFrameTier>>((ref) {
  final ownership = ref.watch(frameOwnershipProvider);
  return ownership.ownedFrames.where((f) => f != RadicalFrameTier.none).toList()..sort((a, b) => a.index.compareTo(b.index));
});

final availableFramesProvider = StateProvider<List<RadicalFrameTier>>((ref) {
  final ownership = ref.watch(frameOwnershipProvider);
  return RadicalFrameTier.values.where((f) => !ownership.ownedFrames.contains(f) && f != RadicalFrameTier.none).toList()..sort((a, b) => a.index.compareTo(b.index));
});

final frameSpendingProvider = StateProvider<int>((ref) {
  final ownership = ref.watch(frameOwnershipProvider);
  return ownership.ownedFrames.fold<int>(0, (sum, tier) => sum + tier.diamondPrice);
});

final hasPremiumFramesProvider = StateProvider<bool>((ref) {
  final owned = ref.watch(ownedFramesListProvider);
  return owned.any((f) => f.diamondPrice > 0);
});

final nextFrameTierProvider = StateProvider<RadicalFrameTier?>((ref) {
  final equipped = ref.watch(currentEquippedFrameProvider);
  return equipped.nextTier;
});

final highestOwnedTierProvider = StateProvider<RadicalFrameTier>((ref) {
  final owned = ref.watch(ownedFramesListProvider);
  if (owned.isEmpty) return RadicalFrameTier.none;
  return owned.last;
});
