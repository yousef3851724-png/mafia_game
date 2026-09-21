import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/radical_frame_tier.dart';
import '../controllers/frame_ownership_controller.dart';

// Frame availability providers
final frameIsOwnedProvider = FutureProvider.family<bool, RadicalFrameTier>(
  (ref, tier) async {
    final ownership = ref.watch(frameOwnershipProvider);
    return ownership.ownedFrames.contains(tier);
  },
);

final frameIsEquippedProvider = FutureProvider.family<bool, RadicalFrameTier>(
  (ref, tier) async {
    final ownership = ref.watch(frameOwnershipProvider);
    return ownership.equippedFrame == tier;
  },
);

final currentEquippedFrameProvider = FutureProvider<RadicalFrameTier>(
  (ref) async {
    final ownership = ref.watch(frameOwnershipProvider);
    return ownership.equippedFrame;
  },
);

final ownedFramesListProvider = FutureProvider<List<RadicalFrameTier>>(
  (ref) async {
    final ownership = ref.watch(frameOwnershipProvider);
    return ownership.ownedFrames;
  },
);

final availableFramesProvider = FutureProvider<List<RadicalFrameTier>>(
  (ref) async {
    return RadicalFrameTier.values.where((tier) => tier.index > 0).toList();
  },
);
