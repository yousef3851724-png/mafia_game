import 'package:audioplayers/audioplayers.dart';

class SoundService {
  static final SoundService instance = SoundService._init();
  static final AudioPlayer _player = AudioPlayer();

  SoundService._init();

  Future<void> playClick() async {
    try {
      await _player.play(AssetSource('sounds/click.mp3'));
    } catch (e) {
      // فایل صدا موجود نیست
    }
  }

  Future<void> playNight() async {
    try {
      await _player.play(AssetSource('sounds/night.mp3'));
    } catch (e) {
      // فایل صدا موجود نیست
    }
  }
}
