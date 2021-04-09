import 'package:aurora_logger/src/interceptor/logger_api_interceptor.dart';

class LoggerSetting {
  final String packageName;
  final LoggerApiInterceptor defaultInterceptor;

  LoggerSetting({
    this.packageName = "packageName",
    this.defaultInterceptor,
  });

  static init(LoggerSetting loggerSetting) {
    _current = loggerSetting;
  }

  static LoggerSetting _current = LoggerSetting();

  static LoggerSetting get current => _current;
}
