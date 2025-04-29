// lib/models/download_task.dart

class DownloadTask {
  String url;
  String format;
  String mode;
  String downloadPath;
  double progress;
  bool isCompleted;
  bool isDownloading;
  bool isProcessing; // <-- NEW: Track processing state (FFmpeg, extraction, etc.)
  String? fileName;

  DownloadTask({
    required this.url,
    required this.format,
    required this.mode,
    required this.downloadPath,
    this.progress = 0.0,
    this.isCompleted = false,
    this.isDownloading = false,
    this.isProcessing = false, // <-- NEW: default to false
    this.fileName,
  });

  factory DownloadTask.fromJson(Map<String, dynamic> json) => DownloadTask(
        url: json['url'],
        format: json['format'],
        mode: json['mode'],
        downloadPath: json['downloadPath'],
        progress: (json['progress'] as num).toDouble(),
        isCompleted: json['isCompleted'],
        isDownloading: json['isDownloading'],
        isProcessing: json['isProcessing'] ?? false, // <-- NEW: handle null for older data
        fileName: json['fileName'],
      );

  Map<String, dynamic> toJson() => {
        'url': url,
        'format': format,
        'mode': mode,
        'downloadPath': downloadPath,
        'progress': progress,
        'isCompleted': isCompleted,
        'isDownloading': isDownloading,
        'isProcessing': isProcessing, // <-- NEW
        'fileName': fileName,
      };
}
