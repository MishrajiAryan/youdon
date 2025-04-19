// ongoing_tasks.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import Provider
import '/models/download_manager.dart'; // Import your DownloadManager

class OngoingTasks extends StatelessWidget {
  const OngoingTasks({super.key}); // No longer takes downloadQueue as a parameter

  @override
  Widget build(BuildContext context) {
    return Consumer<DownloadManager>( // Use Consumer
      builder: (context, downloadManager, child) {
        if (downloadManager.downloadQueue.isEmpty) {
          return const Center(child: Text("No downloads in progress."));
        }

        return ListView.builder(
          itemCount: downloadManager.downloadQueue.length,
          itemBuilder: (context, index) {
            final task = downloadManager.downloadQueue[index];
            return ListTile(
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${task.format} - ${task.mode}'),
                  if (task.isDownloading)
                    LinearProgressIndicator(
                      value: task.progress,
                    ),
                ],
              ),
              trailing: task.isDownloading
                  ? Text('${(task.progress * 100).toStringAsFixed(2)}%')
                  : const Text("Queued"),
            );
          },
        );
      },
    );
  }
}
