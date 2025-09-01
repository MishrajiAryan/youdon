// lib/screens/components/completed_tasks.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/models/download_manager.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'dart:math';
import 'package:flutter/foundation.dart'; // for debugPrint and kDebugMode

class CompletedTasks extends StatefulWidget {
  const CompletedTasks({super.key});

  @override
  State<CompletedTasks> createState() => _CompletedTasksState();
}

class _CompletedTasksState extends State<CompletedTasks> {
  bool _recentFirst = true;

  IconData _getFormatIcon(String format) {
    switch (format) {
      case 'mp3':
        return Icons.audiotrack;
      case 'mp4':
        return Icons.videocam;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color _getFormatColor(String format, BuildContext context) {
    switch (format) {
      case 'mp3':
        return Theme.of(context).colorScheme.secondary;
      case 'mp4':
        return Theme.of(context).colorScheme.primary;
      default:
        return Colors.grey;
    }
  }

  void _showSnackBar(BuildContext context, String message, {Color? color, IconData? icon}) {
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: color ?? Colors.blueGrey,
          content: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: Colors.white),
                const SizedBox(width: 12),
              ],
              Expanded(child: Text(message, style: const TextStyle(color: Colors.white))),
            ],
          ),
        ),
      );
  }

  // Enhanced similarity function for fuzzy matching
  double _calculateSimilarity(String s1, String s2) {
    if (s1 == s2) return 1.0;
    if (s1.isEmpty || s2.isEmpty) return 0.0;

    // Convert to lowercase for case-insensitive comparison
    s1 = s1.toLowerCase();
    s2 = s2.toLowerCase();

    // Levenshtein distance-based similarity
    final len1 = s1.length;
    final len2 = s2.length;
    final maxLen = max(len1, len2);
    if (maxLen == 0) return 1.0;

    final distance = _levenshteinDistance(s1, s2);
    return 1.0 - (distance / maxLen);
  }

  // Levenshtein distance calculation (fixed initialization to avoid invalid_assignment)
  int _levenshteinDistance(String s1, String s2) {
    final len1 = s1.length;
    final len2 = s2.length;

    // Explicit generic types avoid inference pitfalls
    final List<List<int>> matrix = List<List<int>>.generate(
      len1 + 1,
      (_) => List<int>.filled(len2 + 1, 0, growable: false),
      growable: false,
    );

    for (int i = 0; i <= len1; i++) {
      matrix[i][0] = i;
    }
    for (int j = 0; j <= len2; j++) {
      matrix[0][j] = j;
    }

    for (int i = 1; i <= len1; i++) {
      for (int j = 1; j <= len2; j++) {
        final cost = s1[i - 1] == s2[j - 1] ? 0 : 1;
        matrix[i][j] = [
          matrix[i - 1][j] + 1, // deletion
          matrix[i][j - 1] + 1, // insertion
          matrix[i - 1][j - 1] + cost // substitution
        ].reduce(min);
      }
    }

    return matrix[len1][len2];
  }

  // Method to sanitize and normalize filenames for better matching
  String _sanitizeFileName(String fileName) {
    String sanitized = fileName;

    // Remove yt-dlp format codes like .f234, .F123, etc.
    sanitized = sanitized.replaceAll(RegExp(r'\.[fF]\d+'), '');

    // Normalize whitespace
    sanitized = sanitized.replaceAll(RegExp(r'\s+'), ' ');

    // Remove common special characters that might differ
    sanitized = sanitized.replaceAll(RegExp(r'[""｜|•·\-_()\[\]]'), '');

    // Remove common words that might be inconsistent
    sanitized = sanitized.replaceAll(
      RegExp(r'\b(full|song|with|lyrics|video|audio|official|hd|4k)\b', caseSensitive: false),
      '',
    );

    // Clean up extra spaces
    sanitized = sanitized.replaceAll(RegExp(r'\s+'), ' ');

    return sanitized.trim();
  }

  // Enhanced fuzzy file finder (expanded extensions and debugPrint)
  String? _findBestMatch(
    String targetName,
    List<FileSystemEntity> files,
    String format, {
    double threshold = 0.65,
  }) {
    final sanitizedTarget = _sanitizeFileName(targetName);
    debugPrint("DEBUG: Looking for fuzzy match for: '$sanitizedTarget'");

    // Broaden valid extensions to cover common outputs/conversions
    final List<String> validExtensions = format == 'mp3'
        ? <String>['.mp3', '.m4a', '.aac', '.opus', '.wav', '.flac']
        : <String>['.mp4', '.mkv', '.webm', '.mov', '.avi'];

    String? bestMatch;
    double bestSimilarity = 0.0;

    for (final file in files) {
      if (file is File) {
        final fileName = path.basename(file.path);
        final fileExtension = path.extension(file.path).toLowerCase();

        // Check if extension matches format
        if (!validExtensions.contains(fileExtension)) continue;

        final fileNameWithoutExt = path.basenameWithoutExtension(fileName);
        final sanitizedFileName = _sanitizeFileName(fileNameWithoutExt);

        // Calculate similarity
        double similarity = _calculateSimilarity(sanitizedTarget, sanitizedFileName);

        debugPrint("DEBUG: Comparing '$sanitizedTarget' with '$sanitizedFileName': similarity = $similarity");

        // Also check if one string contains the other (for partial matches)
        if (similarity < threshold) {
          if (sanitizedTarget.contains(sanitizedFileName) || sanitizedFileName.contains(sanitizedTarget)) {
            final containsSimilarity =
                min(sanitizedTarget.length, sanitizedFileName.length) /
                    max(sanitizedTarget.length, sanitizedFileName.length).toDouble();
            if (containsSimilarity > 0.5) {
              similarity = max(similarity, containsSimilarity);
              debugPrint("DEBUG: Boosted similarity using substring match: $similarity");
            }
          }
        }

        if (similarity > bestSimilarity && similarity >= threshold) {
          bestSimilarity = similarity;
          bestMatch = file.path;
          debugPrint("DEBUG: New best match: '$fileName' with similarity $similarity");
        }
      }
    }

    if (bestMatch != null) {
      debugPrint("DEBUG: Best match found: '$bestMatch' with similarity $bestSimilarity");
    } else {
      debugPrint("DEBUG: No match found above threshold $threshold");
    }

    return bestMatch;
  }

  // Enhanced method to find and open file with fuzzy matching
  Future<void> _openFile(String? storedFileName, String downloadPath, String format) async {
    if (storedFileName == null || storedFileName.isEmpty) {
      _showSnackBar(
        context,
        "File path not available.",
        color: Colors.red,
        icon: Icons.error,
      );
      return;
    }

    try {
      String? actualFilePath;

      debugPrint("DEBUG: Stored filename: $storedFileName");
      debugPrint("DEBUG: Download path: $downloadPath");
      debugPrint("DEBUG: Format: $format");

      // First try the original path
      final originalFile = File(storedFileName);
      if (await originalFile.exists()) {
        actualFilePath = storedFileName;
        debugPrint("DEBUG: Found file at original path: $actualFilePath");
      }

      // If not found, try fuzzy matching in download directory (recursive for playlist folders)
      if (actualFilePath == null) {
        debugPrint("DEBUG: Starting fuzzy search in download directory (recursive)...");
        final dir = Directory(downloadPath);
        if (await dir.exists()) {
          final files = await dir.list(recursive: true, followLinks: false).toList();
          debugPrint("DEBUG: Files in directory (recursive): ${files.length}");

          // Get the base name from stored filename for fuzzy matching
          final targetName = path.basenameWithoutExtension(storedFileName);

          // Try fuzzy matching with different thresholds
          actualFilePath = _findBestMatch(targetName, files, format, threshold: 0.75) ??
              _findBestMatch(targetName, files, format, threshold: 0.65) ??
              _findBestMatch(targetName, files, format, threshold: 0.55);
        }
      }

      if (actualFilePath == null) {
        debugPrint("DEBUG: File not found anywhere");
        if (!mounted) return;
        _showSnackBar(
          context,
          "File not found in download location",
          color: Colors.red,
          icon: Icons.error,
        );
        return;
      }

      debugPrint("DEBUG: Attempting to open file: $actualFilePath");

      // Try to open the file
      final result = await OpenFile.open(actualFilePath);
      if (!mounted) return;

      debugPrint("DEBUG: OpenFile result: ${result.type}, message: ${result.message}");

      final fallbackMessage = (result.message.isNotEmpty) ? result.message : 'Unknown error';

      switch (result.type) {
        case ResultType.done:
          _showSnackBar(
            context,
            "File opened successfully.",
            color: Colors.green,
            icon: Icons.check_circle,
          );
          break;
        case ResultType.fileNotFound:
          _showSnackBar(
            context,
            "File not found by system",
            color: Colors.red,
            icon: Icons.error,
          );
          break;
        case ResultType.noAppToOpen:
          _showSnackBar(
            context,
            "No app found to open this file type.",
            color: Colors.orange,
            icon: Icons.warning,
          );
          break;
        case ResultType.permissionDenied:
          _showSnackBar(
            context,
            "Permission denied to open file.",
            color: Colors.red,
            icon: Icons.block,
          );
          break;
        default:
          _showSnackBar(
            context,
            "Could not open file: $fallbackMessage",
            color: Colors.red,
            icon: Icons.error,
          );
      }
    } catch (e) {
      debugPrint("DEBUG: Exception occurred: $e");
      if (!mounted) return;
      _showSnackBar(
        context,
        "Error opening file: ${e.toString()}",
        color: Colors.red,
        icon: Icons.error,
      );
    }
  }

  // Method to open folder location; prefers the file's containing folder if available
  Future<void> _openFolder(String downloadPath, {String? targetFile}) async {
    try {
      String pathToOpen = downloadPath;
      if (targetFile != null && targetFile.isNotEmpty) {
        final parent = path.dirname(targetFile);
        if (await Directory(parent).exists()) {
          pathToOpen = parent;
        }
      }

      final result = await OpenFile.open(pathToOpen);
      if (!mounted) return;

      if (result.type == ResultType.done) {
        _showSnackBar(
          context,
          "Folder opened successfully.",
          color: Colors.green,
          icon: Icons.folder_open,
        );
      } else {
        _showSnackBar(
          context,
          "Could not open folder.",
          color: Colors.orange,
          icon: Icons.warning,
        );
      }
    } catch (e) {
      if (!mounted) return;
      _showSnackBar(
        context,
        "Error opening folder: ${e.toString()}",
        color: Colors.red,
        icon: Icons.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DownloadManager>(
      builder: (context, downloadManager, child) {
        var completed = List.of(downloadManager.completedTasks);
        if (_recentFirst) {
          completed = completed.reversed.toList();
        }

        if (completed.isEmpty) {
          return const Center(child: Text("No completed downloads yet."));
        }

        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  icon: Icon(_recentFirst ? Icons.arrow_downward : Icons.arrow_upward),
                  label: Text(_recentFirst ? "Recent First" : "Oldest First"),
                  onPressed: () => setState(() => _recentFirst = !_recentFirst),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.delete_sweep),
                  label: const Text("Clear All"),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  onPressed: () {
                    downloadManager.clearAllCompletedTasks();
                    _showSnackBar(
                      context,
                      "All completed tasks cleared.",
                      color: Colors.red,
                      icon: Icons.delete_sweep,
                    );
                  },
                ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemCount: completed.length,
                itemBuilder: (context, index) {
                  final task = completed[index];

                  // Use the actual stored filename and extension for display when available
                  String displayName;
                  if (task.fileName != null && task.fileName!.isNotEmpty) {
                    final base = path.basename(task.fileName!);
                    final baseNoExt = path.basenameWithoutExtension(base);
                    final ext = path.extension(base);
                    displayName = '${_sanitizeFileName(baseNoExt)}$ext';
                  } else {
                    displayName = task.url;
                  }

                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Card(
                      elevation: 5,
                      shadowColor: Colors.black26,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getFormatColor(task.format, context).withValues(alpha: 0.15),
                          child: Icon(
                            _getFormatIcon(task.format),
                            color: _getFormatColor(task.format, context),
                          ),
                        ),
                        title: Text(
                          displayName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          '${task.format == "mp3" ? "Audio" : "Video"} • ${task.mode == "playlist" ? "Playlist" : "Single"}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Open file button
                            IconButton(
                              icon: const Icon(Icons.play_arrow, color: Colors.blue),
                              tooltip: "Open File",
                              onPressed: () => _openFile(task.fileName, task.downloadPath, task.format),
                            ),
                            // Open folder button (opens containing folder if known)
                            IconButton(
                              icon: const Icon(Icons.folder_open, color: Colors.green),
                              tooltip: "Open Folder",
                              onPressed: () => _openFolder(task.downloadPath, targetFile: task.fileName),
                            ),
                            // Delete button
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              tooltip: "Delete from List",
                              onPressed: () {
                                downloadManager.removeCompletedTask(task);
                                _showSnackBar(
                                  context,
                                  "Task deleted from list.",
                                  color: Colors.red,
                                  icon: Icons.delete,
                                );
                              },
                            ),
                          ],
                        ),
                        onTap: () => _openFile(task.fileName, task.downloadPath, task.format),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
