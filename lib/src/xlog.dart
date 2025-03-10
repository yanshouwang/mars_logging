import 'log_imp.dart';
import 'mars_logging_plugin.dart';

abstract base class Xlog extends LogImp {
  Xlog.impl() : super.impl();

  factory Xlog() => MarsLoggingPlugin.instance.newXlog();
}
