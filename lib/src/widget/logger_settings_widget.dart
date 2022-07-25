import 'dart:io';
import 'package:aurora_logger/src/logger/logger.dart';
import 'package:aurora_logger/src/logger/logger_storage.dart';
import 'package:aurora_logger/src/widget/log_screen/log_screen.dart';
import 'package:aurora_logger/src/widget/logger_setting_arg.dart';
import 'package:flutter/material.dart';

class LoggerSettingWidget extends StatefulWidget {
  final LoggerSettingArg arg;

  const LoggerSettingWidget(this.arg);

  @override
  _LoggerSettingWidgetState createState() => _LoggerSettingWidgetState();
}

class _LoggerSettingWidgetState extends State<LoggerSettingWidget> {
  final _storage = LoggerStorage();
  late bool _debug;
  late List<Widget> _logs;
  bool _initComplete = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() {
    Future.wait([
      _storage.getDebug(),
      logger.logDir().then((value) => getLogs(value)),
    ]).then((list) {
      _debug = list[0] as bool;
      _logs = list[1] as List<Widget>;
      setState(() {
        _initComplete = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return !_initComplete
        ? SizedBox.shrink()
        : Column(
            children: <Widget>[
              ListTile(
                title: Text("Host: " + widget.arg.hostname),
              ),
              CheckboxListTile(
                value: _debug,
                title: Text(widget.arg.labelShowDebugView),
                onChanged: _onChangeDebug,
              ),
              TextButton(
                child: Text(widget.arg.labelDeleteAllLogs),
                onPressed: _onDeleteAll,
              ),
              Expanded(
                child: ListView(
                  children: _logs,
                ),
              )
            ],
          );
  }

  void _onChangeDebug(bool? value) {
    final enable = value ?? false;
    _debug = enable;
    _storage.setDebug(enable);
    setState(() {});
    logger.enable = enable;
  }

  Future<void> _onDeleteAll() async {
    final result = await widget.arg.confirmDialog(widget.arg.hintDeleteAllLogs);
    if (result == true) {
      deleteAll();
    }
  }

  Future<List<Widget>> getLogs(String path) async {
    final dir = Directory(path);
    if (!await dir.exists()) {
      return [];
    }
    var files = (await (await dir.list()).toList());
    Map<FileSystemEntity, FileStat> statMap = {};
    for (var file in files) {
      final stat = await file.stat();
      statMap[file] = stat;
    }
    files.sort((a, b) {
      if (a is Directory) return 0;
      if (statMap[a] == null || statMap[b] == null) return 0;
      return statMap[a]!.changed.compareTo(statMap[b]!.changed);
    });
    final widgets = <Widget>[];
    for (var value in files) {
      if (value is Directory) {
        final children = await getLogs(value.path);
        widgets.add(FolderLogWidget(value, children));
      } else if (value is File) {
        widgets.add(FileLogWidget(value, delete, widget.arg));
      }
    }
    return widgets;
  }

  deleteAll() async {
    final dir = Directory(await logger.logDir());
    await _delete(dir);
    _init();
  }

  Future _delete(FileSystemEntity entity) async {
    if (entity is Directory) {
      final children = await entity.list().toList();
      for (var item in children) {
        await _delete(item);
      }
    } else if (entity is File) {
      await entity.delete();
    }
  }

  delete(File file) async {
    await file.delete();
    _init();
  }
}

class FileLogWidget extends StatelessWidget {
  final File value;
  final LoggerSettingArg arg;
  final Function(File) onDelete;

  FileLogWidget(this.value, this.onDelete, this.arg);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.insert_drive_file),
      title: Text(value.path.split(Platform.pathSeparator).last),
      onTap: () => open(context),
    );
  }

  open(BuildContext context) async {
    final content = await value.readAsString();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) {
        return LogScreen(
          value,
          content,
          onDelete,
          arg,
        );
      }),
    );
  }
}

class FolderLogWidget extends StatefulWidget {
  final Directory value;
  final List<Widget> children;

  FolderLogWidget(this.value, this.children);

  @override
  _FolderLogWidgetState createState() => _FolderLogWidgetState();
}

class _FolderLogWidgetState extends State<FolderLogWidget> {
  bool expand = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ListTile(
          leading: Icon(Icons.folder),
          title: Text(widget.value.path.split(Platform.pathSeparator).last),
          onTap: () => setState(() => expand = !expand),
        ),
        if (expand)
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: widget.children,
            ),
          )
      ],
    );
  }
}
