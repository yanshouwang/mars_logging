import 'package:clover/clover.dart';
import 'package:hybrid_logging/hybrid_logging.dart';
import 'package:logging/logging.dart';

class HomeViewModel extends ViewModel with TypeLogger {
  final List<Level> levels;

  HomeViewModel()
      : levels = List.unmodifiable([
          Level.FINEST,
          Level.FINER,
          Level.FINE,
          Level.CONFIG,
          Level.INFO,
          Level.WARNING,
          Level.SEVERE,
          Level.SHOUT,
        ]);

  void log(Level level) {
    logger.log(level, 'Hello World!');
  }
}
