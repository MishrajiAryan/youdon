// lib/screens/components/ongoing_tasks.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/models/download_manager.dart';

class OngoingTasks extends StatelessWidget {
  const OngoingTasks({super.key});

  IconData _getFormatIcon(String format) {
    switch (format) {
      case 'mp3':
        return Icons.audiotrack;
      case 'mp4':
        return Icons.videocam;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color _getFormatColor(String format, BuildContext context) {
    switch (format) {
      case 'mp3':
        return Theme.of(context).colorScheme.secondary;
      case 'mp4':
        return Theme.of(context).colorScheme.primary;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DownloadManager>(
      builder: (context, downloadManager, child) {
        if (downloadManager.downloadQueue.isEmpty) {
          return const Center(child: Text("No downloads in progress."));
        }

        return ListView.builder(
          itemCount: downloadManager.downloadQueue.length,
          itemBuilder: (context, index) {
            final task = downloadManager.downloadQueue[index];

            return AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeInOut,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Card(
                elevation: 5,
                shadowColor: Colors.black26,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getFormatColor(task.format, context).withOpacity(0.15),
                    child: Icon(
                      _getFormatIcon(task.format),
                      color: _getFormatColor(task.format, context),
                    ),
                  ),
                  title: Text(
                    task.fileName ?? task.url,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${task.format == "mp3" ? "Audio" : "Video"} • ${task.mode == "playlist" ? "Playlist" : "Single"}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      ),
                      const SizedBox(height: 6),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        child: task.isDownloading
                            ? Column(
                                key: const ValueKey("progress"),
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  LinearProgressIndicator(
                                    value: task.progress,
                                    minHeight: 8, // Increased height for better visibility
                                    backgroundColor: Theme.of(context).brightness == Brightness.dark
                                        ? Colors.grey[800]
                                        : Colors.grey[300],
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      task.format == "mp3"
                                          ? Colors.deepPurpleAccent // Bright purple for audio
                                          : Colors.blueAccent,     // Bright blue for video
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                  ),


                                  const SizedBox(height: 4),
                                  Text(
                                    "${(task.progress * 100).toStringAsFixed(1)}%",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                ],
                              )
                            : Container(
                                key: const ValueKey("queued"),
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                child: Text(
                                  "Queued",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context).hintColor,
                                  ),
                                ),
                              ),
                      ),
                    ],
                  ),
                  // Optionally, add a trailing cancel button or icon here
                ),
              ),
            );
          },
        );
      },
    );
  }
}
