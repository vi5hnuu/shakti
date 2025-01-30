import 'package:flutter_svg/flutter_svg.dart';
import 'package:native_video_player/native_video_player.dart';
import 'package:shakti/models/Reel.dart';
import 'package:shakti/state/httpStates.dart';
import 'package:shakti/state/shaktiReels/ShaktiReel_bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:volume_controller/volume_controller.dart';


final key=ValueKey('VLC');
class ShaktiReelsScreen extends StatefulWidget {
  const ShaktiReelsScreen({super.key});

  @override
  State<ShaktiReelsScreen> createState() => _ShaktiReelsScreenState();
}

class _ShaktiReelsScreenState extends State<ShaktiReelsScreen> {
  late final bloc=BlocProvider.of<ShaktiReelBloc>(context);
  final pageStorageKey = const PageStorageKey('shakti-reels-screen');
  final PageController _controller = PageController(initialPage: 0,viewportFraction: 1);
  CancelToken? token;
  int currentReelNo = 0;
  ValueNotifier<double> progressNotifier=ValueNotifier(0.0);
  bool isInitialized=false;
  final playerKey=ValueKey('Shakti Reel Player');

  @override
  initState() {
    _loadMore(pageNo: 1);
    VolumeController.instance.showSystemUI=true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: BlocBuilder<ShaktiReelBloc, ShaktiReelState>(
          buildWhen: (previous, current) => previous != current,
          builder: (context, state){
            final reels=state.allReels();
            return Flex(direction: Axis.vertical,
            children: [
              if(state.isLoading(forr: HttpStates.ALL_REEL)) LinearProgressIndicator(color: Colors.green)
              else if(state.isError(forr: HttpStates.ALL_REEL)) Expanded(child: Center(child: Text("Error"),))
              else if(reels.isEmpty && state.isSuccess(forr:HttpStates.ALL_REEL)) Expanded(child: Center(child: Text("No Reels found"))),
              if(reels.isNotEmpty) Expanded(child: PageView.builder(
                key: pageStorageKey,
                pageSnapping: true,
                controller: _controller,
                physics: const BouncingScrollPhysics(decelerationRate: ScrollDecelerationRate.fast),
                scrollDirection: Axis.vertical,
                itemCount: reels.length,
                allowImplicitScrolling: true,
                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(color: Colors.black),
                    child: Flex(direction: Axis.vertical,children: [
                      Expanded(child: Stack(
                        fit: StackFit.expand,
                        alignment: Alignment.center,
                        children: [
                          VideoPlayerView(key: playerKey,reel: reels[currentReelNo]),
                          Positioned(bottom: 25,left: 15,child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(backgroundColor: Colors.white,radius: 24,child: SvgPicture.asset("assets/icons/swastik.svg")),
                              SizedBox(width: 15,),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Shakti-Official",style: TextStyle(color: Colors.white,fontSize: 16,fontWeight: FontWeight.w600,fontFamily: "oxanium"),),
                                  Text(reels[index].title,maxLines: 2,overflow: TextOverflow.ellipsis,style: TextStyle(height: 2,color: Colors.white,fontWeight: FontWeight.w600,fontFamily: "oxanium"),),
                                ],
                              )
                            ],
                          ),),
                        ],
                      )),
                      ValueListenableBuilder(valueListenable: progressNotifier, builder: (context, value, child) {
                        return LinearProgressIndicator(value: value,color: Colors.green,backgroundColor: Colors.white);
                      },)
                    ],)
                  );
                },
                dragStartBehavior: DragStartBehavior.down,
                onPageChanged: (reelNo)=>_onPageChanged(reelNo,reels[reelNo].videoUrl),
              ))
            ],);
          },
        ));
  }

  void _loadMore({required int pageNo}) {
    if (!bloc.state.canLoadPage(pageNo: pageNo)) return;
    bloc.add(FetchShaktiReelsEvent(pageNo: pageNo));
  }

  void _onPageChanged(int reelNo,String reelUrl) async{
    if(bloc.state.totalItems!=null && (bloc.state.totalReels()+5>reelNo)) _loadMore(pageNo: bloc.state.reels.length+1);
    setState(()=>currentReelNo = reelNo);
  }

  @override
  void dispose() async{
    _controller.dispose();
    token?.cancel("cancelled");
    super.dispose();
  }
}
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
    _controller?. //
    onPlaybackStatusChanged
        .removeListener(_onPlaybackStatusChanged);
    _controller?. //
    onPlaybackPositionChanged
        .removeListener(_onPlaybackPositionChanged);
    _controller?. //
    onPlaybackSpeedChanged
        .removeListener(_onPlaybackSpeedChanged);
    _controller?. //
    onVolumeChanged
        .removeListener(_onPlaybackVolumeChanged);
    _controller?. //
    onPlaybackReady
        .removeListener(_onPlaybackReady);
    _controller?. //
    onPlaybackEnded
        .removeListener(_onPlaybackEnded);
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
      alignment: Alignment.center,
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
        Column(
          children: [
            Row(
              children: [
                Checkbox(
                  value: isAutoplayEnabled,
                  onChanged: (value) {
                    setState(() => isAutoplayEnabled = value ?? false);
                  },
                ),
                const Text('Autoplay'),
                const SizedBox(width: 24),
                Checkbox(
                  value: isPlaybackLoopEnabled,
                  onChanged: (value) {
                    setState(() => isPlaybackLoopEnabled = value ?? false);
                  },
                ),
                const Text('Playback loop'),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  formatDuration(
                    Duration(seconds: _controller?.playbackInfo?.position ?? 0),
                  ),
                ),
                const Spacer(),
                Text(
                  formatDuration(
                    Duration(seconds: _controller?.videoInfo?.duration ?? 0),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.play_arrow),
                  onPressed: () => _controller?.play(),
                ),
                IconButton(
                  icon: const Icon(Icons.pause),
                  onPressed: () => _controller?.pause(),
                ),
                IconButton(
                  icon: const Icon(Icons.stop),
                  onPressed: () => _controller?.stop(),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.fast_rewind),
                  onPressed: () => _controller?.seekBackward(5),
                ),
                IconButton(
                  icon: const Icon(Icons.fast_forward),
                  onPressed: () => _controller?.seekForward(5),
                ),
                const Spacer(),
                _buildPlaybackStatusView(),
              ],
            ),
            if(_controller!=null) Row(
              children: [
                Text('''
Volume: ${_controller?.playbackInfo?.volume.toStringAsFixed(2)}'''),
                Expanded(

                  child:ValueListenableBuilder(valueListenable: _controller!.onVolumeChanged, builder: (context, value, child) {
                    return Slider(
                    value:  value,
    onChanged: (value) => _controller?.setVolume(value),
    );
                  },)
                ),
              ],
            ),
            Row(
              children: [
                Text('''
Speed: ${_controller?.playbackInfo?.speed.toStringAsFixed(2)}'''),
                Expanded(
                  child: Slider(
                    value: _controller?.playbackInfo?.speed ?? 1,
                    onChanged: (value) => _controller?.setPlaybackSpeed(value),
                    min: 0.25,
                    max: 2,
                    divisions: (2 - 0.25) ~/ 0.25,
                  ),
                ),
              ],
            ),
          ],
        )
      ],
    );
  }

  Widget _buildPlaybackStatusView() {
    const size = 16.0;
    final color = Colors.black.withOpacity(0.3);
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

class ReelShimmer extends StatelessWidget {
  const ReelShimmer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Shimmer.fromColors(
          baseColor: Colors.grey.shade600,
          highlightColor: Colors.grey.shade700,
          child: Container(color: Colors.white),
        ),
        Shimmer.fromColors(
          baseColor: Colors.grey.shade800,
          highlightColor: Colors.grey.shade600,
          child: Stack(
            children: [
              Positioned(
                left: 16,
                bottom: 30,
                child: Row(
                  children: [
                    // Avatar
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // User name placeholder
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 100,
                          height: 12,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 150,
                          height: 12,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Engagement actions
              Positioned(
                right: 16,
                bottom: 40,
                child: Column(
                  children: [
                    // Like button
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Comment button
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Share button
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}

String formatDuration(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  final twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
  final twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
  return '$twoDigitMinutes:$twoDigitSeconds';
}