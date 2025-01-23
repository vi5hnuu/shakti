class HttpState<T>{
  final bool? loading;
  final bool? done;
  final String? error;
  final T? value;

  const HttpState._({this.loading=false,this.error,this.value,this.done}):assert(loading!=null || error!=null || value!=null);
  const HttpState.loading():this._(loading: true);
  const HttpState.error({required String? error}):this._(error: error);
  const HttpState.done():this._(done: true);
  const HttpState.value({required T value}):this._(value: value);
}