part of 'Aarti_bloc.dart';

@immutable
abstract class AartiEvent {
  final CancelToken? cancelToken;
  const AartiEvent({this.cancelToken});
}

class FetchAllAartiEvent extends AartiEvent {
  final int pageNo;
  const FetchAllAartiEvent({required this.pageNo,super.cancelToken});
}

