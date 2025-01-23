import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:shakti/extensions/map-entensions.dart';
import 'package:shakti/models/ApiResponse.dart';
import 'package:shakti/models/Pageable.dart';
import 'package:shakti/models/User.dart';
import 'package:shakti/models/enums/UserRole.dart';
import 'package:shakti/models/requestPayload/AddRole.dart';
import 'package:shakti/services/AuthApi.dart';
import '../../models/HttpState.dart';
import '../WithHttpState.dart';
import '../httpStates.dart';

part 'Admin_event.dart';
part 'Admin_state.dart';

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  AdminBloc({required AuthApi authApi}) : super(AdminState.initial()) {
    on<PaginatedUsersEvent>((event, emit) async {
      emit(state.copyWith(httpStates:  state.httpStates.clone()..put(HttpStates.PAGINATED_USERS,const HttpState.loading())));
      try {
        ApiResponse<Pageable<User>> res = await authApi.getPaginatedUsers(pageNo: event.pageNo,pageSize: event.pageSize, cancelToken: event.cancelToken);
        emit(state.copyWith(users: res.data!.data, message: res.message,httpStates: state.httpStates.clone()..remove(HttpStates.PAGINATED_USERS)));
      } on DioException catch (e) {
        emit(state.copyWith(httpStates: state.httpStates.clone()..put(HttpStates.PAGINATED_USERS, HttpState.error(error: e.message))));
      } catch (e) {
        emit(state.copyWith(httpStates: state.httpStates.clone()..put(HttpStates.PAGINATED_USERS, HttpState.error(error: e.toString()))));
      }
    });

    on<UserInfoEvent>((event, emit) async {
      emit(state.copyWith(httpStates:  state.httpStates.clone()..put(HttpStates.USER_INFO,const HttpState.loading())));
      try {
        ApiResponse<User> res = await authApi.getUserInfo(userId: event.userId, cancelToken: event.cancelToken);
        emit(state.copyWith(users: [res.data!], message: res.message,httpStates: state.httpStates.clone()..remove(HttpStates.USER_INFO)));
      } on DioException catch (e) {
        emit(state.copyWith(httpStates: state.httpStates.clone()..put(HttpStates.USER_INFO, HttpState.error(error: e.message))));
      } catch (e) {
        emit(state.copyWith(httpStates: state.httpStates.clone()..put(HttpStates.USER_INFO, HttpState.error(error: e.toString()))));
      }
    });

    on<DeleteUserEvent>((event, emit) async {
      emit(state.copyWith(httpStates:  state.httpStates.clone()..put(HttpStates.DELETE_USER,const HttpState.loading())));
      try {
        ApiResponse<void> res = await authApi.deleteUser(userId: event.userId, cancelToken: event.cancelToken);
        emit(state.copyWith(message: res.message,httpStates: state.httpStates.clone()..remove(HttpStates.DELETE_USER)));
      } on DioException catch (e) {
        emit(state.copyWith(httpStates: state.httpStates.clone()..put(HttpStates.DELETE_USER, HttpState.error(error: e.message))));
      } catch (e) {
        emit(state.copyWith(httpStates: state.httpStates.clone()..put(HttpStates.DELETE_USER, HttpState.error(error: e.toString()))));
      }
    });

    on<AddRoleEvent>((event, emit) async {
      emit(state.copyWith(httpStates:  state.httpStates.clone()..put(HttpStates.ADD_ROLE,const HttpState.loading())));
      try {
        ApiResponse<User> res = await authApi.addRole(role: AddRole(userId: event.userId,role: event.role), cancelToken: event.cancelToken);
        emit(state.copyWith(users: [res.data!], message: res.message,httpStates: state.httpStates.clone()..remove(HttpStates.ADD_ROLE)));
      } on DioException catch (e) {
        emit(state.copyWith(httpStates: state.httpStates.clone()..put(HttpStates.ADD_ROLE, HttpState.error(error: e.message))));
      } catch (e) {
        emit(state.copyWith(httpStates: state.httpStates.clone()..put(HttpStates.ADD_ROLE, HttpState.error(error: e.toString()))));
      }
    });
  }
}
