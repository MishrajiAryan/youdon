// lib/screens/components/download_input.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/models/download_manager.dart';
import '/models/download_task.dart';
import '/utils/file_picker.dart';

class DownloadInput extends StatefulWidget {
  const DownloadInput({super.key});

  @override
  State<DownloadInput> createState() => _DownloadInputState();
}

class _DownloadInputState extends State<DownloadInput> {
  final TextEditingController _urlController = TextEditingController();
  String _selectedFormat = "mp4";
  String _selectedMode = "single";


  void _showSnackBar(String message, {Color? color, IconData? icon}) {
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
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(color: Colors.white),
                  overflow: TextOverflow.visible,
                ),
              ),
            ],
          ),
        ),
      );
  }

  void _addToQueue() {
    final downloadManager = Provider.of<DownloadManager>(context, listen: false);
    final url = _urlController.text.trim();

    if (url.isEmpty) {
      _showSnackBar(
        "Please enter a YouTube URL.",
        color: Colors.red,
        icon: Icons.error,
      );
      return;
    }

    if (downloadManager.downloadPath == null) {
      _showSnackBar(
        "Please select a download folder.",
        color: Colors.red,
        icon: Icons.folder_off,
      );
      return;
    }

    final newTask = DownloadTask(
      url: url,
      format: _selectedFormat,
      mode: _selectedMode,
      downloadPath: downloadManager.downloadPath!,
    );

    downloadManager.addToQueue(newTask);
    _urlController.clear();
    
    _showSnackBar(
      _selectedFormat == "mp3" 
        ? "Audio download added with best quality format."
        : "Video download added with best quality format.",
      color: Colors.green,
      icon: Icons.check_circle,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final downloadButtonColor = isDark ? Colors.pinkAccent : Theme.of(context).colorScheme.primary;

    return Card(
      elevation: 7,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          children: [
            // URL Input Field
            TextField(
              controller: _urlController,
              decoration: InputDecoration(
                labelText: "Enter YouTube URL",
                prefixIcon: const Icon(Icons.link),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 14),

            // Format & Mode Selection in a Row
            Row(
              children: [
                // Format Dropdown (Video/Audio)
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedFormat,
                    decoration: InputDecoration(
                      labelText: "Quality",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                    ),
                    isExpanded: true,
                    onChanged: (value) => setState(() => _selectedFormat = value!),
                    items: const [
                      DropdownMenuItem(
                        value: "mp4",
                        child: Row(
                          children: [
                            Icon(Icons.high_quality, color: Colors.blue),
                            SizedBox(width: 8),
                            Text("Best Video + Audio"),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: "mp3",
                        child: Row(
                          children: [
                            Icon(Icons.audiotrack, color: Colors.deepPurple),
                            SizedBox(width: 8),
                            Text("Best Audio Only"),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),

                // Mode Dropdown (Single/Playlist)
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedMode,
                    decoration: InputDecoration(
                      labelText: "Mode",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                    ),
                    isExpanded: true,
                    onChanged: (value) => setState(() => _selectedMode = value!),
                    items: const [
                      DropdownMenuItem(
                        value: "single",
                        child: Row(
                          children: [
                            Icon(Icons.music_note, color: Colors.teal),
                            SizedBox(width: 8),
                            Text("Single"),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: "playlist",
                        child: Row(
                          children: [
                            Icon(Icons.queue_music, color: Colors.orange),
                            SizedBox(width: 8),
                            Text("Playlist"),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Quality Info Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _selectedFormat == "mp3"
                          ? "Audio: Highest bitrate format will be automatically selected"
                          : "Video: Best resolution + audio combination will be automatically selected",
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Folder Selection
            Consumer<DownloadManager>(
              builder: (context, downloadManager, child) {
                return Row(
                  children: [
                    Expanded(
                      child: Text(
                        downloadManager.downloadPath ?? "Tap folder icon to select download path",
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: downloadManager.downloadPath != null
                              ? Theme.of(context).textTheme.bodyMedium?.color
                              : Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                          fontSize: 14,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        await downloadManager.setDownloadPath();
                      },
                      icon: const Icon(Icons.folder_open),
                      tooltip: "Select Download Folder",
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 14),

            // Download Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 4,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: downloadButtonColor,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.download),
                label: const Text("Add to Queue"),
                onPressed: _addToQueue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }
}