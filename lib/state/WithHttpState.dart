import 'package:shakti/models/HttpState.dart';

mixin WithHttpState{
  final Map<String, HttpState> httpStates={};

  bool isLoading({required final String forr}){
    return httpStates.containsKey(forr) && httpStates[forr]?.loading==true;
  }

  bool anyLoading({List<String> forr=const []}){
    if(forr.isEmpty) forr=httpStates.keys.toList();
    for(final key in forr){
      if(httpStates.containsKey(key) && httpStates[key]?.loading==true) return true;
    }
    return false;
  }

  bool anyDone({List<String> forr=const []}){
    if(forr.isEmpty) forr=httpStates.keys.toList();
    for(final key in forr){
      if(httpStates.containsKey(key) && httpStates[key]?.done==true) return true;
    }
    return false;
  }

  bool anyState({required final String forr}){
    return anyLoading(forr: [forr]) || anyError(forr: [forr]);
  }

  bool anyError({List<String> forr=const []}){
    if(forr.isEmpty) forr=httpStates.keys.toList();
    for(final key in forr){
      if(httpStates[key]?.error!=null) return true;
    }
    return false;
  }

  String? getAnyError({List<String> forr=const []}){
    if(forr.isEmpty) forr=httpStates.keys.toList();
        for(final key in forr){
      if(httpStates[key]?.error!=null) return httpStates[key]?.error;
    }
    return null;
  }

  bool isError({required final String forr}){
    return httpStates.containsKey(forr) && httpStates[forr]!.error!=null;
  }

  bool isExpired({required final String forr}){
    return httpStates.containsKey(forr) && httpStates[forr]!.isExpired;
  }

  bool isSuccess({required final String forr}){
    return httpStates.containsKey(forr) && httpStates[forr]!.done==true;
  }

  String? getError({required final String forr}){
    return httpStates[forr]?.error;
  }

  bool hasHttpState({required final String forr}){
    return httpStates[forr]!=null;
  }

  printStates(){
    for(final kv in httpStates.entries){
      print("http state ${kv.key} --> ${kv.value.error}/${kv.value.loading}");
    }
  }
}