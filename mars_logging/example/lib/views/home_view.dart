import 'package:clover/clover.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mars_logging_example/view_models.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = ViewModel.of<HomeViewModel>(context);
    final levels = viewModel.levels;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mars Example'),
        actions: [
          IconButton(
            onPressed: () => context.go('/logs'),
            icon: const Icon(Icons.bug_report),
          ),
        ],
      ),
      body: ListView.separated(
        itemBuilder: (context, index) {
          final level = levels[index];
          return ListTile(
            title: Text(level.name),
            onTap: () {
              viewModel.log(level);
            },
          );
        },
        separatorBuilder: (context, index) {
          return const Divider();
        },
        itemCount: levels.length,
      ),
    );
  }
}
