// download_manager.dart
import 'package:flutter/material.dart';
import 'download_task.dart'; // Import your DownloadTask model
import '../services/downloader.dart'; // Import your downloader service
import '../utils/file_picker.dart'; // Import file picker if needed for setting path
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';


class DownloadManager extends ChangeNotifier {
  List<DownloadTask> downloadQueue = [];
  List<DownloadTask> completedTasks = [];
  String? downloadPath;

  DownloadManager() {
    _loadPreferences(); // Load preferences when DownloadManager is created
  }

  Future<void> _loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    downloadPath = prefs.getString('downloadPath'); // Load download path

    String? completedTasksJson = prefs.getString('completedTasks');
    if (completedTasksJson != null) {
      try {
        completedTasks = (jsonDecode(completedTasksJson) as List)
            .map((taskJson) => DownloadTask.fromJson(taskJson))
            .toList();
      } catch (e) {
        debugPrint("Error loading completed tasks: $e");
        completedTasks = [];
      }
    }
  }

  Future<void> _savePreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('downloadPath', downloadPath ?? ""); // Save download path

    String completedTasksJson = jsonEncode(completedTasks.map((task) => task.toJson()).toList());
    await prefs.setString('completedTasks', completedTasksJson);
  }

  Future<void> setDownloadPath() async {
    String? path = await pickDownloadFolder();
    if (path != null) {
      downloadPath = path;
      _savePreferences();
      notifyListeners();
    }
  }

  void addToQueue(DownloadTask task) {
    downloadQueue.add(task);
    notifyListeners();
    _startDownload(task);
  }

  void _startDownload(DownloadTask task) async {
    task.isDownloading = true;
    notifyListeners();

    try {
      await startDownload(
        url: task.url,
        format: task.format,
        downloadMode: task.mode,
        downloadPath: downloadPath!,
        onProgress: (progress) {
          task.progress = progress;
          notifyListeners();
        },
        onComplete: () {
          downloadComplete(task);
        },
        onError: (errorMessage) {
          task.isDownloading = false;
          notifyListeners();
          debugPrint("Download Error for: ${task.url}: $errorMessage");
        },
        createPlaylistFolder: true,
      );
    } catch (e) {
      task.isDownloading = false;
      notifyListeners();
      debugPrint("Exception in _startDownload: $e");
    }
  }

  void downloadComplete(DownloadTask task) {
    task.isDownloading = false;
    task.isCompleted = true;
    downloadQueue.remove(task);

    // Check for duplicates before adding:
    bool alreadyCompleted = completedTasks.any((existingTask) =>
        existingTask.url == task.url &&
        existingTask.format == task.format &&
        existingTask.mode == task.mode);

    if (!alreadyCompleted) {
      completedTasks.add(task);
      _savePreferences();
    }

    notifyListeners();
  }

  void removeCompletedTask(DownloadTask task) {
    completedTasks.remove(task);
    _savePreferences();
    notifyListeners();
  }
}