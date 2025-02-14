// ongoing_tasks.dart
import 'package:flutter/material.dart';
import 'package:youdon/models/download_task.dart';

class OngoingTasks extends StatelessWidget {
  final List<DownloadTask> downloadQueue;

  const OngoingTasks({super.key, required this.downloadQueue});

  @override
  Widget build(BuildContext context) {
    if (downloadQueue.isEmpty) {
      return const Center(child: Text("No downloads in progress."));
    }

    return ListView.builder(
      itemCount: downloadQueue.length,
      itemBuilder: (context, index) {
        final task = downloadQueue[index];
        return ListTile(
          title: Text(task.url), // Display URL
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
  }
}