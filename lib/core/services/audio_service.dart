import 'package:just_audio/just_audio.dart';

class AudioService {
  static final AudioPlayer _audioPlayer = AudioPlayer();
  
  static Future<void> playMove() async {
    var duration = await _audioPlayer.setAsset('assets/sounds/move.wav');
    _audioPlayer.play();
    return Future.delayed(duration ?? Duration.zero);
  }

  static Future<void> playDice() async {
    var duration = await _audioPlayer.setAsset('assets/sounds/roll_the_dice.mp3');
    _audioPlayer.play();
    return Future.delayed(duration ?? Duration.zero);
  }

  static Future<void> playWin() async {
    var duration = await _audioPlayer.setAsset('assets/sounds/win.mp3');
    _audioPlayer.play();
    return Future.delayed(duration ?? Duration.zero);
  }
} 