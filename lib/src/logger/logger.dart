import 'dart:io';

import 'package:aurora_logger/src/interceptor/logger_api_interceptor.dart';
import 'package:aurora_logger/src/logger/logger_setting.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'logger_storage.dart';

Logger? _logger;

Logger get logger => _logger ??= Logger._();

class Logger {
  static const newLine = "|/n|";

  final storage = LoggerStorage();
  String? currentTag;
  String buffer = "";
  int count = 0;
  Function()? onEdit;

  bool _isRun = false;

  bool get isRun => _isRun;

  set isRun(bool val) {
    storage.setIsRun(val);
    _isRun = val;
  }

  bool _enable = false;

  bool get enable => _enable;

  set enable(bool v) {
    _enable = v;
    if (onEdit != null) onEdit!.call();
  }

  Logger._([String? tag, LoggerApiInterceptor? apiInterceptor]) {
    currentTag = tag;
    if (apiInterceptor == null) {
      apiInterceptor = LoggerSetting.current.defaultInterceptor;
    }
    if (apiInterceptor != null) {
      apiInterceptor.onError = (str) {
        log("API ERROR:\n$str", true);
      };
      apiInterceptor.onRequest = (str) {
        log("API REQUEST:\n$str", true);
      };
      apiInterceptor.onResponse = (str) {
        log("API RESPONSE:\n$str", true);
      };
    }
  }

  void error(Object text, StackTrace? stackTrace, [bool show = true]) {
    stackTrace ??= StackTrace.current;
    final time = DateFormat("hh:mm:ss.SSS").format(DateTime.now());
    text =
        "____________________________\n\nError:$text\n${stackTrace.toString()}\n\n____________________________";
    if (show == true) print("[$time] $text");
    if (isRun) {
      buffer += "[$time] ${"$text".replaceAll("\n", newLine)}$newLine$newLine";
      count++;
      if (onEdit != null) onEdit!.call();
    }
  }

  void log(Object text, [bool show = true]) {
    final time = DateFormat("hh:mm:ss.SSS").format(DateTime.now());
    if (show == true) print("[$time] $text");
    if (isRun) {
      buffer += "[$time] ${"$text".replaceAll("\n", newLine)}$newLine$newLine";
      count++;
      if (onEdit != null) onEdit!.call();
    }
  }

  static Logger backgroundSync(LoggerApiInterceptor apiInterceptor) {
    return Logger._("Background_sync", apiInterceptor);
  }

  static Logger errorLog(Object error, StackTrace stackTrace) {
    return Logger._("Error")
      ..start()
      ..error(error, stackTrace)
      ..save();
  }

  static Logger notifications(Object value) {
    return Logger._("Notifications")
      ..start()
      ..log(value)
      ..save();
  }

  static Logger fido(Object value) {
    return Logger._("FIDO")
      ..start()
      ..log(value)
      ..save();
  }

  void start() {
    isRun = true;
    if (onEdit != null) onEdit!.call();
  }

  void clear() {
    buffer = "";
    count = 0;
    if (onEdit != null) onEdit!.call();
  }

  Future<void> save() async {
    final content = buffer;
    buffer = "";
    count = 0;
    try {
      final dir = await logDir();
      final file = File(
        dir +
            Platform.pathSeparator +
            (currentTag == null ? "" : "$currentTag${Platform.pathSeparator}") +
            DateTime.now().toIso8601String() +
            ".log.txt",
      );
      await file.create(recursive: true);
      await file.writeAsString(content.replaceAll(newLine, "\n"));
    } catch (e) {
      print(e);
    }

    if (onEdit != null) onEdit!.call();
  }

  void pause() {
    isRun = false;
    if (onEdit != null) onEdit!.call();
  }

  Future<String> logDir() async {
    return (await getApplicationDocumentsDirectory()).path +
        Platform.pathSeparator +
        "Logs_${LoggerSetting.current.packageName}";
  }
}
