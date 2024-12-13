import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'dirs_channel.dart';
import 'impl.dart';
import 'xlog_channel.dart';

abstract class MarsLoggingPlugin extends PlatformInterface {
  /// Constructs a MarsLoggingPlatform.
  MarsLoggingPlugin() : super(token: _token);

  static final Object _token = Object();

  static MarsLoggingPlugin? _instance;

  /// The default instance of [MarsLoggingPlugin] to use.
  ///
  /// Defaults to [MethodChannelMarsLogging].
  static MarsLoggingPlugin get instance {
    var instance = _instance;
    if (instance == null) {
      _instance = instance = MarsLoggingPluginImpl();
    }
    return instance;
  }

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [MarsLoggingPlugin] when
  /// they register themselves.
  static set instance(MarsLoggingPlugin instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  DirsChannel get dirsChannel;
  XlogChannel get xlogChannel;
}
