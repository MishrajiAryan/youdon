// download_task.dart
class DownloadTask {
  String url;
  String format;
  String mode;
  String downloadPath;
  double progress;
  bool isCompleted;
  bool isDownloading;
  // Removed title property

  DownloadTask({
    required this.url,
    required this.format,
    required this.mode,
    required this.downloadPath,
    this.progress = 0.0,
    this.isCompleted = false,
    this.isDownloading = false,
  });

  factory DownloadTask.fromJson(Map<String, dynamic> json) => DownloadTask(
        url: json['url'],
        format: json['format'],
        mode: json['mode'],
        downloadPath: json['downloadPath'],
        progress: (json['progress'] as num).toDouble(),
        isCompleted: json['isCompleted'],
        isDownloading: json['isDownloading'],
      );

  Map<String, dynamic> toJson() => {
        'url': url,
        'format': format,
        'mode': mode,
        'downloadPath': downloadPath,
        'progress': progress,
        'isCompleted': isCompleted,
        'isDownloading': isDownloading,
      };
}