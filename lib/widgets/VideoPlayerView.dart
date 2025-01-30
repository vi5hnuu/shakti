import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:native_video_player/native_video_player.dart';
import 'package:volume_controller/volume_controller.dart';

import '../models/Reel.dart';

class VideoPlayerView extends StatefulWidget {
  final Reel reel;

  const VideoPlayerView({
    super.key,
    required this.reel,
  });

  @override
  State<VideoPlayerView> createState() => _VideoPlayerViewState();
}

class _VideoPlayerViewState extends State<VideoPlayerView> {
  NativeVideoPlayerController? _controller;
  late final md=MediaQuery.of(context);
  bool isAutoplayEnabled = true;
  bool isPlaybackLoopEnabled = true;

  @override
  void didUpdateWidget(VideoPlayerView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.reel != widget.reel) {
      _loadVideoSource();
    }
  }

  Future<void> _initController(NativeVideoPlayerController controller) async {
    setState(() => _controller = controller);
    _controller?.onPlaybackStatusChanged.addListener(_onPlaybackStatusChanged);
    _controller?.onPlaybackPositionChanged.addListener(_onPlaybackPositionChanged);
    _controller?.onPlaybackSpeedChanged.addListener(_onPlaybackSpeedChanged);
    _controller?.onVolumeChanged.addListener(_onPlaybackVolumeChanged);
    _controller?.onPlaybackReady.addListener(_onPlaybackReady);
    _controller?.onPlaybackEnded.addListener(_onPlaybackEnded);
    await _loadVideoSource();
  }

  Future<void> _loadVideoSource() async {
    final videoSource = await _createVideoSource();
    await _controller!.loadVideoSource(videoSource);
  }

  Future<VideoSource> _createVideoSource() async {
    return VideoSource.init(
        path: Uri.parse(widget.reel.videoUrl).toString(),
        type: VideoSourceType.network
    );
  }

  @override
  void dispose() {
    _controller?.onPlaybackStatusChanged.removeListener(_onPlaybackStatusChanged);
    _controller?.onPlaybackPositionChanged.removeListener(_onPlaybackPositionChanged);
    _controller?.onPlaybackSpeedChanged.removeListener(_onPlaybackSpeedChanged);
    _controller?.onVolumeChanged.removeListener(_onPlaybackVolumeChanged);
    _controller?.onPlaybackReady.removeListener(_onPlaybackReady);
    _controller?.onPlaybackEnded.removeListener(_onPlaybackEnded);
    _controller = null;
    super.dispose();
  }

  void _onPlaybackReady() async{
    setState(() {});
    if (isAutoplayEnabled) {
      _controller?.setVolume(await VolumeController.instance.getVolume());
      _controller?.play();
    }
  }

  void _onPlaybackStatusChanged() {
    setState(() {});
  }

  void _onPlaybackPositionChanged() {
    setState(() {});
  }

  void _onPlaybackSpeedChanged() {
    setState(() {});
  }

  void _onPlaybackVolumeChanged() {
    setState(() {});
  }

  void _onPlaybackEnded() {
    if (isPlaybackLoopEnabled) {
      _controller?.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      alignment: Alignment.bottomCenter,
      children: [
        Flex(direction: Axis.vertical,
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AspectRatio(
                    aspectRatio:_controller?.videoInfo?.aspectRatio!=null ? 1/(_controller?.videoInfo?.aspectRatio ?? 1) : 9 /16,
                    child: NativeVideoPlayerView(
                      onViewReady: _initController,
                    ),
                  )
                ],
              ),
            ),
            if(_controller!=null) ValueListenableBuilder(valueListenable: _controller!.onPlaybackPositionChanged,builder: (context, value, child) => LinearProgressIndicator(color: Colors.green,value: value.toDouble()/(_controller!.videoInfo?.duration ?? 1)),)
          ],),
        Positioned(top: md.size.height/2,right: 15,child: Container(
          decoration: BoxDecoration(color: Colors.grey.shade50.withValues(alpha: 0.3),borderRadius: BorderRadius.circular(1000)),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                RotatedBox(
                  quarterTurns: 3,
                  child: Slider(
                    value: _controller?.playbackInfo?.speed ?? 1,
                    onChanged: (value) => _controller?.setPlaybackSpeed(value),
                    min: 0.25,
                    max: 2,
                    thumbColor: Colors.green,
                    activeColor: Colors.green,
                    divisions: (2 - 0.25) ~/ 0.25,
                  ),
                ),
                Icon(Icons.speed,color: Colors.white),
              ],
            ),
          ),
        )),
        Positioned(bottom: 100,child: Container(
          decoration: BoxDecoration(color: Colors.grey.shade50.withValues(alpha: 0.3),borderRadius: BorderRadius.circular(1000)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Row(
              //   children: [
              //     Checkbox(
              //       value: isAutoplayEnabled,
              //       onChanged: (value) {
              //         setState(() => isAutoplayEnabled = value ?? false);
              //       },
              //     ),
              //     const Text('Autoplay'),
              //     const SizedBox(width: 24),
              //     Checkbox(
              //       value: isPlaybackLoopEnabled,
              //       onChanged: (value) {
              //         setState(() => isPlaybackLoopEnabled = value ?? false);
              //       },
              //     ),
              //     const Text('Playback loop'),
              //   ],
              // ),
              // const SizedBox(height: 4),
              // Text('${formatDuration(Duration(seconds: _controller?.playbackInfo?.position ?? 0))}/${formatDuration(Duration(seconds: _controller?.videoInfo?.duration ?? 0))}'),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  IconButton(
                    icon: const Icon(Icons.play_arrow,color: Colors.white,),
                    onPressed: () => _controller?.play(),
                  ),
                  IconButton(
                    icon: const Icon(Icons.pause,color: Colors.white,),
                    onPressed: () => _controller?.pause(),
                  ),
                  IconButton(
                    icon: const Icon(Icons.stop,color: Colors.white,),
                    onPressed: () => _controller?.stop(),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.fast_rewind,color: Colors.white,),
                    onPressed: () => _controller?.seekBackward(5),
                  ),
                  IconButton(
                    icon: const Icon(Icons.fast_forward,color: Colors.white,),
                    onPressed: () => _controller?.seekForward(5),
                  ),
                ],
              ),
              // const Spacer(),
              // _buildPlaybackStatusView(),
        //       if(_controller!=null) Row(
        //         children: [
        //           Text('''
        // Volume: ${_controller?.playbackInfo?.volume.toStringAsFixed(2)}'''),
        //           Expanded(
        //               child:ValueListenableBuilder(valueListenable: _controller!.onVolumeChanged, builder: (context, value, child) {
        //                 return Slider(
        //                   value:  value,
        //                   onChanged: (value) => _controller?.setVolume(value),
        //                 );
        //               },)
        //           ),
        //         ],
        //       ),
            ],
          ),
        ))
      ],
    );
  }

  Widget _buildPlaybackStatusView() {
    const size = 16.0;
    final color = Colors.black.withValues(alpha: 0.3);
    switch (_controller?.playbackInfo?.status) {
      case PlaybackStatus.playing:
        return Icon(Icons.play_arrow, size: size, color: color);
      case PlaybackStatus.paused:
        return Icon(Icons.pause, size: size, color: color);
      case PlaybackStatus.stopped:
        return Icon(Icons.stop, size: size, color: color);
      default:
        return Container();
    }
  }
}


String formatDuration(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  final twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
  final twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
  return '$twoDigitMinutes:$twoDigitSeconds';
}