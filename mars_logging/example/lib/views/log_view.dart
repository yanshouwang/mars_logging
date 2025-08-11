import 'package:clover/clover.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:mars_logging/mars_logging.dart';
import 'package:mars_logging_example/view_models.dart';

class LogView extends StatelessWidget {
  const LogView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);
    final viewModel = ViewModel.of<LogViewModel>(context);
    final logName = viewModel.logName;
    final logPath = viewModel.logPath;
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(middle: Text(logName)),
      child: SafeArea(
        child: SelectableRegion(
          selectionControls:
              defaultTargetPlatform == TargetPlatform.android ||
                      defaultTargetPlatform == TargetPlatform.iOS
                  ? CupertinoTextSelectionControls()
                  : CupertinoDesktopTextSelectionControls(),
          child: XLogView(
            xlogPath: logPath,
            style: theme.textTheme.textStyle.copyWith(fontSize: 14.0),
            padding: EdgeInsets.all(16.0),
          ),
        ),
      ),
    );
  }
}
