import 'dart:convert';
import 'dart:io';

import 'package:clover/clover.dart';
import 'package:mars_logging/mars_logging.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as path;

class LogViewModel extends ViewModel {
  final String _name;
  String? _text;

  LogViewModel(this._name) : _text = null {
    _updateLogContent();
  }

  String get name => _name;
  String? get text => _text;

  void _updateLogContent() async {
    final filesDir = await path.getApplicationSupportDirectory();
    final logPath = path.join(filesDir.path, 'logs', _name);
    final log = File(logPath);
    final buffer = await log.readAsBytes();
    final codeUnits = await XLog.decode(buffer);
    _text = utf8.decode(codeUnits);
    notifyListeners();
  }
}
