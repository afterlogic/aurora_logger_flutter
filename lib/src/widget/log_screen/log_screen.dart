import 'dart:io';
import 'package:aurora_logger/src/widget/logger_setting_arg.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class LogScreen extends StatelessWidget {
  final File file;
  final String content;
  final Function(File) onDelete;
  final LoggerSettingArg arg;

  const LogScreen(this.file, this.content, this.onDelete, this.arg);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(file.path.split(Platform.pathSeparator).last),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {
              final xFile = XFile(file.path, mimeType: 'text/plain');
              Share.shareXFiles(
                [xFile],
                subject: file.path.split(Platform.pathSeparator).last,
                sharePositionOrigin: Rect.fromCenter(
                  center: MediaQuery.of(context).size.bottomCenter(Offset.zero),
                  width: 0,
                  height: 0,
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () async {
              final result = await arg.confirmDialog(arg.hintDeleteLog);
              if (result == true) {
                onDelete(file);
                Navigator.pop(context);
              }
            },
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(8),
        child: SingleChildScrollView(
          child: SelectableText(
            content,
            maxLines: null,
          ),
        ),
      ),
    );
  }
}
