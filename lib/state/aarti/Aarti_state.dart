part of 'Aarti_bloc.dart';

@Immutable("cannot modify Auth state")
class AartiState extends Equatable with WithHttpState {
  static const int PAGE_SIZE=20;
  final Map<int,List<Aarti>> aartis;//page-wise aarti's
  final int? totalItems;


  AartiState({this.aartis=const {},
    this.totalItems,
    Map<String,HttpState>? httpStates}){
    this.httpStates.addAll(httpStates ?? {});
  }

  AartiState.initial() : this(httpStates: const {});

  AartiState copyWith({Map<String, HttpState>? httpStates,Map<int,List<Aarti>>? aartis,int? totalItems}) {
    return AartiState(
        httpStates: httpStates ?? this.httpStates,
        totalItems:totalItems ?? this.totalItems,
        aartis: aartis ?? this.aartis
    );
  }

  int totalAartis(){
    int length=0;
    for(final entry in aartis.entries){
      length+=entry.value.length;
    }
    return length;
  }

  get totalPages{
    return totalItems==null ? 0 : (totalItems!/PAGE_SIZE).ceil();
  }

  canLoadPage({required int pageNo}){
    assert(pageNo>=1);

    final curTotal=totalAartis();
    if(aartis.containsKey(pageNo) || isLoading(forr: HttpStates.ALL_AARTI) || totalItems==0 || curTotal==totalItems) return false;
    return pageNo==1 || (totalItems!=null && (curTotal/PAGE_SIZE).ceil()+1==pageNo && pageNo<=totalPages);
  }

  @override
  List<Object?> get props => [httpStates,aartis];
}
