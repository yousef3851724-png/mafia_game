import 'dart:io';

void main() async {
  final files = [
    'lib/features/lobby/round_lobby.dart',
    'lib/features/store/store_screen.dart',
    'lib/core/widgets/frames/animated_avatar_frame.dart',
  ];

  final colorMap = {
    'Colors.white24': 'Colors.white.withOpacity(0.24)',
    'Colors.white38': 'Colors.white.withOpacity(0.38)',
    'Colors.white70': 'Colors.white.withOpacity(0.7)',
    'Colors.black54': 'RadicalTheme.ink.withOpacity(0.54)',
    'Colors.amber': 'RadicalTheme.gold',
    'Colors.green': 'RadicalTheme.violet',
    'Colors.greenAccent': 'RadicalTheme.violetBright',
    'Colors.lightBlueAccent': 'RadicalTheme.smoke',
    'Colors.white': 'Colors.white',
  };

  for (final filePath in files) {
    final file = File(filePath);
    if (!await file.exists()) continue;
    
    String content = await file.readAsString();
    for (var e in colorMap.entries) {
      content = content.replaceAll(e.key, e.value);
    }
    await file.writeAsString(content);
    print('✅ $filePath');
  }
}
