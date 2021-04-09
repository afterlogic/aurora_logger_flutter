class LoggerApiInterceptor {
  void Function(String) onError;
  void Function(String) onRequest;
  void Function(String) onResponse;

  void error(String msg) {
    onError?.call(msg);
  }

  void request(String msg) {
    onRequest?.call(msg);
  }

  void response(String msg) {
    onResponse?.call(msg);
  }
}
