import 'dart:io';

import 'package:dio/dio.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shakti/extensions/map-entensions.dart';
import 'package:shakti/singletons/SecureStorage.dart';
import '../constants/Constants.dart';
import 'LoggerSingleton.dart';

class AppPlayer{
  static final AppPlayer _instance = AppPlayer._();
  final player = AudioPlayer();
  final _playlist = ConcatenatingAudioSource(
    // Start loading next item just before reaching it
    useLazyPreparation: true,
    // Customise the shuffle algorithm
    shuffleOrder: DefaultShuffleOrder(),
    // Specify the playlist items
    children: [
    ],
  );
  final _currentSource = BehaviorSubject<String?>(); // Use Rx for better control

  AppPlayer._(){
    _init();
  }

  void _init() async{
    await player.setAudioSource(_playlist, initialIndex: 0, initialPosition: Duration.zero);

    player.sequenceStateStream.listen((sequenceState) {
      if (sequenceState?.currentSource != null) {
        final currentSource = sequenceState!.currentSource; // Get the current source
        if (currentSource is UriAudioSource) {
          _currentSource.add(currentSource.uri.toString()); // Notify subscribers
        } else {
          throw Exception("Current source is not uri audio source");
        }
      } else {
        _currentSource.add(null); // Handle empty state
      }
    });
  }

  Stream<String?> get currentSourceStream => _currentSource.stream;

  resetPlayList() async{
    await _playlist.clear();
  }

  addToQueue({required String audioUrl}){
    _playlist.add(AudioSource.uri(Uri.parse(audioUrl)));
    if(_playlist.length==1) player.play();
  }

  bool isActiveSource({required String audioUrl}){//will be played
    try{
      if(player.currentIndex==null) return false;
      return (( player.audioSource as ConcatenatingAudioSource?)?.children[player.currentIndex!] as UriAudioSource?)?.uri.toString()==Uri.parse(audioUrl).toString();
    }catch(e){
      return false;
    }
  }

  isInQueue({required String audioUrl}){
    try{
      return _playlist.children.firstWhere((audioSource) => (audioSource as UriAudioSource).uri.toString()==Uri.parse(audioUrl).toString());
    }catch(e){
      return false;
    }
  }

  factory AppPlayer() {
    return _instance;
  }
}

