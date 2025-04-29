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
                      labelText: "Format",
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
                            Icon(Icons.videocam, color: Colors.blue),
                            SizedBox(width: 8),
                            Text("Video"),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: "mp3",
                        child: Row(
                          children: [
                            Icon(Icons.audiotrack, color: Colors.deepPurple),
                            SizedBox(width: 8),
                            Text("Audio"),
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

            // Folder Selection
            Consumer<DownloadManager>(
              builder: (context, downloadManager, child) {
                return Row(
                  children: [
                    Expanded(
                      child: Text(
                        downloadManager.downloadPath ?? "No download path selected",
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: downloadManager.downloadPath != null
                              ? Colors.grey.shade700
                              : Colors.red.shade300,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        final path = await pickDownloadFolder();
                        if (path != null) {
                          downloadManager.setDownloadPath();
                          _showSnackBar(
                            "Download folder set.",
                            color: Colors.green,
                            icon: Icons.folder_open,
                          );
                        }
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
                onPressed: () {
                  final downloadManager =
                      Provider.of<DownloadManager>(context, listen: false);
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
                    "Download added to queue.",
                    color: Colors.green,
                    icon: Icons.check_circle,
                  );
                },
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
