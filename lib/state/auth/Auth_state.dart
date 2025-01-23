part of 'Auth_bloc.dart';

@Immutable("cannot modify Auth state")
class AuthState extends Equatable with WithHttpState {
  final User? userInfo;
  final String? message;

  AuthState({
    this.userInfo,
    this.message,
    Map<String,HttpState>? httpStates,
  }){
    this.httpStates.addAll(httpStates ?? {});
  }

  AuthState.initial() : this(httpStates: const {});

  AuthState copyWith({Map<String, HttpState>? httpStates,User? user,String? message}) {
    return AuthState(
        httpStates: httpStates ?? this.httpStates,
        userInfo: user ?? userInfo,
        message: message ?? this.message
    );
  }

  @override
  List<Object?> get props => [httpStates,userInfo,message];
}
