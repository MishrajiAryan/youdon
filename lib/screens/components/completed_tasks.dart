// lib/screens/components/completed_tasks.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/models/download_manager.dart';
import 'package:open_file/open_file.dart'; // Add open_file package in pubspec.yaml

class CompletedTasks extends StatefulWidget {
  const CompletedTasks({super.key});

  @override
  State<CompletedTasks> createState() => _CompletedTasksState();
}

class _CompletedTasksState extends State<CompletedTasks> {
  bool _recentFirst = true;

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

  void _showSnackBar(BuildContext context, String message, {Color? color, IconData? icon}) {
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: color ?? Colors.blueGrey,
          content: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: Colors.white),
                const SizedBox(width: 12),
              ],
              Expanded(child: Text(message, style: const TextStyle(color: Colors.white))),
            ],
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DownloadManager>(
      builder: (context, downloadManager, child) {
        var completed = List.of(downloadManager.completedTasks);
        if (_recentFirst) {
          completed = completed.reversed.toList();
        }

        if (completed.isEmpty) {
          return const Center(child: Text("No completed downloads yet."));
        }

        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  icon: Icon(_recentFirst ? Icons.arrow_downward : Icons.arrow_upward),
                  label: Text(_recentFirst ? "Recent First" : "Oldest First"),
                  onPressed: () => setState(() => _recentFirst = !_recentFirst),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.delete_sweep),
                  label: const Text("Clear All"),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  onPressed: () {
                    downloadManager.clearAllCompletedTasks();
                    _showSnackBar(
                      context,
                      "All completed tasks cleared.",
                      color: Colors.red,
                      icon: Icons.delete_sweep,
                    );
                  },
                ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemCount: completed.length,
                itemBuilder: (context, index) {
                  final task = completed[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Card(
                      elevation: 5,
                      shadowColor: Colors.black26,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
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
                        subtitle: Text(
                          '${task.format == "mp3" ? "Audio" : "Video"} • ${task.mode == "playlist" ? "Playlist" : "Single"}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          tooltip: "Delete",
                          onPressed: () {
                            downloadManager.removeCompletedTask(task);
                            _showSnackBar(
                              context,
                              "Task deleted.",
                              color: Colors.red,
                              icon: Icons.delete,
                            );
                          },
                        ),
                        onTap: () async {
                          final filePath = task.fileName;
                          if (filePath != null) {
                            final result = await OpenFile.open(filePath);
                            if (result.type == ResultType.done) {
                              _showSnackBar(
                                context,
                                "Opened successfully.",
                                color: Colors.green,
                                icon: Icons.check_circle,
                              );
                            } else {
                              _showSnackBar(
                                context,
                                "Could not open file.",
                                color: Colors.orange,
                                icon: Icons.warning,
                              );
                            }
                          } else {
                            _showSnackBar(
                              context,
                              "File not found.",
                              color: Colors.orange,
                              icon: Icons.warning,
                            );
                          }
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
