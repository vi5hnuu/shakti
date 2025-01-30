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

import '../widgets/ReelShimmer.dart';
import '../widgets/VideoPlayerView.dart';


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
                          if(currentReelNo==index) VideoPlayerView(reel: reels[currentReelNo])
                          else ReelShimmer(),
                          if(currentReelNo==index) Positioned(bottom: 25,left: 15,child: Row(
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