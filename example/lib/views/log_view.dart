import 'package:clover/clover.dart';
import 'package:flutter/material.dart';
import 'package:mars_logging_example/view_models.dart';
import 'package:path/path.dart' as path;

class LogView extends StatelessWidget {
  const LogView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = ViewModel.of<LogViewModel>(context);
    final logName = viewModel.logName;
    final logText = viewModel.logText;
    final title = path.basenameWithoutExtension(logName);
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: logText == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Text(logText),
            ),
    );
  }
}
