part of 'Admin_bloc.dart';

@Immutable("cannot modify Auth state")
class AdminState extends Equatable with WithHttpState {
  final List<User> users;
  final String? message;

  AdminState({
    this.users=const [],
    this.message,
    Map<String,HttpState>? httpStates,
  }){
    this.httpStates.addAll(httpStates ?? {});
  }

  AdminState.initial() : this(httpStates: const {});

  AdminState copyWith({Map<String, HttpState>? httpStates,List<User>? users,String? message}) {
    return AdminState(
        httpStates: httpStates ?? this.httpStates,
        users: users ?? this.users,
        message: message ?? this.message
    );
  }

  @override
  List<Object?> get props => [httpStates,users,message];
}
