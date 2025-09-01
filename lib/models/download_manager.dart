// lib/models/download_manager.dart

import 'package:flutter/material.dart';
import 'download_task.dart';
import '../services/downloader.dart';
import '../utils/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

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

  // Track URLs being downloaded to prevent duplicates
  Set<String> _activeDownloads = {};

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

  void _setMessage(String text, {required Color color, required IconData icon}) {
    uiMessage = DownloadManagerMessage(text, color: color, icon: icon);
    notifyListeners();
  }

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
    // Create unique identifier for this download
    String taskId = "${task.url}_${task.format}_${task.mode}";
    
    // Check if already downloading or in queue
    if (_activeDownloads.contains(taskId)) {
      _setMessage(
        "This download is already in progress.",
        color: Colors.orange,
        icon: Icons.warning,
      );
      return;
    }

    // Check if already in queue
    bool alreadyInQueue = downloadQueue.any((existingTask) =>
        existingTask.url == task.url &&
        existingTask.format == task.format &&
        existingTask.mode == task.mode);

    if (alreadyInQueue) {
      _setMessage(
        "This download is already in the queue.",
        color: Colors.orange,
        icon: Icons.warning,
      );
      return;
    }

    // Check if already completed
    bool alreadyCompleted = completedTasks.any((existingTask) =>
        existingTask.url == task.url &&
        existingTask.format == task.format &&
        existingTask.mode == task.mode);

    if (alreadyCompleted) {
      _setMessage(
        "This download was already completed.",
        color: Colors.blue,
        icon: Icons.check_circle,
      );
      return;
    }

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
    
    DownloadTask task = downloadQueue.first;
    String taskId = "${task.url}_${task.format}_${task.mode}";
    
    // Double-check if this download is already active
    if (_activeDownloads.contains(taskId)) {
      downloadQueue.removeAt(0);
      _processNextDownload();
      return;
    }
    
    _isDownloading = true;
    _activeDownloads.add(taskId);
    _startDownload(task);
  }

  void _startDownload(DownloadTask task) async {
    String taskId = "${task.url}_${task.format}_${task.mode}";
    
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
          _downloadComplete(task, taskId);
        },
        onError: (errorMessage) {
          _downloadError(task, taskId, errorMessage);
        },
        createPlaylistFolder: true,
      );
    } catch (e) {
      _downloadError(task, taskId, e.toString());
    }
  }

  void _downloadComplete(DownloadTask task, String taskId) {
    task.isDownloading = false;
    task.isProcessing = false;
    task.isCompleted = true;
    downloadQueue.remove(task);

    // Remove from active downloads
    _activeDownloads.remove(taskId);

    // Add to completed tasks if not already there
    bool alreadyCompleted = completedTasks.any((existingTask) =>
        existingTask.url == task.url &&
        existingTask.format == task.format &&
        existingTask.mode == task.mode);

    if (!alreadyCompleted) {
      completedTasks.add(task);
      _savePreferences();
    }

    _isDownloading = false;
    _setMessage(
      "Download complete!",
      color: Colors.green,
      icon: Icons.check_circle,
    );
    notifyListeners();
    _processNextDownload();
  }

  void _downloadError(DownloadTask task, String taskId, String errorMessage) {
    task.isDownloading = false;
    task.isProcessing = false;
    downloadQueue.remove(task);
    
    // Remove from active downloads
    _activeDownloads.remove(taskId);
    
    _isDownloading = false;
    _setMessage(
      "Download failed: $errorMessage",
      color: Colors.red,
      icon: Icons.error,
    );
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

  // Method to cancel a download if needed
  void cancelDownload(DownloadTask task) {
    String taskId = "${task.url}_${task.format}_${task.mode}";
    downloadQueue.remove(task);
    _activeDownloads.remove(taskId);
    
    if (task.isDownloading && _isDownloading) {
      _isDownloading = false;
      _processNextDownload();
    }
    
    _setMessage(
      "Download cancelled.",
      color: Colors.orange,
      icon: Icons.cancel,
    );
    notifyListeners();
  }
}
