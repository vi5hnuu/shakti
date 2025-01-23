import 'dart:io';

import 'package:dio/dio.dart';
import 'package:shakti/extensions/map-entensions.dart';
import 'package:shakti/singletons/SecureStorage.dart';
import '../constants/Constants.dart';
import 'LoggerSingleton.dart';

class DioSingleton {
  final Dio dio = Dio();
  final Map<String, Cookie> _cookies = {};
  static final DioSingleton _instance = DioSingleton._();
  final _secureStorage = SecureStorage();

  DioSingleton._() {
    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) async {
      LoggerSingleton().logger.i('REQUEST [${options.method}] => PATH: ${options.path}');
      if (_cookies.isNotEmpty) {
        options.headers['Cookie'] = _cookies.values.map((cookie) => '${cookie.name}=${cookie.value}').join('; ');
      }
      return handler.next(options);
    }, onResponse: (response, handler) async {
      LoggerSingleton().logger.i('RESPONSE [${response.statusCode}] => PATH: ${response.requestOptions.path}');
      List<String> rawCookies = response.headers['set-cookie'] ?? [];

      final cookies = rawCookies.where((cookie) => cookie.startsWith(Constants.jwtCookieKey));
      if (cookies.isEmpty) return handler.next(response);

      Cookie jwtCookie = Cookie.fromSetCookieValue(cookies.first);
      addCookie(Constants.jwtCookieKey, jwtCookie);

      //save token ->[at splash screen use this to authenticate if not expired]
      _secureStorage.storage.write(key: Constants.jwtCookieKey, value: jwtCookie.toString());
      return handler.next(response);
    }, onError: (DioException e, handler) {
      LoggerSingleton().logger.i('ERROR [${e.response?.statusCode}] => PATH: ${e.requestOptions.path}');
      LoggerSingleton().logger.e('ERROR [${e.response}');
      return handler.next(e);
    }));
  }

  void addCookie(String key, Cookie cookie) {
    _cookies.put(key, cookie);
  }



  factory DioSingleton() {
    return _instance;
  }
}

