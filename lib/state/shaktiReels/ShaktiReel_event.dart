part of 'ShaktiReel_bloc.dart';

@immutable
abstract class ShaktiReelEvent {
  final CancelToken? cancelToken;
  const ShaktiReelEvent({this.cancelToken});
}

class FetchShaktiReelsEvent extends ShaktiReelEvent {
  final int pageNo;
  const FetchShaktiReelsEvent({required this.pageNo,super.cancelToken});
}

