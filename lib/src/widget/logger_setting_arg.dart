class LoggerSettingArg {
  final String hostname;
  final String labelShowDebugView;
  final String labelCounterOfUploadedMessage;
  final String labelDeleteAllLogs;
  final String hintDeleteAllLogs;
  final String hintDeleteLog;
  final Future<bool> Function(String hint) confirmDialog;

  LoggerSettingArg(
    this.hostname,
    this.labelShowDebugView,
    this.labelCounterOfUploadedMessage,
    this.labelDeleteAllLogs,
    this.hintDeleteAllLogs,
    this.hintDeleteLog,
    this.confirmDialog,
  );
}
