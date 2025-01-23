part of 'Admin_bloc.dart';

@immutable
abstract class AdminEvent {
  final CancelToken? cancelToken;
  const AdminEvent({this.cancelToken});
}

class PaginatedUsersEvent extends AdminEvent{
  final int pageNo;
  final int pageSize;

  const PaginatedUsersEvent({required this.pageNo,required this.pageSize,super.cancelToken});
}

class UserInfoEvent extends AdminEvent{
  final String userId;

  const UserInfoEvent({required this.userId,super.cancelToken});
}

class DeleteUserEvent extends AdminEvent{
  final String userId;

  const DeleteUserEvent({required this.userId,super.cancelToken});
}

class AddRoleEvent extends AdminEvent{
  final String userId;
  final UserRole role;

  const AddRoleEvent({required this.userId,required this.role,super.cancelToken});
}
