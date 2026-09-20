import 'package:flutter/material.dart';
import 'radical_avatar_picker.dart';
import '../../core/models/radical_avatar_catalog.dart';

class AvatarSelectionScreen extends StatelessWidget {
  const AvatarSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('انتخاب آواتار')),
      body: RadicalAvatarPicker(
        onSelected: (RadicalAvatarAsset avatar) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${avatar.displayNameFa} انتخاب شد')),
          );
        },
      ),
    );
  }
}