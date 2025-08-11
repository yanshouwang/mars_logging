import 'package:clover/clover.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:mars_logging/mars_logging.dart';
import 'package:mars_logging_example/view_models.dart';
import 'package:path/path.dart' as path;

class LogView extends StatelessWidget {
  const LogView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = ViewModel.of<LogViewModel>(context);
    final logPath = viewModel.logPath;
    final logName = path.basenameWithoutExtension(logPath);
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(middle: Text(logName)),
      child: SafeArea(
        child: SelectableRegion(
          selectionControls:
              defaultTargetPlatform == TargetPlatform.android ||
                      defaultTargetPlatform == TargetPlatform.iOS
                  ? CupertinoTextSelectionControls()
                  : CupertinoDesktopTextSelectionControls(),
          child: XLogView(xlogPath: logPath, padding: EdgeInsets.all(16.0)),
        ),
      ),
    );
  }
}
