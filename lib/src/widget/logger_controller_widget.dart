import 'package:flutter/material.dart';
import 'package:aurora_logger/src/logger/logger.dart';
import 'package:flutter/scheduler.dart';

class LoggerControllerWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LoggerControllerWidgetState();
  }

  static Widget wrap(Widget widget) {
    return Column(
      children: <Widget>[
        Expanded(
          child: widget,
        ),
        LoggerControllerWidget(),
      ],
    );
  }
}

class LoggerControllerWidgetState extends State<LoggerControllerWidget> {
  @override
  void initState() {
    super.initState();
    logger.onEdit = _onChange;
  }

  @override
  void dispose() {
    super.dispose();
    logger.onEdit = null;
  }

  void _rebuild() {
    try {
      setState(() {});
    } catch (err) {
      print('LoggerControllerWidget ERROR: $err');
    }
  }

  void _onChange() {
    // if we are in the build phase
    if (SchedulerBinding.instance?.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      SchedulerBinding.instance?.addPostFrameCallback((_) {
        _rebuild();
      });
    } else {
      _rebuild();
    }
  }

  void _onDelete() {
    logger.clear();
  }

  void _onStartPause() {
    logger.isRun ? logger.pause() : logger.start();
  }

  void _onSave() {
    if (logger.count > 0) {
      logger.save();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!logger.enable) {
      return SizedBox.shrink();
    }
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Container(
        color: Colors.white,
        height: 40,
        width: double.infinity,
        child: Stack(
          children: <Widget>[
            Row(
              textDirection: TextDirection.ltr,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: EdgeInsets.all(6),
                    child: Icon(Icons.delete),
                  ),
                  onTap: _onDelete,
                ),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: EdgeInsets.all(6),
                    child: Icon(
                      logger.isRun
                          ? Icons.pause_circle_filled
                          : Icons.fiber_manual_record,
                      color: Colors.red,
                    ),
                  ),
                  onTap: _onStartPause,
                ),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: EdgeInsets.all(6),
                    child: Icon(Icons.save),
                  ),
                  onTap: _onSave,
                )
              ],
            ),
            Text(
              "Recorded entries: ${logger.count}",
              style: TextStyle(
                fontSize: 9,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
