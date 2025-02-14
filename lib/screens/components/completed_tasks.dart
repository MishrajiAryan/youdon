// completed_tasks.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import Provider
import '/models/download_manager.dart'; // Import your DownloadManager


class CompletedTasks extends StatelessWidget {
  const CompletedTasks({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DownloadManager>(
      builder: (context, downloadManager, child) {
        if (downloadManager.completedTasks.isEmpty) {
          return const Center(child: Text("No completed downloads yet."));
        }

        return ListView.builder(
          itemCount: downloadManager.completedTasks.length,
          itemBuilder: (context, index) {
            final task = downloadManager.completedTasks[index];
            return ListTile(
              title: Text(task.url),
              subtitle: Text('${task.format} - ${task.mode}'),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  downloadManager.removeCompletedTask(task);
                },
              ),
            );
          },
        );
      },
    );
  }
}