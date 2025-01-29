import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:shakti/constants/Constants.dart';
import 'package:shakti/extensions/map-entensions.dart';
import 'package:shakti/models/ApiResponse.dart';
import 'package:shakti/models/User.dart';
import 'package:shakti/models/requestPayload/Register.dart';
import 'package:shakti/models/requestPayload/ResetPassword.dart';
import 'package:shakti/models/requestPayload/UpdatePassword.dart';
import 'package:shakti/services/AuthApi.dart';
import 'package:shakti/singletons/SecureStorage.dart';
import 'package:shakti/streams/auth-global-dispatcher.dart';
import '../../models/HttpState.dart';
import '../../models/requestPayload/LoginManual.dart';
import '../../singletons/DioSingleton.dart';
import '../WithHttpState.dart';
import '../httpStates.dart';

part 'Auth_event.dart';
part 'Auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  StreamSubscription<GlobalEvent>? subscription;

  AuthBloc({required AuthApi authApi}) : super(AuthState.initial()) {
    subscription=(globalEventDispatcher.stream as Stream<GlobalEvent>).listen((event) {
      if(event is LogOutInitEvent) add(const LogoutEvent());
    });

    on<TryAuthenticatingEvent>((event, emit) async {
      emit(AuthState.initial().copyWith(httpStates:  state.httpStates.clone()..put(HttpStates.TRY_AUTH,const HttpState.loading())));
      try {
        final cookie = await _getCookie();
        final isValidCookie = _isCookieValid(cookie);
        if(!isValidCookie) await _clearCookies();
        if(isValidCookie) DioSingleton().addCookie(Constants.jwtCookieKey, cookie!); //add cookie for further requests
        ApiResponse<User> res = await authApi.getMeInfo(cancelToken: event.cancelToken);
        emit(state.copyWith(user: res.data,httpStates:state.httpStates.clone()..put(HttpStates.TRY_AUTH,HttpState.done()), message: res.success ? "logged in successfully" : null));
      } on DioException catch (e) {
        emit(state.copyWith(httpStates: state.httpStates.clone()..put(HttpStates.TRY_AUTH, HttpState.error(error: e.response?.data?['error'] ?? e.response?.data?['message'] ?? e.message))));
      } catch (e) {
        emit(state.copyWith(httpStates: state.httpStates.clone()..put(HttpStates.TRY_AUTH, HttpState.error(error: e.toString()))));
      }
    });

    on<LoginEvent>((event, emit) async {
      emit(state.copyWith(httpStates:  state.httpStates.clone()..put(HttpStates.CUSTOM_LOGIN,const HttpState.loading())));
      try {
        ApiResponse<User> res = await authApi.login(loginManual: LoginManual(usernameEmail: event.usernameEmail, password: event.password), cancelToken: event.cancelToken);
        emit(state.copyWith(user: res.data, message: res.message,httpStates: state.httpStates.clone()..put(HttpStates.CUSTOM_LOGIN,HttpState.done())));
      } on DioException catch (e) {
        emit(state.copyWith(httpStates: state.httpStates.clone()..put(HttpStates.CUSTOM_LOGIN, HttpState.error(error: e.response?.data?['error'] ?? e.response?.data?['message'] ?? e.message))));
      } catch (e) {
        emit(state.copyWith(httpStates: state.httpStates.clone()..put(HttpStates.CUSTOM_LOGIN, HttpState.error(error: e.toString()))));
      }
    });

    on<GoogleLoginEvent>((event, emit) async {
      emit(state.copyWith(httpStates:  state.httpStates.clone()..put(HttpStates.GOOGLE_LOGIN,const HttpState.loading())));
      try {
        ApiResponse<User> res = await authApi.loginGoogle(idToken: event.idToken, cancelToken: event.cancelToken);
        emit(state.copyWith(user: res.data, message: res.message,httpStates: state.httpStates.clone()..put(HttpStates.GOOGLE_LOGIN,HttpState.done())));
      } on DioException catch (e) {
        emit(state.copyWith(httpStates: state.httpStates.clone()..put(HttpStates.GOOGLE_LOGIN, HttpState.error(error: e.response?.data?['error'] ?? e.response?.data?['message'] ?? e.message))));
      } catch (e) {
        emit(state.copyWith(httpStates: state.httpStates.clone()..put(HttpStates.GOOGLE_LOGIN, HttpState.error(error: e.toString()))));
      }
    });

    on<JwtVerifyEvent>((event, emit) async {
      emit(state.copyWith(httpStates:  state.httpStates.clone()..put(HttpStates.JWT_VERIFY,const HttpState.loading())));
      try {
        String message = await authApi.jwtVerify(cancelToken: event.cancelToken);
        emit(state.copyWith(message: message,httpStates: state.httpStates.clone()..put(HttpStates.JWT_VERIFY,HttpState.done())));
      } on DioException catch (e) {
        emit(state.copyWith(httpStates: state.httpStates.clone()..put(HttpStates.JWT_VERIFY, HttpState.error(error: e.response?.data?['error'] ?? e.response?.data?['message'] ?? e.message))));
      } catch (e) {
        emit(state.copyWith(httpStates: state.httpStates.clone()..put(HttpStates.JWT_VERIFY, HttpState.error(error: e.toString()))));
      }
    });

    on<FetchMeInfoEvent>((event, emit) async {
      if (state.userInfo != null) return emit(state.copyWith(httpStates: state.httpStates.clone()..remove(HttpStates.ME_INFO)));
      emit(state.copyWith(httpStates: state.httpStates.clone()..put(HttpStates.ME_INFO,const HttpState.loading())));
      try {
        ApiResponse<User> res = await authApi.getMeInfo(cancelToken: event.cancelToken);
        emit(state.copyWith(httpStates: state.httpStates.clone()..put(HttpStates.ME_INFO,HttpState.done()), user: res.data, message: res.message));
      } on DioException catch (e) {
        emit(state.copyWith(httpStates: state.httpStates.clone()..put(HttpStates.ME_INFO, HttpState.error(error: e.response?.data?['error'] ?? e.response?.data?['message'] ?? e.message))));
      } catch (e) {
        emit(state.copyWith(httpStates: state.httpStates.clone()..put(HttpStates.ME_INFO, HttpState.error(error: e.toString()))));
      }
    });

    on<RegisterEvent>((event, emit) async {
      emit(AuthState().copyWith(httpStates: state.httpStates.clone()..put(HttpStates.REGISTER,const HttpState.loading())));
      try {
        ApiResponse res = await authApi.register(
          register: Register(
            firstName: event.firstName,
            lastName: event.lastName,
            userName: event.username,
            email: event.email,
            password: event.password),
            cancelToken: event.cancelToken);
        emit(AuthState(httpStates: state.httpStates.clone()..put(HttpStates.REGISTER,HttpState.done()), message: res.message));
      } on DioException catch (e) {
        emit(state.copyWith(httpStates: state.httpStates.clone()..put(HttpStates.REGISTER, HttpState.error(error: e.response?.data?['error'] ?? e.response?.data?['message'] ?? e.message))));
      } catch (e) {
        emit(state.copyWith(httpStates: state.httpStates.clone()..put(HttpStates.REGISTER, HttpState.error(error: e.toString()))));
      }
    });

    on<LogoutEvent>((event, emit) async {
      emit(state.copyWith(httpStates: state.httpStates.clone()..put(HttpStates.LOG_OUT,const HttpState.loading())));
      try {
        final res = await authApi.logout(cancelToken: event.cancelToken);
        _clearCookies();
        emit(AuthState.initial());
        globalEventDispatcher.dispatch(event: LogOutCompleteEvent());
      } on DioException catch (e) {
        emit(state.copyWith(httpStates: state.httpStates.clone()..put(HttpStates.LOG_OUT, HttpState.error(error: e.response?.data?['error'] ?? e.response?.data?['message'] ?? e.message))));
      } catch (e) {
        emit(state.copyWith(httpStates: state.httpStates.clone()..put(HttpStates.LOG_OUT, HttpState.error(error: e.toString()))));
      }
    });

    on<ForgotPasswordEvent>((event, emit) async {
      emit(AuthState().copyWith(httpStates: state.httpStates.clone()..put(HttpStates.FORGOT_PASSWORD,const HttpState.loading())));
      try {
        final res = await authApi.forgotPassword(usernameEmail: event.usernameEmail, cancelToken: event.cancelToken);
        emit(AuthState(httpStates: state.httpStates.clone()..put(HttpStates.FORGOT_PASSWORD,HttpState.done()),message: res.message));
      } on DioException catch (e) {
        emit(state.copyWith(httpStates: state.httpStates.clone()..put(HttpStates.FORGOT_PASSWORD, HttpState.error(error: e.response?.data?['error'] ?? e.response?.data?['message'] ?? e.message))));
      } catch (e) {
        emit(state.copyWith(httpStates: state.httpStates.clone()..put(HttpStates.FORGOT_PASSWORD, HttpState.error(error: e.toString()))));
      }
    });

    on<ResetPasswordEvent>((event, emit) async {
      emit(AuthState().copyWith(httpStates: state.httpStates.clone()..put(HttpStates.RESET_PASSWORD,const HttpState.loading())));
      try {
        final res=await authApi.resetPassword(resetPassword: ResetPassword(
          otp: event.otp,
          password: event.password,
          confirmPassword: event.confirmPassword,
          usernameEmail: event.usernameEmail
        ),cancelToken: event.cancelToken);
        emit(AuthState(httpStates: state.httpStates.clone()..put(HttpStates.RESET_PASSWORD,HttpState.done()), message: res.message));
      } on DioException catch (e) {
        emit(state.copyWith(httpStates: state.httpStates.clone()..put(HttpStates.RESET_PASSWORD, HttpState.error(error: e.response?.data?['error'] ?? e.response?.data?['message'] ?? e.message))));
      } catch (e) {
        emit(state.copyWith(httpStates: state.httpStates.clone()..put(HttpStates.RESET_PASSWORD, HttpState.error(error: e.toString()))));
      }
    });

    on<UpdatePasswordInitEvent>((event, emit) async {
      emit(state.copyWith(httpStates: state.httpStates.clone()..put(HttpStates.UPDATE_PASSWORD_INIT,const HttpState.loading())));
      try {
        final res = await authApi.updatePasswordInit(usernameEmail:event.usernameEmail,cancelToken: event.cancelToken);
        emit(state.copyWith(httpStates: state.httpStates.clone()..put(HttpStates.UPDATE_PASSWORD_INIT,HttpState.done()), message: res.message));
      } on DioException catch (e) {
        emit(state.copyWith(httpStates: state.httpStates.clone()..put(HttpStates.UPDATE_PASSWORD_INIT, HttpState.error(error: e.response?.data?['error'] ?? e.response?.data?['message'] ?? e.message))));
      } catch (e) {
        emit(state.copyWith(httpStates: state.httpStates.clone()..put(HttpStates.UPDATE_PASSWORD_INIT, HttpState.error(error: e.toString()))));
      }
    });

    on<UpdatePasswordCompleteEvent>((event, emit) async {
      emit(state.copyWith(httpStates: state.httpStates.clone()..put(HttpStates.UPDATE_PASSWORD_COMPLETE,const HttpState.loading())));
      try {
        final res = await authApi.updatePasswordComplete(updatePassword: UpdatePassword(otp: event.otp,oldPassword: event.oldPassword, newPassword: event.newPassword, confirmPassword: event.confirmPassword), cancelToken: event.cancelToken);
        emit(state.copyWith(httpStates: state.httpStates.clone()..put(HttpStates.UPDATE_PASSWORD_COMPLETE,HttpState.done()), message: res.message));
      } on DioException catch (e) {
        emit(state.copyWith(httpStates: state.httpStates.clone()..put(HttpStates.UPDATE_PASSWORD_COMPLETE, HttpState.error(error: e.response?.data?['error'] ?? e.response?.data?['message'] ?? e.message))));
      } catch (e) {
        emit(state.copyWith(httpStates: state.httpStates.clone()..put(HttpStates.UPDATE_PASSWORD_COMPLETE, HttpState.error(error: e.toString()))));
      }
    });

    on<DeleteMeEvent>((event, emit) async {
      emit(state.copyWith(httpStates: state.httpStates.clone()..put(HttpStates.DELETE_ME,const HttpState.loading())));
      try {
        final res = await authApi.deleteMe(cancelToken: event.cancelToken);
        _clearCookies();
        emit(AuthState(httpStates: state.httpStates.clone()..put(HttpStates.DELETE_ME,HttpState.done()), message: res.message));
      } on DioException catch (e) {
        emit(state.copyWith(httpStates: state.httpStates.clone()..put(HttpStates.DELETE_ME, HttpState.error(error: e.response?.data?['error'] ?? e.response?.data?['message'] ?? e.message))));
      } catch (e) {
        emit(state.copyWith(httpStates: state.httpStates.clone()..put(HttpStates.DELETE_ME, HttpState.error(error: e.toString()))));
      }
    });

    on<ReVerifyEvent>((event, emit) async {
      emit(AuthState().copyWith(httpStates: state.httpStates.clone()..put(HttpStates.REVERIFY,const HttpState.loading())));
      try {
        final res = await authApi.reVerify(email: event.email, cancelToken: event.cancelToken);
        emit(AuthState(httpStates: state.httpStates.clone()..put(HttpStates.REVERIFY,HttpState.done()), message: res.message));
      } on DioException catch (e) {
        emit(state.copyWith(httpStates: state.httpStates.clone()..put(HttpStates.REVERIFY, HttpState.error(error: e.response?.data?['error'] ?? e.response?.data?['message'] ?? e.message))));
      } catch (e) {
        emit(state.copyWith(httpStates: state.httpStates.clone()..put(HttpStates.REVERIFY, HttpState.error(error: e.toString()))));
      }
    });
  }

  @override
  Future<void> close() {
    subscription?.cancel();
    return super.close();
  }

  Future<Cookie?> _getCookie() async {
    var cookie = await SecureStorage().storage.read(key: Constants.jwtCookieKey);
    return cookie != null ? Cookie.fromSetCookieValue(cookie) : null;
  }

  _clearCookies() async {
    await SecureStorage().storage.deleteAll();
  }

  bool _isCookieValid(Cookie? cookie) {
    if (cookie == null) return false;
    return cookie.expires!.isAfter(DateTime.now().add(Duration(minutes: 1)));
  }
}
