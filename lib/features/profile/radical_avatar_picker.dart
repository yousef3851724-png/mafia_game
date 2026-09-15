import 'package:flutter/material.dart';
import '../../models/radical_avatar_frame_model.dart';
import '../../core/widgets/radical_avatar_frame.dart';

/// گرید انتخاب آواتار برای پروفایل/ساخت شخصیت.
/// آواتار انتخاب‌شده با فریم فعلی کاربر پیش‌نمایش داده می‌شود.
class RadicalAvatarPicker extends StatefulWidget {
  final String? initialAvatarId;
  final RadicalFrameTier currentTier;
  final ValueChanged<RadicalAvatarAsset> onSelected;

  const RadicalAvatarPicker({
    super.key,
    this.initialAvatarId,
    this.currentTier = RadicalFrameTier.gold,
    required this.onSelected,
  });

  @override
  State<RadicalAvatarPicker> createState() => _RadicalAvatarPickerState();
}

class _RadicalAvatarPickerState extends State<RadicalAvatarPicker> {
  late String selectedId;

  @override
  void initState() {
    super.initState();
    selectedId = widget.initialAvatarId ?? RadicalAvatarCatalog.avatars.first.id;
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.all(12),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: .82,
      ),
      itemCount: RadicalAvatarCatalog.avatars.length,
      itemBuilder: (context, index) {
        final avatar = RadicalAvatarCatalog.avatars[index];
        final isSelected = avatar.id == selectedId;
        return GestureDetector(
          onTap: () {
            setState(() => selectedId = avatar.id);
            widget.onSelected(avatar);
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadicalAvatarFrame(
                avatarAssetPath: avatar.assetPath,
                tier: isSelected ? widget.currentTier : RadicalFrameTier.none,
                size: 64,
                showBadge: false,
              ),
              const SizedBox(height: 4),
              Text(
                avatar.displayNameFa,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? const Color(0xFFFFD700) : Colors.white70,
                ),
              ),
              if (avatar.isPremium)
                const Icon(Icons.lock, size: 12, color: Colors.amber)
              else
                const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }
}
