import 'package:dio/dio.dart';
import 'package:shakti/constants/Constants.dart';
import 'package:shakti/models/Aarti.dart';
import 'package:shakti/models/ApiResponse.dart';
import 'package:shakti/models/Pageable.dart';
import 'package:shakti/models/User.dart';
import 'package:shakti/models/requestPayload/AddRole.dart';
import 'package:shakti/models/requestPayload/LoginManual.dart';
import 'package:shakti/models/requestPayload/ResetPassword.dart';
import 'package:shakti/models/requestPayload/UpdatePassword.dart';
import '../../models/requestPayload/Register.dart';
import '../../singletons/DioSingleton.dart';

class AartiApi {
  static final AartiApi _instance = AartiApi._();
  static const String _getPaginatedAartis = "${Constants.baseUrl}/api/v1/shakti/aarti/all";

  AartiApi._();

  factory AartiApi() {
    return _instance;
  }

  Future<ApiResponse<Pageable<Aarti>>> getPaginatedAartis({required int pageNo,int pageSize=20,CancelToken? cancelToken}) async {
    var url = '$_getPaginatedAartis?pageNo=$pageNo&pageSize=$pageSize';
    var res = await DioSingleton().dio.get(url,cancelToken:cancelToken);
    final apiRes=res.data;
    final pageData=apiRes['data'];
    final page=Pageable<Aarti>(data: (pageData['data'] as List).map((item)=>Aarti.fromJson(item)).toList(), pageNo: pageData['pageNo'], totalItems: pageData['totalItems']);

    return ApiResponse(success: apiRes['success'],data: page,message: apiRes['message']);
  }

}
