// lib/services/downloader.dart

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

/// Starts a download using yt-dlp and FFmpeg, tracking download and processing stages.
/// 
/// [onProgress] is called with a value from 0.0 to 1.0 during downloading.
/// [onProcessing] is called when post-processing (FFmpeg, extraction) begins.
/// [onFileName] is called with the output filename (if detected).
/// [onComplete] is called only when all processing is finished.
/// [onError] is called with an error message.
Future<void> startDownload({
  required String url,
  required String format,
  required String downloadMode,
  required String downloadPath,
  required Function(double) onProgress,
  required Function(String) onError,
  required Function() onComplete,
  required bool createPlaylistFolder,
  Function()? onProcessing, // <-- NEW: callback for processing state
  Function(String)? onFileName,
}) async {
  String ytDlpPath = "dependencies/yt-dlp.exe";
  String ffmpegPath = "dependencies/ffmpeg/bin/ffmpeg.exe";

  Map<String, String> envVars = {"FFMPEG_BINARY": ffmpegPath};

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

  if (format == "mp4") {
    ytDlpArgs.addAll(["-f", "bestvideo+bestaudio", "--merge-output-format", "mp4"]);
  } else {
    ytDlpArgs.addAll([
      "-f", "bestaudio",
      "--extract-audio",
      "--audio-format", "mp3",
      "--audio-quality", "0"
    ]);
  }

  ytDlpArgs.add(downloadMode == "single" ? "--no-playlist" : "--yes-playlist");
  ytDlpArgs.add(url);

  bool isProcessing = false;
  bool isDownloadFinished = false;

  try {
    debugPrint("Starting download...");
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
      if ((data.contains("[ffmpeg]") || data.contains("[ExtractAudio]") || data.contains("Merging formats into")) && !isProcessing) {
        isProcessing = true;
        if (onProcessing != null) onProcessing();
      }

      // Detect download finished (but not necessarily processing)
      if (data.contains("[download] 100%") || data.contains("[download] Finished downloading")) {
        isDownloadFinished = true;
        // Progress should be 1.0 at this point
        onProgress(1.0);
      }
    }, onError: (error) {
      debugPrint("yt-dlp error: $error");
      onError(error.toString());
    });

    ytDlpProcess.stderr.transform(utf8.decoder).listen((data) {
      debugPrint("yt-dlp stderr: $data");
      // Optionally, parse FFmpeg/yt-dlp errors here
      // onError(data);
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
  // Looks for lines like: [download]  45.3% of ...
  RegExp regex = RegExp(r'\[download\]\s+(\d+\.\d+)%');
  Match? match = regex.firstMatch(output);
  return match != null ? double.parse(match.group(1)!) / 100 : 0.0;
}
