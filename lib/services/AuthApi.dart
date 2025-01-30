import 'package:dio/dio.dart';
import 'package:shakti/constants/Constants.dart';
import 'package:shakti/models/ApiResponse.dart';
import 'package:shakti/models/Pageable.dart';
import 'package:shakti/models/User.dart';
import 'package:shakti/models/requestPayload/AddRole.dart';
import 'package:shakti/models/requestPayload/LoginManual.dart';
import 'package:shakti/models/requestPayload/ResetPassword.dart';
import 'package:shakti/models/requestPayload/UpdatePassword.dart';
import '../../models/requestPayload/Register.dart';
import '../../singletons/DioSingleton.dart';

class AuthApi {
  static final AuthApi _instance = AuthApi._();
  static const String _getPaginatedUsers = "${Constants.baseUrl}/api/v1/users/all"; //Admin : GET
  static const String _getUserInfo = "${Constants.baseUrl}/api/v1/users/{userId}"; //Admin : GET
  static const String _getMeInfo = "${Constants.baseUrl}/api/v1/users/me"; //GET
  static const String _deleteUser = "${Constants.baseUrl}/api/v1/users/{userId}"; //DELETE
  static const String _deleteMe = "${Constants.baseUrl}/api/v1/users"; //DELETE
  static const String _addRole = "${Constants.baseUrl}/api/v1/users/add-role"; //PATCH
  static const String _updatePasswordInit = "${Constants.baseUrl}/api/v1/users/password/init"; //POST
  static const String _updatePasswordComplete = "${Constants.baseUrl}/api/v1/users/password/complete"; //PATCH
  static const String _login = "${Constants.baseUrl}/api/v1/users/login"; //POST
  static const String _loginGoogle = "${Constants.baseUrl}/api/v1/users/login/google"; //POST
  static const String _logout = "${Constants.baseUrl}/api/v1/users/logout"; //GET
  static const String _register = "${Constants.baseUrl}/api/v1/users/register"; //POST
  static const String _reVerify = "${Constants.baseUrl}/api/v1/users/re-verify"; //GET
  static const String _verify = "${Constants.baseUrl}/api/v1/users/verify"; //GET
  static const String _jwtVerify = "${Constants.baseUrl}/api/v1/users/jwt/verify"; //POST
  static const String _forgotPassword = "${Constants.baseUrl}/api/v1/users/forgot-password"; //POST
  static const String _resetPassword = "${Constants.baseUrl}/api/v1/users/reset-password"; //POST

  AuthApi._();

  factory AuthApi() {
    return _instance;
  }

  Future<ApiResponse<Pageable<User>>> getPaginatedUsers({required int pageNo,int pageSize=20,CancelToken? cancelToken}) async {
    var url = '$_getPaginatedUsers?pageNo=$pageNo&count=$pageSize';
    var res = await DioSingleton().dio.get(url,cancelToken:cancelToken);
    final apiRes=res.data;
    final pageData=apiRes['data'];
    final page=Pageable<User>(data: (pageData['data'] as List).map((item)=>User.fromJson(item)).toList(), pageNo: pageData['pageNo'], totalItems: pageData['totalItems']);

    return ApiResponse(success: apiRes['success'],data: page,message: apiRes['message']);
  }

  Future<ApiResponse<User>> getUserInfo({required String userId,CancelToken? cancelToken}) async {
    var url = _getUserInfo.replaceFirst('{userId}', userId);
    var res = await DioSingleton().dio.get(url,cancelToken:cancelToken);
    return ApiResponse<User>(success: res.data['success'],data: User.fromJson(res.data['data']),message: res.data['message']);
  }

  Future<ApiResponse<User>> getMeInfo({CancelToken? cancelToken}) async {
    var res = await DioSingleton().dio.get(_getMeInfo,cancelToken:cancelToken);
    return ApiResponse<User>(success: res.data['success'],data: User.fromJson(res.data['data']),message: res.data['message']);
  }

  Future<ApiResponse<void>> deleteUser({required String userId,CancelToken? cancelToken}) async {
    var url = _deleteUser.replaceFirst('{userId}', userId);
    var res = await DioSingleton().dio.delete(url,cancelToken:cancelToken);
    return ApiResponse<void>(success: res.data['success'],message: res.data['message']);
  }

