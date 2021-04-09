class LoggerSettingArg {
  final String hostname;
  final String labelShowDebugView;
  final String labelDeleteAllLogs;
  final String hintDeleteAllLogs;
  final String hintDeleteLog;
  final Future<bool> Function(String hint) confirmDialog;

  LoggerSettingArg(
    this.hostname,
    this.labelShowDebugView,
    this.labelDeleteAllLogs,
    this.hintDeleteAllLogs,
    this.hintDeleteLog,
    this.confirmDialog,
  );
}
