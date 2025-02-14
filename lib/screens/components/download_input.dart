// download_input.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import Provider
import '/models/download_manager.dart'; // Import your DownloadManager
import '/models/download_task.dart'; // Import DownloadTask
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _urlController,
          decoration: const InputDecoration(labelText: "YouTube URL"),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            DropdownButton<String>(
              value: _selectedFormat,
              onChanged: (newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedFormat = newValue;
                  });
                }
              },
              items: const [
                DropdownMenuItem(value: "mp4", child: Text("MP4")),
                DropdownMenuItem(value: "mp3", child: Text("MP3")),
              ],
            ),
            DropdownButton<String>(
              value: _selectedMode,
              onChanged: (newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedMode = newValue;
                  });
                }
              },
              items: const [
                DropdownMenuItem(value: "single", child: Text("Single")),
                DropdownMenuItem(value: "playlist", child: Text("Playlist")),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: Consumer<DownloadManager>(
                builder: (context, downloadManager, child) {
                  return Text(
                    downloadManager.downloadPath ?? "No download path selected",
                    overflow: TextOverflow.ellipsis,
                  );
                },
              ),
            ),
            IconButton(
              onPressed: () async {
                final downloadManager =
                    Provider.of<DownloadManager>(context, listen: false);
                String? path = await pickDownloadFolder();
                if (path != null) {
                  downloadManager.downloadPath = path;
                }
              },
              icon: const Icon(Icons.folder_open),
            ),
          ],
        ),
        ElevatedButton(
          onPressed: () {
            final downloadManager =
                Provider.of<DownloadManager>(context, listen: false);
            if (_urlController.text.isNotEmpty &&
                downloadManager.downloadPath != null) {
              final newTask = DownloadTask(
                url: _urlController.text,
                format: _selectedFormat,
                mode: _selectedMode,
                downloadPath: downloadManager.downloadPath!,
              );
              downloadManager.addToQueue(newTask);
              _urlController.clear();
            }
          },
          child: const Text("Add to Queue"),
        ),
      ],
    );
  }
  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }
}