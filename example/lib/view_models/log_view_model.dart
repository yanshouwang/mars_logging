import 'dart:convert';
import 'dart:io';

import 'package:clover/clover.dart';
import 'package:mars_logging/mars_logging.dart';
import 'package:path/path.dart' as path;

class LogViewModel extends ViewModel {
  final String _logName;
  String? _logText;

  LogViewModel(this._logName) : _logText = null {
    _updateLogContent();
  }

  String get logName => _logName;
  String? get logText => _logText;

  void _updateLogContent() async {
    final filesDir = Dirs.filesDir;
    final externalFilesDir = Dirs.externalFilesDir ?? filesDir;
    final logPath = path.join(externalFilesDir.path, 'log', _logName);
    final logFile = File(logPath);
    final buffer = await logFile.readAsBytes();
    final outBuffer = await Xlog.decode(buffer);
    _logText = utf8.decode(outBuffer);
    notifyListeners();
  }
}
