// download_input.dart
import 'package:flutter/material.dart';

class DownloadInput extends StatelessWidget {
  final TextEditingController urlController;
  final String selectedFormat;
  final String selectedMode;
  final String? downloadPath;
  final ValueChanged<String?> onFormatChanged;
  final ValueChanged<String?> onModeChanged;
  final VoidCallback onSelectDownloadPath;
  final VoidCallback onAddToQueue;

  const DownloadInput({
    super.key,
    required this.urlController,
    required this.selectedFormat,
    required this.selectedMode,
    required this.downloadPath,
    required this.onFormatChanged,
    required this.onModeChanged,
    required this.onSelectDownloadPath,
    required this.onAddToQueue,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: urlController,
          decoration: const InputDecoration(labelText: "YouTube URL"),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            DropdownButton<String>(
              value: selectedFormat,
              onChanged: onFormatChanged,
              items: const [
                DropdownMenuItem(value: "mp4", child: Text("MP4")),
                DropdownMenuItem(value: "mp3", child: Text("MP3")),
              ],
            ),
            DropdownButton<String>(
              value: selectedMode,
              onChanged: onModeChanged,
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
              child: Text(
                downloadPath ?? "No download path selected",
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              onPressed: onSelectDownloadPath,
              icon: const Icon(Icons.folder_open),
            ),
          ],
        ),
        ElevatedButton(
          onPressed: onAddToQueue,
          child: const Text("Add to Queue"),
        ),
      ],
    );
  }
}