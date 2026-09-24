import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/radical_frame_tier.dart';
import '../controllers/frame_ownership_controller.dart';

final frameIsOwnedProvider = Provider.family<bool, RadicalFrameTier>(
  (ref, tier) {
    final ownership = ref.watch(frameOwnershipProvider);
    return ownership.ownedFrames.contains(tier);
  },
);

final frameIsEquippedProvider = Provider.family<bool, RadicalFrameTier>(
  (ref, tier) {
    final ownership = ref.watch(frameOwnershipProvider);
    return ownership.equippedFrame == tier;
  },
);

final currentEquippedFrameProvider = Provider<RadicalFrameTier>(
  (ref) {
    final ownership = ref.watch(frameOwnershipProvider);
    return ownership.equippedFrame;
  },
);

final ownedFramesListProvider = Provider<List<RadicalFrameTier>>(
  (ref) {
    final ownership = ref.watch(frameOwnershipProvider);
    return ownership.ownedFrames;
  },
);

final availableFramesProvider = Provider<List<RadicalFrameTier>>(
  (ref) {
    return RadicalFrameTier.values.where((tier) => tier.tierIndex > 0).toList();
  },
);
