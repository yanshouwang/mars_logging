import 'package:plugin_platform_interface/plugin_platform_interface.dart';

abstract base class LogImp extends PlatformInterface {
  static final _token = Object();

  LogImp.impl() : super(token: _token);
}