  Future<ApiResponse<void>> deleteMe({CancelToken? cancelToken}) async {
    var res = await DioSingleton().dio.delete(_deleteMe,cancelToken:cancelToken);
    return ApiResponse<void>(success: res.data['success'],message: res.data['message']);
  }

  Future<ApiResponse<User>> addRole({required AddRole role,CancelToken? cancelToken}) async {
    var res = await DioSingleton().dio.patch(_addRole,data:role,cancelToken:cancelToken);
    return ApiResponse<User>(success: res.data['success'],data: User.fromJson(res.data['data']),message: res.data['message']);
  }

  Future<ApiResponse<void>> updatePasswordInit({required String usernameEmail,CancelToken? cancelToken}) async {
    var res = await DioSingleton().dio.post(_updatePasswordInit,data:{'usernameEmail':usernameEmail},cancelToken:cancelToken);
    return ApiResponse<void>(success: res.data['success'],message: res.data['message']);
  }

  Future<ApiResponse<void>> updatePasswordComplete({required UpdatePassword updatePassword,CancelToken? cancelToken}) async {
    var res = await DioSingleton().dio.patch(_updatePasswordComplete,data:updatePassword.toJson(),cancelToken:cancelToken);
    return ApiResponse<void>(success: res.data['success'],message: res.data['message']);
  }

  Future<ApiResponse<User>> login({required LoginManual loginManual,CancelToken? cancelToken}) async {
    var res = await DioSingleton().dio.post(_login,data:loginManual.toJson(),options: Options(contentType: "application/json"),cancelToken:cancelToken);
    return ApiResponse<User>(success: res.data['success'],data: User.fromJson(res.data['data']),message: res.data['message']);
  }

  Future<ApiResponse<User>> loginGoogle({required String idToken,CancelToken? cancelToken}) async {
    var res = await DioSingleton().dio.post(_loginGoogle,data:{'idToken':idToken},cancelToken:cancelToken);
    return ApiResponse<User>(success: res.data['success'],data: User.fromJson(res.data['data']),message: res.data['message']);
  }

  Future<ApiResponse<void>> logout({CancelToken? cancelToken}) async {
    var res = await DioSingleton().dio.get(_logout,cancelToken:cancelToken);
    return ApiResponse<void>(success: res.data['success'],message: res.data['message']);
  }

  Future<ApiResponse<void>> register({required Register register,CancelToken? cancelToken}) async {
    var res = await DioSingleton().dio.post(_register,data:register,cancelToken:cancelToken);
    return ApiResponse<void>(success: res.data['success'],message: res.data['message']);
  }

  Future<ApiResponse<void>> reVerify({required String email,CancelToken? cancelToken}) async {
    var res = await DioSingleton().dio.get('$_reVerify?email=$email',data:register,cancelToken:cancelToken);
    return ApiResponse<void>(success: res.data['success'],message: res.data['message']);
  }

  Future<String> verify({required String token,CancelToken? cancelToken}) async {
    var res = await DioSingleton().dio.get('$_verify?token=$token',data:register,cancelToken:cancelToken);
    return res.data;
  }

  Future<String> jwtVerify({CancelToken? cancelToken}) async {
    var res = await DioSingleton().dio.post(_jwtVerify,cancelToken:cancelToken);
    return res.data;
  }

  Future<ApiResponse<void>> forgotPassword({required String usernameEmail,CancelToken? cancelToken}) async {
    var res = await DioSingleton().dio.post(_forgotPassword,data:{'usernameEmail':usernameEmail},cancelToken:cancelToken);
    return ApiResponse<void>(success: res.data['success'],message: res.data['message']);
  }

  Future<ApiResponse<void>> resetPassword({required ResetPassword resetPassword,CancelToken? cancelToken}) async {
    var res = await DioSingleton().dio.post(_resetPassword,data:resetPassword,cancelToken:cancelToken);
    return ApiResponse<void>(success: res.data['success'],message: res.data['message']);
  }
}
