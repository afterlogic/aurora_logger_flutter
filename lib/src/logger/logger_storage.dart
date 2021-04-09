import 'package:shared_preferences/shared_preferences.dart';

class LoggerStorage {
  static LoggerStorage _instance;
  SharedPreferences _pref;
  LoggerStorage._();

  factory LoggerStorage() {
    return _instance ??= LoggerStorage._();
  }

  Future<SharedPreferences> _getPref() async {
    return _pref ??= await SharedPreferences.getInstance();
  }

  static const _debugEnable = "debugEnable";

  Future setDebugEnable(bool enable) async {
    final pref = await _getPref();
    return pref.setBool(_debugEnable, enable);
  }

  Future<bool> getDebugEnable() async {
    final pref = await _getPref();
    return pref.getBool(_debugEnable) ?? false;
  }

  static const _debug = "debug";

  Future setDebug(bool enable) async {
    final pref = await _getPref();
    pref.setBool(_debug, enable);
  }

  Future<bool> getDebug() async {
    final pref = await _getPref();
    return pref.getBool(_debug) ?? false;
  }


  static const _isRun = "isRun";

  Future setIsRun(bool enable) async {
    final pref = await _getPref();
    return pref.setBool(_isRun, enable);
  }

  Future<bool> getIsRun() async {
    final pref = await _getPref();
    return pref.getBool(_isRun) ?? false;
  }
}
