// downloader.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

Future<void> startDownload({
  required String url,
  required String format,
  required String downloadMode,
  required String downloadPath,
  required Function(double) onProgress,
  required Function(String) onError,
  required Function() onComplete,
  required bool createPlaylistFolder,
}) async {
  String ytDlpPath = "dependencies/yt-dlp.exe"; // Path to yt-dlp executable
  String ffmpegPath = "dependencies/ffmpeg/bin/ffmpeg.exe"; // Path to ffmpeg

  Map<String, String> envVars = {"FFMPEG_BINARY": ffmpegPath};

  List<String> ytDlpArgs = [
    "--ffmpeg-location",
    ffmpegPath,
    "--add-metadata",
    "--embed-thumbnail",
  ];

  String outputPath = downloadPath;
  String fileNameTemplate = "%(title)s.%(ext)s"; // File naming template

  if (downloadMode == "playlist" && createPlaylistFolder) {
    String playlistFolderName = "%(playlist_title)s"; // Playlist folder name
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
      "-f",
      "bestaudio",
      "--extract-audio",
      "--audio-format",
      "mp3",
      "--audio-quality",
      "0"
    ]);
  }

  ytDlpArgs.add(downloadMode == "single" ? "--no-playlist" : "--yes-playlist");
  ytDlpArgs.add(url);

  try {
    debugPrint("Starting download...");
    Process ytDlpProcess = await Process.start(
      ytDlpPath,
      ytDlpArgs,
      environment: envVars,
    );

    ytDlpProcess.stdout.transform(utf8.decoder).listen((data) {
      debugPrint("yt-dlp output: $data");
      double progress = _parseProgress(data);
      onProgress(progress);
    }, onError: (error) {
      debugPrint("yt-dlp error: $error");
      onError(error.toString());
    }, onDone: () {
      debugPrint("yt-dlp finished");
      onComplete(); // Title fetching removed
    });

    ytDlpProcess.stderr.transform(utf8.decoder).listen((data) {
      debugPrint("yt-dlp error: $data");
      onError(data);
    });

    int exitCode = await ytDlpProcess.exitCode;
    if (exitCode == 0 || exitCode == 1) {
      debugPrint("Download complete");
      onComplete(); // No title to fetch
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
  RegExp regex = RegExp(r'\b(\d+\.\d+)%');
  Match? match = regex.firstMatch(output);
  return match != null ? double.parse(match.group(1)!) / 100 : 0.0;
}