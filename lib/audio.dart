import 'package:just_audio/just_audio.dart';

class Audio {
  static AudioPlayer audioPlayer = AudioPlayer();

  static Future<void> playMove() async {
    await audioPlayer.setAsset('assets/sounds/move.wav');
    audioPlayer.play();
  }

  static Future<void> playKill() async {
    await audioPlayer.setAsset('assets/sounds/laugh.mp3');
    audioPlayer.play();
  }

  static Future<void> rollDice() async {
    await audioPlayer.setAsset('assets/sounds/roll_the_dice.mp3');
    audioPlayer.play();
    //
  }

  static Future<void> playBlockade() async {
    await audioPlayer.setAsset('assets/sounds/blocked.wav');
    audioPlayer.play();
  }
}
