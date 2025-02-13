class DownloadTask {
  String url;
  String format;
  String mode;
  String downloadPath;
  double progress;
  bool isCompleted;
  bool isDownloading;
  String? title; // Add title property, nullable

  DownloadTask({
    required this.url,
    required this.format,
    required this.mode,
    required this.downloadPath,
    this.progress = 0.0,
    this.isCompleted = false,
    this.isDownloading = false,
    this.title, // Initialize title, can be null
  });

  factory DownloadTask.fromJson(Map<String, dynamic> json) => DownloadTask(
        url: json['url'],
        format: json['format'],
        mode: json['mode'],
        downloadPath: json['downloadPath'],
        progress: (json['progress'] as num).toDouble(),
        isCompleted: json['isCompleted'],
        isDownloading: json['isDownloading'],
        title: json['title'], // Deserialize title
      );

  Map<String, dynamic> toJson() => {
        'url': url,
        'format': format,
        'mode': mode,
        'downloadPath': downloadPath,
        'progress': progress,
        'isCompleted': isCompleted,
        'isDownloading': isDownloading,
        'title': title, // Serialize title
      };
}