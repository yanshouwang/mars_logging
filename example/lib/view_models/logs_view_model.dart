import 'dart:io';

import 'package:clover/clover.dart';
import 'package:mars_logging/mars_logging.dart';
import 'package:path/path.dart' as path;

class LogsViewModel extends ViewModel {
  List<File> _logs;

  LogsViewModel() : _logs = [] {
    _updateLogs();
  }

  List<File> get logs => List.unmodifiable(_logs);

  void _updateLogs() async {
    final filesDir = Dirs.filesDir;
    final externalFilesDir = Dirs.externalFilesDir ?? filesDir;
    final logsPath = path.join(externalFilesDir.path, 'log');
    final logDir = Directory(logsPath);
    final exists = await logDir.exists();
    if (!exists) {
      return;
    }
    final logEntities = await logDir.list().toList();
    _logs = logEntities.whereType<File>().toList();
    notifyListeners();
  }
}
