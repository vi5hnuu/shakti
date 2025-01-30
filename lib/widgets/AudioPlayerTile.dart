import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';
import 'package:volume_controller/volume_controller.dart';

import '../pages/common.dart';

class AudioPlayerTile extends StatefulWidget {
  final String audioUrl;
  final String title;
  final VoidCallback onPlay;
  final AudioPlayer? player;
  final VolumeController? volumeController;

  AudioPlayerTile({this.volumeController,this.player,required this.onPlay,required this.title,required this.audioUrl,Key? key}) :super(key: key);

  @override
  AudioPlayerTileState createState() => AudioPlayerTileState();
}

class AudioPlayerTileState extends State<AudioPlayerTile> {
  late final theme=Theme.of(context);

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// Collects the data useful for displaying in a seek bar, using a handy
  /// feature of rx_dart to combine the 3 streams of interest into one.
  Stream<PositionData> get _positionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
          widget.player!.positionStream,
          widget.player!.bufferedPositionStream,
          widget.player!.durationStream,
              (position, bufferedPosition, duration) => PositionData(
              position, bufferedPosition, duration ?? Duration.zero));


  @override
  Widget build(BuildContext context) {
    final bool isActive=widget.player!=null;

    return Container(
      decoration: BoxDecoration(
          boxShadow: [
      BoxShadow(
      color: Colors.grey.withValues(alpha: 0.3),
      offset: Offset(0, 2), // changes the shadow's position
    ),
    ],
          color:widget.player==null ? Colors.white : Colors.greenAccent.withValues(green: 200,alpha: 0.1)
          ,borderRadius: BorderRadius.all(Radius.circular(8.0))),
      child:Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
            title: Text(widget.title,maxLines: 2,overflow: TextOverflow.ellipsis),
            leading: Icon(Icons.music_note),
            trailing: widget.player?.playing!=true ? SizedBox(width: 40,child: StreamBuilder<PlayerState>(
                stream: widget.player?.playerStateStream,
                builder: (context, snapshot) {
                  final playerState = snapshot.data;
                  final processingState = playerState?.processingState;
                  if (isActive && (processingState == ProcessingState.loading ||
                      processingState == ProcessingState.buffering)) {
                    return SpinKitThreeBounce(color: Colors.red,size: 10,);
                  }
                  return IconButton(onPressed: widget.onPlay, icon: Icon(FontAwesomeIcons.play));
                }),) : null,
          ),
          AnimatedSize(
            duration: Duration(milliseconds: 400),
            child:isActive ? Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Column(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Opens volume slider dialog
                      if(widget.volumeController!=null) IconButton(
                        icon: const Icon(Icons.volume_up),
                        onPressed: isActive ? () {
                          showDialog(context: context, builder: (context) {
                            return SimpleDialog(
                              title: Text("Adjust volume",textAlign: TextAlign.center,style: TextStyle(fontFamily: "oxanium",fontWeight: FontWeight.w600),),
                              contentPadding: EdgeInsets.symmetric(horizontal: 0,vertical: 24),
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              children: [StreamBuilder(stream:widget.player!.volumeStream, builder: (context, snapshot) {
                                return Slider(
                                  thumbColor: Colors.green,
                                  activeColor: Colors.green,
                                  divisions: 20,
                                  min: 0.0,
                                  max: 1.0,
                                  value: snapshot.data ?? 0,
                                  onChanged:widget.volumeController!.setVolume,
                                );
                              },)]);
                          });
                        } : null,
                      ),

                      /// This StreamBuilder rebuilds whenever the player state changes, which
                      /// includes the playing/paused state and also the
                      /// loading/buffering/ready state. Depending on the state we show the
                      /// appropriate button or loading indicator.
                      StreamBuilder<PlayerState>(
                        stream: widget.player!.playerStateStream,
                        builder: (context, snapshot) {
                          final playerState = snapshot.data;
                          final processingState = playerState?.processingState;
                          final playing = playerState?.playing;
                          if (processingState == ProcessingState.loading ||
                              processingState == ProcessingState.buffering) {
                            return Container(
                              margin: const EdgeInsets.all(8.0),
                              width: 64.0,
                              height: 64.0,
                              child: const CircularProgressIndicator(),
                            );
                          } else if (playing != true) {
                            return IconButton(
                              icon: const Icon(Icons.play_arrow),
                              iconSize: 64.0,
                              onPressed: widget.onPlay,
                            );
                          } else if (processingState != ProcessingState.completed) {
                            return IconButton(
                              icon: const Icon(Icons.pause),
                              iconSize: 64.0,
                              onPressed: widget.player!.pause,
                            );
                          } else {
                            return IconButton(
                              icon: const Icon(Icons.replay),
                              iconSize: 64.0,
                              onPressed: () => widget.player!.seek(Duration.zero),
                            );
                          }
                        },
                      ),
                      // Opens speed slider dialog
                      StreamBuilder<double>(
                        stream: widget.player!.speedStream,
                        builder: (context, snapshot) => IconButton(
                          icon: Text("${snapshot.data?.toStringAsFixed(1)}x",style: TextStyle(fontWeight: FontWeight.bold,color: isActive ? Colors.black : Colors.grey),),
                          onPressed: isActive ? () {

                            showDialog(context: context, builder: (context) {
                              return SimpleDialog(
                                  title: Text("Adjust speed",textAlign: TextAlign.center,style: TextStyle(fontFamily: "oxanium",fontWeight: FontWeight.w600),),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 0,vertical: 24),
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  children: [StreamBuilder(stream:widget.player!.speedStream, builder: (context, snapshot) {
                                    return Column(
                                      children: [
                                        Text('Speed ${widget.player!.speed.toStringAsFixed(1)}'),
                                        Slider(
                                          thumbColor: Colors.green,
                                          activeColor: Colors.green,
                                          divisions: 20,
                                          min: 0.5,
                                          max: 2,
                                          value: widget.player!.speed,
                                          onChanged: widget.player!.setSpeed,
                                        )
                                      ],
                                    );
                                  },)]);
                            },);
                          }:null,
                        ),
                      ),
                    ],
                  ),

                  // Display seek bar. Using StreamBuilder, this widget rebuilds
                  // each time the position, buffered position or duration changes.
                  StreamBuilder<PositionData>(
                    stream: _positionDataStream,
                    builder: (context, snapshot) {
                      final positionData = snapshot.data;
                      return SeekBar(
                        duration: positionData?.duration ?? Duration.zero,
                        position: positionData?.position ?? Duration.zero,
                        bufferedPosition:
                        positionData?.bufferedPosition ?? Duration.zero,
                        onChangeEnd: widget.player!.seek,
                      );
                    },
                  ),
                ],
              ),
            ) : const SizedBox.shrink(),
          )
        ],
      ),
    );
  }
}