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
        color: const Color(0xFFEF4444),
        icon: Icons.error_outline_rounded,
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
        "📁 Download folder selected successfully!",
        color: const Color(0xFF10B981),
        icon: Icons.folder_open_rounded,
      );
      notifyListeners();
    } else {
      _setMessage(
        "Failed to select download folder.",
        color: const Color(0xFFEF4444),
        icon: Icons.folder_off_rounded,
      );
    }
  }

  void addToQueue(DownloadTask task) {
    // Create unique identifier for this download
    String taskId = "${task.url}_${task.format}_${task.mode}";
    
    // Check if already downloading or in queue
    if (_activeDownloads.contains(taskId)) {
      _setMessage(
        "⚠️ This download is already in progress.",
        color: const Color(0xFFF59E0B),
        icon: Icons.warning_rounded,
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
        "⚠️ This download is already in the queue.",
        color: const Color(0xFFF59E0B),
        icon: Icons.warning_rounded,
      );
      return;
    }

    // REMOVED: Check if already completed - users can now re-download completed tasks

    downloadQueue.add(task);
    _setMessage(
      "✅ Download added to queue successfully!",
      color: const Color(0xFF10B981),
      icon: Icons.download_rounded,
    );
    notifyListeners();
    _processNextDownload();
  }

  // NEW: Requeue functionality to move completed task back to active queue
  void requeueTask(DownloadTask completedTask) {
    // Create a new task based on the completed one (reset progress and status)
    final newTask = DownloadTask(
      url: completedTask.url,
      format: completedTask.format,
      mode: completedTask.mode,
      downloadPath: completedTask.downloadPath,
    );
    
    // Add to queue using existing addToQueue method (handles duplicates)
    String taskId = "${newTask.url}_${newTask.format}_${newTask.mode}";
    
    // Check if already in active downloads or queue
    if (_activeDownloads.contains(taskId)) {
      _setMessage(
        "⚠️ This download is already active.",
        color: const Color(0xFFF59E0B),
        icon: Icons.warning_rounded,
      );
      return;
    }

    bool alreadyInQueue = downloadQueue.any((existingTask) =>
        existingTask.url == newTask.url &&
        existingTask.format == newTask.format &&
        existingTask.mode == newTask.mode);

    if (alreadyInQueue) {
      _setMessage(
        "⚠️ This download is already in the active queue.",
        color: const Color(0xFFF59E0B),
        icon: Icons.warning_rounded,
      );
      return;
    }

    // Add to queue
    downloadQueue.add(newTask);
    
    _setMessage(
      "🔄 Download re-added to queue successfully!",
      color: const Color(0xFF10B981),
      icon: Icons.refresh_rounded,
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
      "🎉 Download completed successfully!",
      color: const Color(0xFF10B981),
      icon: Icons.check_circle_rounded,
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
      "❌ Download failed: $errorMessage",
      color: const Color(0xFFEF4444),
      icon: Icons.error_outline_rounded,
    );
    notifyListeners();
    _processNextDownload();
  }

  void removeCompletedTask(DownloadTask task) {
    completedTasks.remove(task);
    _savePreferences();
    _setMessage(
      "🗑️ Task removed from completed list.",
      color: const Color(0xFFEF4444),
      icon: Icons.delete_rounded,
    );
    notifyListeners();
  }

  void clearAllCompletedTasks() {
    completedTasks.clear();
    _savePreferences();
    _setMessage(
      "🧹 All completed tasks cleared successfully!",
      color: const Color(0xFFEF4444),
      icon: Icons.delete_sweep_rounded,
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
      "🚫 Download cancelled successfully.",
      color: const Color(0xFFF59E0B),
      icon: Icons.cancel_rounded,
    );
    notifyListeners();
  }

  // Helper method to get queue status
  bool get isDownloadInProgress => _isDownloading;
  
  int get queueCount => downloadQueue.length;
  
  int get completedCount => completedTasks.length;
  
  // Helper method to check if a specific URL is already processed
  bool isUrlAlreadyProcessed(String url, String format, String mode) {
    String taskId = "${url}_${format}_${mode}";
    
    // Check if in active downloads
    if (_activeDownloads.contains(taskId)) return true;
    
    // Check if in queue
    if (downloadQueue.any((task) => 
        task.url == url && task.format == format && task.mode == mode)) {
      return true;
    }
    
    // REMOVED: Check if in completed tasks - allow re-downloading completed tasks
    
    return false;
  }
  
  // Helper method to get download statistics
  Map<String, dynamic> getDownloadStats() {
    return {
      'totalCompleted': completedTasks.length,
      'activeDownloads': downloadQueue.length,
      'isDownloading': _isDownloading,
      'audioDownloads': completedTasks.where((task) => task.format == 'mp3').length,
      'videoDownloads': completedTasks.where((task) => task.format == 'mp4').length,
      'playlistDownloads': completedTasks.where((task) => task.mode == 'playlist').length,
      'singleDownloads': completedTasks.where((task) => task.mode == 'single').length,
    };
  }
}
