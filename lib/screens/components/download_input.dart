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

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // URL Input Field
            TextField(
              controller: _urlController,
              decoration: InputDecoration(
                labelText: "Enter YouTube URL",
                prefixIcon: const Icon(Icons.link),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 10),

            // Format & Mode Selection
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDropdown(
                  value: _selectedFormat,
                  items: const ["mp4", "mp3"],
                  onChanged: (value) => setState(() => _selectedFormat = value),
                  icon: Icons.video_library,
                  label: "Format",
                ),
                _buildDropdown(
                  value: _selectedMode,
                  items: const ["single", "playlist"],
                  onChanged: (value) => setState(() => _selectedMode = value),
                  icon: Icons.playlist_play,
                  label: "Mode",
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Folder Selection
            Consumer<DownloadManager>(
              builder: (context, downloadManager, child) {
                return Row(
                  children: [
                    Expanded(
                      child: Text(
                        downloadManager.downloadPath ?? "No download path selected",
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        final path = await pickDownloadFolder();
                        if (path != null) {
                          downloadManager.setDownloadPath();
                        }
                      },
                      icon: const Icon(Icons.folder_open),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 10),

            // Download Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                icon: const Icon(Icons.download),
                label: const Text("Add to Queue"),
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Custom Dropdown Builder
  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required void Function(String) onChanged,
    required IconData icon,
    required String label,
  }) {
    return Expanded(
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onChanged: (newValue) => onChanged(newValue!),
        items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
      ),
    );
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }
}
