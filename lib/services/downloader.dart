import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

/// Download states for UI feedback
enum DownloadStage {
  preparing,
  downloading,
  processing,
  completed,
  error,
}

/// Starts a download using yt-dlp with optimized best format selection
Future<void> startDownload({
  required String url,
  required String format,
  required String downloadMode,
  required String downloadPath,
  required Function(double) onProgress,
  required Function(String) onError,
  required Function() onComplete,
  required bool createPlaylistFolder,
  Function()? onProcessing,
  Function(String)? onFileName,
}) async {
  String ytDlpPath = "dependencies/yt-dlp.exe";
  String ffmpegPath = "dependencies/ffmpeg/bin/ffmpeg.exe";

  Map<String, String> envVars = {"FFMPEG_BINARY": ffmpegPath};

  try {
    List<String> ytDlpArgs = [
      "--ffmpeg-location",
      ffmpegPath,
      "--add-metadata",
      "--embed-thumbnail",
    ];

    String outputPath = downloadPath;
    String fileNameTemplate = "%(title)s.%(ext)s";

    if (downloadMode == "playlist" && createPlaylistFolder) {
      String playlistFolderName = "%(playlist_title)s";
      outputPath = p.join(downloadPath, playlistFolderName);

      try {
        await Directory(outputPath).create(recursive: true);
        debugPrint("Playlist folder created: $outputPath");
      } catch (e) {
        onError("Error creating playlist folder: $e");
        return;
      }
    }

    ytDlpArgs.addAll(["-o", p.join(outputPath, fileNameTemplate)]);

    // Use yt-dlp's built-in best format selection (much faster)
    if (format == "mp3") {
      ytDlpArgs.addAll([
        "-f", "bestaudio/best",
        "--extract-audio",
        "--audio-format", "mp3",
        "--audio-quality", "0", // Best quality
        "--embed-thumbnail",
        "--add-metadata",
      ]);
    } else {
      // For video: improved format selection for best quality
      ytDlpArgs.addAll([
        "-f", "bestvideo+bestaudio/best",
        "--merge-output-format", "mp4",
        "--embed-thumbnail",
        "--add-metadata",
      ]);
    }


    ytDlpArgs.add(downloadMode == "single" ? "--no-playlist" : "--yes-playlist");
    ytDlpArgs.add(url);

    bool isProcessing = false;
    bool isDownloadFinished = false;

    debugPrint("Starting download with optimized format selection");
    Process ytDlpProcess = await Process.start(
      ytDlpPath,
      ytDlpArgs,
      environment: envVars,
    );

    ytDlpProcess.stdout.transform(utf8.decoder).listen((data) {
      debugPrint("yt-dlp output: $data");

      // Detect file name
      final fileMatch = RegExp(r'\[download\] Destination: (.+)').firstMatch(data);
      if (fileMatch != null && onFileName != null) {
        onFileName(fileMatch.group(1)!);
      }

      // Detect download progress
      if (data.contains("[download]")) {
        double progress = _parseProgress(data);
        onProgress(progress);
      }

      // Detect start of processing (FFmpeg, extraction, merging, etc.)
      if ((data.contains("[ffmpeg]") || 
           data.contains("[ExtractAudio]") || 
           data.contains("Merging formats into") ||
           data.contains("Deleting original file")) && !isProcessing) {
        isProcessing = true;
        if (onProcessing != null) onProcessing();
      }

      // Detect download finished
      if (data.contains("[download] 100%") || data.contains("[download] Finished downloading")) {
        isDownloadFinished = true;
        onProgress(1.0);
      }
    }, onError: (error) {
      debugPrint("yt-dlp error: $error");
      onError(error.toString());
    });

    ytDlpProcess.stderr.transform(utf8.decoder).listen((data) {
      debugPrint("yt-dlp stderr: $data");
      if (data.contains("ERROR") || data.contains("Error")) {
        onError(data);
      }
    });

    int exitCode = await ytDlpProcess.exitCode;
    if (exitCode == 0) {
      debugPrint("Download and processing complete");
      onProgress(1.0);
      onComplete();
    } else {
      debugPrint("Download failed with exit code $exitCode");
      onError("yt-dlp exited with code $exitCode");
    }
  } catch (e) {
    debugPrint("Error during download: $e");
    onError(e.toString());
  }
}

double _parseProgress(String output) {
  RegExp regex = RegExp(r'\[download\]\s+(\d+\.\d+)%');
  Match? match = regex.firstMatch(output);
  return match != null ? double.parse(match.group(1)!) / 100 : 0.0;
}
