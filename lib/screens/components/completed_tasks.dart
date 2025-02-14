// completed_tasks.dart
import 'package:flutter/material.dart';
import 'package:youdon/models/download_task.dart';

class CompletedTasks extends StatelessWidget {
  final List<DownloadTask> completedTasks;

  const CompletedTasks({super.key, required this.completedTasks});

  @override
  Widget build(BuildContext context) {
    if (completedTasks.isEmpty) {
      return const Center(child: Text("No completed downloads yet."));
    }

    return ListView.builder(
      itemCount: completedTasks.length,
      itemBuilder: (context, index) {
        final task = completedTasks[index];
        return ListTile(
          title: Text(task.url), // Display URL
          subtitle: Text('${task.format} - ${task.mode}'),
        );
      },
    );
  }
}