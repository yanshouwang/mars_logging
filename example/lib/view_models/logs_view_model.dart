import 'dart:io';

import 'package:clover/clover.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as path;

class LogsViewModel extends ViewModel {
  List<File> _logs;

  LogsViewModel() : _logs = [] {
    _updateLogs();
  }

  List<File> get logs => List.unmodifiable(_logs);

  void _updateLogs() async {
    final externalFilesDir = await path.getExternalStorageDirectory();
    if (externalFilesDir == null) {
      return;
    }
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
