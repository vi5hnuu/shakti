import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/Constants.dart';

class SecureStorage {
  final FlutterSecureStorage storage = const FlutterSecureStorage(aOptions: AndroidOptions(encryptedSharedPreferences: true, sharedPreferencesName: Constants.sharedPreferencesName));
  static final _instance = SecureStorage._();

  SecureStorage._() {}

  factory SecureStorage() {
    return _instance;
  }
}
