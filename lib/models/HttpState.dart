class HttpState<T>{
  final bool? loading;
  final bool? done;
  final String? error;
  final T? value;
  final bool isExpired;//state expired

  const HttpState({this.isExpired=false,this.loading=false,this.error,this.value,this.done}):assert(loading!=null || error!=null || value!=null);
  const HttpState.loading():this(loading: true);
  const HttpState.error({required String? error}):this(error: error);
  const HttpState.done():this(done: true);
  const HttpState.value({required T value}):this(value: value);

  HttpState<T> copyWith({
    required bool?  loading,
    required bool? done,
    required String? error,
    required T? value,
    required bool isExpired
}){
    return HttpState<T>(isExpired: isExpired,loading: loading,error: error,value: value,done: done);
  }
}