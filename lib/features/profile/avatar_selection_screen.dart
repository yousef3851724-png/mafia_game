import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'radical_avatar_picker.dart';
import '../../core/models/radical_avatar_catalog.dart';

class AvatarSelectionScreen extends StatelessWidget {
  const AvatarSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('انتخاب آواتار')),
      body: RadicalAvatarPicker(
        onSelected: (RadicalAvatarAsset avatar) async {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('selected_avatar', avatar.displayNameFa);
          await prefs.setString('selected_avatar_id', avatar.id);
          await prefs.setString('selected_avatar_path', avatar.assetPath);
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${avatar.displayNameFa} انتخاب شد')),
          );
          Navigator.pop(context, avatar.id);
        },
      ),
    );
  }
}
