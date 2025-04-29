// lib/models/download_manager.dart

import 'package:flutter/material.dart';
import 'download_task.dart';
import '../services/downloader.dart';
import '../utils/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// A simple class to represent UI messages for snackbars/banners.
class DownloadManagerMessage {
  final String text;
  final Color color;
  final IconData icon;

  DownloadManagerMessage(this.text, {required this.color, required this.icon});
}

class DownloadManager extends ChangeNotifier {
  List<DownloadTask> downloadQueue = [];
  List<DownloadTask> completedTasks = [];
  String? downloadPath;
  bool _isDownloading = false;

  // Message for UI to display as snackbar/banner. UI should clear after showing.
  DownloadManagerMessage? uiMessage;

  DownloadManager() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    downloadPath = prefs.getString('downloadPath');
    String? completedTasksJson = prefs.getString('completedTasks');
    try {
      completedTasks = (completedTasksJson == null || completedTasksJson.isEmpty)
          ? []
          : (jsonDecode(completedTasksJson) as List)
              .map((taskJson) => DownloadTask.fromJson(taskJson))
              .toList();
    } catch (e) {
      completedTasks = [];
      _setMessage(
        "Error loading completed tasks.",
        color: Colors.red,
        icon: Icons.error,
      );
    }
  }

  Future<void> _savePreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('downloadPath', downloadPath ?? "");
    String completedTasksJson =
        jsonEncode(completedTasks.map((task) => task.toJson()).toList());
    await prefs.setString('completedTasks', completedTasksJson);
  }

  /// Sets a message for the UI to display (snackbar/banner).
  void _setMessage(String text, {required Color color, required IconData icon}) {
    uiMessage = DownloadManagerMessage(text, color: color, icon: icon);
    notifyListeners();
  }

  /// Call this from UI after displaying the snackbar/banner.
  void clearMessage() {
    uiMessage = null;
  }

  Future<void> setDownloadPath() async {
    String? path = await pickDownloadFolder();
    if (path != null) {
      downloadPath = path;
      await _savePreferences();
      _setMessage(
        "Download folder set.",
        color: Colors.green,
        icon: Icons.folder_open,
      );
      notifyListeners();
    } else {
      _setMessage(
        "Failed to set download folder.",
        color: Colors.red,
        icon: Icons.folder_off,
      );
    }
  }

  void addToQueue(DownloadTask task) {
    downloadQueue.add(task);
    _setMessage(
      "Download added to queue.",
      color: Colors.green,
      icon: Icons.download,
    );
    notifyListeners();
    _processNextDownload();
  }

  void _processNextDownload() {
    if (_isDownloading || downloadQueue.isEmpty) return;
    _isDownloading = true;
    DownloadTask task = downloadQueue.first;
    _startDownload(task);
  }

  void _startDownload(DownloadTask task) async {
    task.isDownloading = true;
    task.isProcessing = false;
    notifyListeners();

    try {
      await startDownload(
        url: task.url,
        format: task.format,
        downloadMode: task.mode,
        downloadPath: downloadPath!,
        onProgress: (progress) {
          // Animated progress updates
          task.progress = progress;
          notifyListeners();
        },
        onFileName: (fileName) {
          task.fileName = fileName;
          notifyListeners();
        },
        onProcessing: () {
          task.isProcessing = true;
          notifyListeners();
        },
        onComplete: () {
          downloadComplete(task);
          _setMessage(
            "Download complete!",
            color: Colors.green,
            icon: Icons.check_circle,
          );
        },
        onError: (errorMessage) {
          task.isDownloading = false;
          task.isProcessing = false;
          _isDownloading = false;
          notifyListeners();
          _setMessage(
            "Download failed: $errorMessage",
            color: Colors.red,
            icon: Icons.error,
          );
          _processNextDownload();
        },
        createPlaylistFolder: true,
      );
    } catch (e) {
      task.isDownloading = false;
      task.isProcessing = false;
      _isDownloading = false;
      notifyListeners();
      _setMessage(
        "Download error: $e",
        color: Colors.red,
        icon: Icons.error,
      );
      _processNextDownload();
    }
  }

  void downloadComplete(DownloadTask task) {
    task.isDownloading = false;
    task.isProcessing = false;
    task.isCompleted = true;
    downloadQueue.remove(task);

    bool alreadyCompleted = completedTasks.any((existingTask) =>
        existingTask.url == task.url &&
        existingTask.format == task.format &&
        existingTask.mode == task.mode);

    if (!alreadyCompleted) {
      completedTasks.add(task);
      _savePreferences();
    }

    _isDownloading = false;
    notifyListeners();
    _processNextDownload();
  }

  void removeCompletedTask(DownloadTask task) {
    completedTasks.remove(task);
    _savePreferences();
    _setMessage(
      "Task deleted.",
      color: Colors.red,
      icon: Icons.delete,
    );
    notifyListeners();
  }

  void clearAllCompletedTasks() {
    completedTasks.clear();
    _savePreferences();
    _setMessage(
      "All completed tasks cleared.",
      color: Colors.red,
      icon: Icons.delete_sweep,
    );
    notifyListeners();
  }
}
