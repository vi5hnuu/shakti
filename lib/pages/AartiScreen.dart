import 'package:just_audio/just_audio.dart';
import 'package:shakti/singletons/NotificationService.dart';
import 'package:shakti/singletons/PlayerSingleton.dart';
import 'package:shakti/state/aarti/Aarti_bloc.dart';
import 'package:shakti/widgets/AudioPlayerTile.dart';
import 'package:shakti/widgets/RetryAgain.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:volume_controller/volume_controller.dart';

import '../state/httpStates.dart';

class AartiScreen extends StatefulWidget {
  const AartiScreen({super.key});

  @override
  State<AartiScreen> createState() => _AartiScreenState();
}

class _AartiScreenState extends State<AartiScreen> with WidgetsBindingObserver{
  late final aartiBloc=BlocProvider.of<AartiBloc>(context);
  final ScrollController _scrollController = ScrollController();
  CancelToken cancelToken = CancelToken();
  int pageNo = 1;
  final VolumeController volumeController=VolumeController.instance;

  //
  final playerInstance = AppPlayer();
  bool isActive=false;

  AudioPlayer get player{
    return playerInstance.player;
  }

  Future<void> _play({required String audioUrl}) async {
    // Inform the operating system of our app's audio attributes etc.
    // We pick a reasonable default for an app that plays speech.
    // final session = await AudioSession.instance;
    // await session.configure(const AudioSessionConfiguration.speech());

    // Try to load audio from a source and catch any errors.
    try {
      await playerInstance.resetPlayList();
      await playerInstance.addToQueue(audioUrl: audioUrl);
    } on PlayerException catch (e) {
      print("Error loading audio source: $e");
    }
  }
  //

  void modifyVolume(volume) {
    player.setVolume(volume);
  }

  @override
  void initState() {
    volumeController.showSystemUI=true;

    // Listen for volume changes and update the player volume
    volumeController.addListener(modifyVolume);

    _loadPage(pageNo: pageNo);
    _scrollController.addListener(_loadNextPage);

    //
    WidgetsBinding.instance.addObserver(this);


    // player.playingStream.listen((playing) {
    //   if(mounted) setState(() =>isActive=playing && isCurrentSourceActive);
    // });
    // Listen to errors during playback.
    player.playbackEventStream.listen((event) {

    },
        onError: (Object e, StackTrace stackTrace) {
          print('A stream error occurred: $e');
        });
    //
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: BlocBuilder<AartiBloc, AartiState>(
          buildWhen: (previous, current) => previous != current,
          builder: (context, state) {
            final allPageAarti=state.aartis.values.expand((pageAarti) => pageAarti).toList();

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Flex(
                direction: Axis.vertical,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                   Expanded(child: Flex(direction: Axis.vertical,children: [
                     if (allPageAarti.isNotEmpty) Expanded(
                         child: StreamBuilder<String?>(stream: AppPlayer().currentSourceStream, builder: (context, snapshot){
                           return  ListView.builder(
                             padding: const EdgeInsets.symmetric(vertical: 8),
                             controller: _scrollController,
                             itemCount: state.totalAartis(),
                             itemBuilder: (context, index) {
                               final aarti = allPageAarti[index];
                               return Padding(
                                 padding: const EdgeInsets.symmetric(vertical: 2),
                                 child: AudioPlayerTile(volumeController: volumeController,onPlay:()=> _play(audioUrl: aarti.audioUrl),player: Uri.parse(aarti.audioUrl).toString()==snapshot.data ? player : null,title: aarti.title,audioUrl: aarti.audioUrl),
                               );
                             },
                           );
            },),
                       )
                     else if(!state.isLoading(forr: HttpStates.ALL_AARTI) && !state.isError(forr: HttpStates.ALL_AARTI)) Text("No Aarti found",style: TextStyle(color: Colors.grey,fontSize: 24)),
                     Container(
                       child: (state.isLoading(forr: HttpStates.ALL_AARTI))
                           ? Padding(
                           padding: const EdgeInsets.symmetric(vertical: 20),
                           child: SpinKitThreeBounce(
                               color: Theme.of(context).primaryColor, size: 24))
                           : ((state.isError(forr: HttpStates.ALL_AARTI))
                           ? RetryAgain(
                           onRetry: ()=> _loadPage(pageNo: pageNo),
                           error: state
                               .getError(forr: HttpStates.ALL_AARTI)!)
                           : null),
                     )
                  ],)),
                ],
              ),
            );
          },
        ));
  }

  Future<void> _openUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
    } else {
      NotificationService.showSnackbar(text: "Failed to open page");
    }
  }

  void _loadPage({required int pageNo}) {
    aartiBloc.add(FetchAllAartiEvent(pageNo: pageNo,cancelToken: cancelToken));
  }

  void _loadNextPage() {
    double maxScrollExtent = _scrollController.position.maxScrollExtent;
    double currentScrollPosition = _scrollController.position.pixels;
    // Calculate the scroll percentage
    double scrollPercentage = currentScrollPosition / maxScrollExtent;
    // Check if scroll percentage is greater than or equal to 80%
    if (scrollPercentage <= 0.8 || !aartiBloc.state.canLoadPage(pageNo: pageNo+1)) return;
    setState(() => _loadPage(pageNo: ++pageNo));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    volumeController.removeListener();

    cancelToken.cancel("cancelling vrat katha page info fetch");
    _scrollController.removeListener(_loadNextPage);
    _scrollController.dispose();
    super.dispose();
  }




  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // Release the player's resources when not in use. We use "stop" so that
      // if the app resumes later, it will still remember what position to
      // resume from.
      player.stop();
    }
  }

}
