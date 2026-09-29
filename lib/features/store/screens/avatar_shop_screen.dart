import 'package:flutter/material.dart';
import '../../../core/models/radical_avatar_catalog.dart';
import '../../../core/theme/radical_theme.dart';

class AvatarShopScreen extends StatelessWidget {
  const AvatarShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const avatars = RadicalAvatarCatalog.avatars;
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.72,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
      ),
      itemCount: avatars.length,
      itemBuilder: (context, i) {
        final a = avatars[i];
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: RadicalTheme.panel,
            border: Border.all(color: RadicalTheme.gold, width: 1.2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 72,
                  height: 72,
                  child: Image.asset(
                    a.assetPath,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _fallback(a),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(a.displayNameFa,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: RadicalTheme.textTheme.bodyMedium),
              const SizedBox(height: 2),
              const Text('لجندری',
                  style: TextStyle(color: RadicalTheme.gold, fontSize: 10)),
            ],
          ),
        );
      },
    );
  }

  Widget _fallback(RadicalAvatarAsset a) => Container(
        color: RadicalTheme.panel2,
        alignment: Alignment.center,
        child: Text(
          a.displayNameFa.isNotEmpty ? a.displayNameFa[0] : '?',
          style: const TextStyle(
              color: RadicalTheme.goldBright,
              fontSize: 30,
              fontWeight: FontWeight.w800),
        ),
      );
}
