import 'dart:io';

import 'mars_logging_plugin.dart';
import 'dirs_channel.dart';

abstract final class Dirs {
  static DirsChannel get _channel => MarsLoggingPlugin.instance.dirsChannel;

  static Directory get filesDir => Directory(_channel.filesDir);

  static Directory? get externalFilesDir {
    final path = _channel.externalFilesDir;
    return path == null ? null : Directory(path);
  }
}
