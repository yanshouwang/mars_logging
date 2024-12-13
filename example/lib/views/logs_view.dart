import 'package:clover/clover.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mars_logging_example/view_models.dart';
import 'package:path/path.dart' as path;

class LogsView extends StatelessWidget {
  const LogsView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = ViewModel.of<LogsViewModel>(context);
    final logs = viewModel.logs;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Logs'),
      ),
      body: ListView.separated(
        itemBuilder: (context, index) {
          final log = logs[index];
          final logPath = log.path;
          final logName = path.basename(logPath);
          final title = path.basenameWithoutExtension(logPath);
          return ListTile(
            title: Text(title),
            onTap: () {
              context.go('/logs/$logName');
            },
          );
        },
        separatorBuilder: (context, index) {
          return const Divider();
        },
        itemCount: logs.length,
      ),
    );
  }
}
