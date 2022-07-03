import 'dart:async';

import 'package:audioplayers/audioplayers.dart';

class AudioPlayerModel{
  Duration duration = const Duration(seconds: 0);
  Duration position = const Duration(seconds: 0);
  double recordPosition = 0.0;
  PlayerState playerState = PlayerState.STOPPED;

  get isPlaying => playerState == PlayerState.PLAYING;
  get isPaused => playerState == PlayerState.PAUSED;

  AudioPlayer audioPlayer= AudioPlayer();
  late StreamSubscription _positionSubscription;
  late StreamSubscription _audioPlayerStateSubscription;


  void dispose(){
    audioPlayer.dispose();
    playerState == PlayerState.PAUSED;
  }

  Future play(String uri) async {
    await audioPlayer.play(uri);
    playerState = PlayerState.PLAYING;
  }

  Future pause() async {
    await audioPlayer.pause();
    playerState = PlayerState.PAUSED;
  }

  Future stop() async {
    await audioPlayer.stop();
    playerState = PlayerState.STOPPED;
    position = const Duration();
  }

  Future toggle(url) async {
    if(isPlaying){
      await audioPlayer.pause();
      playerState = PlayerState.PAUSED;
    }else{
      await audioPlayer.play(url);
      playerState = PlayerState.PLAYING;
    }
  }

  void onComplete() {
    playerState = PlayerState.STOPPED;
  }
}