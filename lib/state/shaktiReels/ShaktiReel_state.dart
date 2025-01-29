part of 'ShaktiReel_bloc.dart';

@Immutable("cannot modify Shakti Reel state")
class ShaktiReelState extends Equatable with WithHttpState {
  static const int PAGE_SIZE=20;
  final Map<int,List<Reel>> reels;//page-wise aarti's
  final int? totalItems;


  ShaktiReelState({
    this.reels=const {},
    this.totalItems,
    Map<String,HttpState>? httpStates}){
    this.httpStates.addAll(httpStates ?? {});
  }

  ShaktiReelState.initial() : this(httpStates: const {});

  ShaktiReelState copyWith({Map<String, HttpState>? httpStates,Map<int,List<Reel>>? reels,int? totalItems}) {
    return ShaktiReelState(
        httpStates: httpStates ?? this.httpStates,
        totalItems:totalItems ?? this.totalItems,
        reels: reels ?? this.reels
    );
  }

  int totalReels(){
    int length=0;
    for(final entry in reels.entries){
      length+=entry.value.length;
    }
    return length;
  }

  List<Reel> allReels(){
    return reels.values.expand((pageReels) => pageReels).toList();
  }

  get totalPages{
    return totalItems==null ? 0 : (totalItems!/PAGE_SIZE).ceil();
  }

  canLoadPage({required int pageNo}){
    assert(pageNo>=1);

    final curTotal=totalReels();
    if(reels.containsKey(pageNo) || isLoading(forr: HttpStates.ALL_REEL) || totalItems==0 || curTotal==totalItems) return false;
    return pageNo==1 || (totalItems!=null && (curTotal/PAGE_SIZE).ceil()+1==pageNo && pageNo<=totalPages);
  }

  @override
  List<Object?> get props => [httpStates,reels,totalItems];
}
