import 'package:dio/dio.dart';
import 'package:shakti/constants/Constants.dart';
import 'package:shakti/models/Aarti.dart';
import 'package:shakti/models/ApiResponse.dart';
import 'package:shakti/models/Pageable.dart';
import 'package:shakti/models/Reel.dart';
import 'package:shakti/models/User.dart';
import 'package:shakti/models/requestPayload/AddRole.dart';
import 'package:shakti/models/requestPayload/LoginManual.dart';
import 'package:shakti/models/requestPayload/ResetPassword.dart';
import 'package:shakti/models/requestPayload/UpdatePassword.dart';
import '../../models/requestPayload/Register.dart';
import '../../singletons/DioSingleton.dart';

class ShaktiReelApi {
  static final ShaktiReelApi _instance = ShaktiReelApi._();
  static const String _getPaginatedShaktiReels = "${Constants.baseUrl}/api/v1/shakti/reel/all";

  ShaktiReelApi._();

  factory ShaktiReelApi() {
    return _instance;
  }

  Future<ApiResponse<Pageable<Reel>>> getPaginatedReels({required int pageNo,int pageSize=20,CancelToken? cancelToken}) async {
    var url = '$_getPaginatedShaktiReels?pageNo=$pageNo&pageSize=$pageSize';
    var res = await DioSingleton().dio.get(url,cancelToken:cancelToken);
    final apiRes=res.data;
    final pageData=apiRes['data'];
    final page=Pageable<Reel>(data: (pageData['data'] as List).map((item)=>Reel.fromJson(item)).toList(), pageNo: pageData['pageNo'], totalItems: pageData['totalItems']);

    return ApiResponse(success: apiRes['success'],data: page,message: apiRes['message']);
  }

}
