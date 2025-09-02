// lib/screens/components/completed_tasks.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '/models/download_manager.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'dart:math';
import 'package:flutter/foundation.dart';

class CompletedTasks extends StatefulWidget {
  const CompletedTasks({super.key});

  @override
  State<CompletedTasks> createState() => _CompletedTasksState();
}

class _CompletedTasksState extends State<CompletedTasks>
    with TickerProviderStateMixin {
  bool _recentFirst = true;
  late AnimationController _listAnimationController;

  @override
  void initState() {
    super.initState();
    _listAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _listAnimationController.forward();
  }

  @override
  void dispose() {
    _listAnimationController.dispose();
    super.dispose();
  }

  IconData _getFormatIcon(String format) {
    switch (format) {
      case 'mp3':
        return Icons.audiotrack_rounded;
      case 'mp4':
        return Icons.videocam_rounded;
      default:
        return Icons.insert_drive_file_rounded;
    }
  }

  Color _getFormatColor(String format, BuildContext context) {
    switch (format) {
      case 'mp3':
        return const Color(0xFF8B5CF6);
      case 'mp4':
        return const Color(0xFF3B82F6);
      default:
        return const Color(0xFF64748B);
    }
  }

  void _showSnackBar(BuildContext context, String message, {Color? color, IconData? icon}) {
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.05,
            vertical: 16,
          ),
          backgroundColor: color ?? const Color(0xFF6366F1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 12,
          content: Container(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                if (icon != null) ...[
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Text(
                    message,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          duration: const Duration(seconds: 4),
        ),
      );
  }

  // Enhanced similarity function for fuzzy matching
  double _calculateSimilarity(String s1, String s2) {
    if (s1 == s2) return 1.0;
    if (s1.isEmpty || s2.isEmpty) return 0.0;

    s1 = s1.toLowerCase();
    s2 = s2.toLowerCase();

    final len1 = s1.length;
    final len2 = s2.length;
    final maxLen = max(len1, len2);
    if (maxLen == 0) return 1.0;

    final distance = _levenshteinDistance(s1, s2);
    return 1.0 - (distance / maxLen);
  }

  int _levenshteinDistance(String s1, String s2) {
    final len1 = s1.length;
    final len2 = s2.length;

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
          matrix[i - 1][j] + 1,
          matrix[i][j - 1] + 1,
          matrix[i - 1][j - 1] + cost
        ].reduce(min);
      }
    }

    return matrix[len1][len2];
  }

  String _sanitizeFileName(String fileName) {
    String sanitized = fileName;
    sanitized = sanitized.replaceAll(RegExp(r'\.[fF]\d+'), '');
    sanitized = sanitized.replaceAll(RegExp(r'\s+'), ' ');
    sanitized = sanitized.replaceAll(RegExp(r'[""｜|•·\-_()\[\]]'), '');
    sanitized = sanitized.replaceAll(
      RegExp(r'\b(full|song|with|lyrics|video|audio|official|hd|4k)\b', caseSensitive: false),
      '',
    );
    sanitized = sanitized.replaceAll(RegExp(r'\s+'), ' ');
    return sanitized.trim();
  }

  String? _findBestMatch(
    String targetName,
    List<FileSystemEntity> files,
    String format, {
    double threshold = 0.65,
  }) {
    final sanitizedTarget = _sanitizeFileName(targetName);
    debugPrint("DEBUG: Looking for fuzzy match for: '$sanitizedTarget'");

    final List<String> validExtensions = format == 'mp3'
        ? ['.mp3', '.m4a', '.aac', '.opus', '.wav', '.flac']
        : ['.mp4', '.mkv', '.webm', '.mov', '.avi'];

    String? bestMatch;
    double bestSimilarity = 0.0;

    for (final file in files) {
      if (file is File) {
        final fileName = path.basename(file.path);
        final fileExtension = path.extension(file.path).toLowerCase();

        if (!validExtensions.contains(fileExtension)) continue;

        final fileNameWithoutExt = path.basenameWithoutExtension(fileName);
        final sanitizedFileName = _sanitizeFileName(fileNameWithoutExt);

        double similarity = _calculateSimilarity(sanitizedTarget, sanitizedFileName);

        if (similarity < threshold) {
          if (sanitizedTarget.contains(sanitizedFileName) || sanitizedFileName.contains(sanitizedTarget)) {
            final containsSimilarity =
                min(sanitizedTarget.length, sanitizedFileName.length) /
                    max(sanitizedTarget.length, sanitizedFileName.length).toDouble();
            if (containsSimilarity > 0.5) {
              similarity = max(similarity, containsSimilarity);
            }
          }
        }

        if (similarity > bestSimilarity && similarity >= threshold) {
          bestSimilarity = similarity;
          bestMatch = file.path;
        }
      }
    }

    return bestMatch;
  }

  Future<void> _openFile(String? storedFileName, String downloadPath, String format) async {
    if (storedFileName == null || storedFileName.isEmpty) {
      _showSnackBar(
        context,
        "File path not available.",
        color: const Color(0xFFEF4444),
        icon: Icons.error_outline_rounded,
      );
      return;
    }

    try {
      String? actualFilePath;

      final originalFile = File(storedFileName);
      if (await originalFile.exists()) {
        actualFilePath = storedFileName;
      }

      if (actualFilePath == null) {
        final dir = Directory(downloadPath);
        if (await dir.exists()) {
          final files = await dir.list(recursive: true, followLinks: false).toList();
          final targetName = path.basenameWithoutExtension(storedFileName);
          
          actualFilePath = _findBestMatch(targetName, files, format, threshold: 0.75) ??
              _findBestMatch(targetName, files, format, threshold: 0.65) ??
              _findBestMatch(targetName, files, format, threshold: 0.55);
        }
      }

      if (actualFilePath == null) {
        if (!mounted) return;
        _showSnackBar(
          context,
          "File not found in download location",
          color: const Color(0xFFEF4444),
          icon: Icons.error_outline_rounded,
        );
        return;
      }

      final result = await OpenFile.open(actualFilePath);
      if (!mounted) return;

      switch (result.type) {
        case ResultType.done:
          _showSnackBar(
            context,
            "File opened successfully! 🎉",
            color: const Color(0xFF10B981),
            icon: Icons.check_circle_rounded,
          );
          break;
        case ResultType.fileNotFound:
          _showSnackBar(
            context,
            "File not found by system",
            color: const Color(0xFFEF4444),
            icon: Icons.error_outline_rounded,
          );
          break;
        case ResultType.noAppToOpen:
          _showSnackBar(
            context,
            "No app found to open this file type.",
            color: const Color(0xFFF59E0B),
            icon: Icons.warning_rounded,
          );
          break;
        case ResultType.permissionDenied:
          _showSnackBar(
            context,
            "Permission denied to open file.",
            color: const Color(0xFFEF4444),
            icon: Icons.block_rounded,
          );
          break;
        default:
          _showSnackBar(
            context,
            "Could not open file: ${result.message}",
            color: const Color(0xFFEF4444),
            icon: Icons.error_outline_rounded,
          );
      }
    } catch (e) {
      if (!mounted) return;
      _showSnackBar(
        context,
        "Error opening file: ${e.toString()}",
        color: const Color(0xFFEF4444),
        icon: Icons.error_outline_rounded,
      );
    }
  }

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
          "Folder opened successfully! 📁",
          color: const Color(0xFF10B981),
          icon: Icons.folder_open_rounded,
        );
      } else {
        _showSnackBar(
          context,
          "Could not open folder.",
          color: const Color(0xFFF59E0B),
          icon: Icons.warning_rounded,
        );
      }
    } catch (e) {
      if (!mounted) return;
      _showSnackBar(
        context,
        "Error opening folder: ${e.toString()}",
        color: const Color(0xFFEF4444),
        icon: Icons.error_outline_rounded,
      );
    }
  }

  Widget _buildQuickAction({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: color.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              color: color,
              size: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTaskCard(task, int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final formatColor = _getFormatColor(task.format, context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 500;

    String displayName;
    if (task.fileName != null && task.fileName!.isNotEmpty) {
      final base = path.basename(task.fileName!);
      final baseNoExt = path.basenameWithoutExtension(base);
      final ext = path.extension(base);
      displayName = '${_sanitizeFileName(baseNoExt)}$ext';
    } else {
      displayName = task.url;
    }

    return AnimatedBuilder(
      animation: _listAnimationController,
      builder: (context, child) {
        final slideAnimation = Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _listAnimationController,
          curve: Interval(
            (index * 0.1).clamp(0.0, 1.0),
            ((index * 0.1) + 0.3).clamp(0.0, 1.0),
            curve: Curves.easeOutBack,
          ),
        ));

        final fadeAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: _listAnimationController,
          curve: Interval(
            (index * 0.05).clamp(0.0, 1.0),
            ((index * 0.05) + 0.5).clamp(0.0, 1.0),
            curve: Curves.easeOut,
          ),
        ));

        return SlideTransition(
          position: slideAnimation,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
              child: Material(
                elevation: 0,
                borderRadius: BorderRadius.circular(16),
                color: Colors.transparent,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDark
                          ? [
                              const Color(0xFF1E293B),
                              const Color(0xFF0F172A).withOpacity(0.8),
                            ]
                          : [
                              Colors.white,
                              const Color(0xFFF8FAFC),
                            ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark 
                          ? const Color(0xFF334155).withOpacity(0.3)
                          : const Color(0xFFE2E8F0).withOpacity(0.8),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                        spreadRadius: 0,
                      ),
                      BoxShadow(
                        color: formatColor.withOpacity(0.05),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                        spreadRadius: -4,
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _openFile(task.fileName, task.downloadPath, task.format),
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: EdgeInsets.all(isSmallScreen ? 14 : 18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Main content row
                            Row(
                              children: [
                                // Format Icon
                                Container(
                                  padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        formatColor,
                                        formatColor.withOpacity(0.8),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: formatColor.withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    _getFormatIcon(task.format),
                                    color: Colors.white,
                                    size: isSmallScreen ? 18 : 20,
                                  ),
                                ),
                                
                                const SizedBox(width: 12),
                                
                                // Content - Make expandable
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        displayName,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.inter(
                                          fontSize: isSmallScreen ? 14 : 15,
                                          fontWeight: FontWeight.w600,
                                          color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A),
                                          height: 1.3,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      // Tags row - Make them wrap properly
                                      Wrap(
                                        spacing: 6,
                                        runSpacing: 4,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: task.format == "mp3" 
                                                  ? const Color(0xFF8B5CF6).withOpacity(0.1)
                                                  : const Color(0xFF3B82F6).withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(6),
                                              border: Border.all(
                                                color: task.format == "mp3" 
                                                    ? const Color(0xFF8B5CF6).withOpacity(0.3)
                                                    : const Color(0xFF3B82F6).withOpacity(0.3),
                                                width: 1,
                                              ),
                                            ),
                                            child: Text(
                                              task.format == "mp3" ? "Audio" : "Video",
                                              style: GoogleFonts.inter(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: task.format == "mp3" 
                                                    ? const Color(0xFF8B5CF6)
                                                    : const Color(0xFF3B82F6),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF10B981).withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(6),
                                              border: Border.all(
                                                color: const Color(0xFF10B981).withOpacity(0.3),
                                                width: 1,
                                              ),
                                            ),
                                            child: Text(
                                              task.mode == "playlist" ? "Playlist" : "Single",
                                              style: GoogleFonts.inter(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: const Color(0xFF10B981),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 12),
                            
                            // Action Buttons - Make them responsive
                            if (isSmallScreen)
                              // Stack vertically on small screens
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildQuickAction(
                                          icon: Icons.refresh_rounded,
                                          color: const Color(0xFF6366F1),
                                          onPressed: () {
                                            final downloadManager = Provider.of<DownloadManager>(context, listen: false);
                                            downloadManager.requeueTask(task);
                                          },
                                          tooltip: "Download Again",
                                        ),
                                      ),
                                      Expanded(
                                        child: _buildQuickAction(
                                          icon: Icons.play_arrow_rounded,
                                          color: const Color(0xFF3B82F6),
                                          onPressed: () => _openFile(task.fileName, task.downloadPath, task.format),
                                          tooltip: "Open File",
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildQuickAction(
                                          icon: Icons.folder_open_rounded,
                                          color: const Color(0xFF10B981),
                                          onPressed: () => _openFolder(task.downloadPath, targetFile: task.fileName),
                                          tooltip: "Open Folder",
                                        ),
                                      ),
                                      Expanded(
                                        child: _buildQuickAction(
                                          icon: Icons.delete_rounded,
                                          color: const Color(0xFFEF4444),
                                          onPressed: () {
                                            final downloadManager = Provider.of<DownloadManager>(context, listen: false);
                                            downloadManager.removeCompletedTask(task);
                                          },
                                          tooltip: "Remove from List",
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              )
                            else
                              // Keep horizontal on larger screens
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  _buildQuickAction(
                                    icon: Icons.refresh_rounded,
                                    color: const Color(0xFF6366F1),
                                    onPressed: () {
                                      final downloadManager = Provider.of<DownloadManager>(context, listen: false);
                                      downloadManager.requeueTask(task);
                                    },
                                    tooltip: "Download Again",
                                  ),
                                  _buildQuickAction(
                                    icon: Icons.play_arrow_rounded,
                                    color: const Color(0xFF3B82F6),
                                    onPressed: () => _openFile(task.fileName, task.downloadPath, task.format),
                                    tooltip: "Open File",
                                  ),
                                  _buildQuickAction(
                                    icon: Icons.folder_open_rounded,
                                    color: const Color(0xFF10B981),
                                    onPressed: () => _openFolder(task.downloadPath, targetFile: task.fileName),
                                    tooltip: "Open Folder",
                                  ),
                                  _buildQuickAction(
                                    icon: Icons.delete_rounded,
                                    color: const Color(0xFFEF4444),
                                    onPressed: () {
                                      final downloadManager = Provider.of<DownloadManager>(context, listen: false);
                                      downloadManager.removeCompletedTask(task);
                                    },
                                    tooltip: "Remove from List",
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(int completedCount) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 500;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          Flex(
            direction: isSmallScreen ? Axis.vertical : Axis.horizontal,
            crossAxisAlignment: isSmallScreen ? CrossAxisAlignment.start : CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF10B981), Color(0xFF059669)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF10B981).withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check_circle_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Completed Downloads",
                          style: GoogleFonts.inter(
                            fontSize: isSmallScreen ? 18 : 20,
                            fontWeight: FontWeight.w700,
                            color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A),
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "$completedCount downloads completed",
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(width: isSmallScreen ? 0 : 16, height: isSmallScreen ? 16 : 0),
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark 
                        ? const Color(0xFF334155).withOpacity(0.5)
                        : const Color(0xFFE2E8F0),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => setState(() => _recentFirst = !_recentFirst),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _recentFirst ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                                size: 16,
                                color: const Color(0xFF3B82F6),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _recentFirst ? "Recent" : "Oldest",
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF3B82F6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      height: 20,
                      width: 1,
                      color: isDark 
                          ? const Color(0xFF334155).withOpacity(0.5)
                          : const Color(0xFFE2E8F0),
                    ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          final downloadManager = Provider.of<DownloadManager>(context, listen: false);
                          downloadManager.clearAllCompletedTasks();
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.delete_sweep_rounded,
                                size: 16,
                                color: Color(0xFFEF4444),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                "Clear",
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFFEF4444),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark 
                  ? const Color(0xFF1E293B).withOpacity(0.5)
                  : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark 
                    ? const Color(0xFF334155).withOpacity(0.3)
                    : const Color(0xFFE2E8F0),
                width: 2,
              ),
            ),
            child: Icon(
              Icons.download_done_rounded,
              size: 48,
              color: isDark 
                  ? const Color(0xFF64748B) 
                  : const Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "No completed downloads yet",
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Your completed downloads will appear here",
            style: GoogleFonts.inter(
              fontSize: 14,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
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
          return _buildEmptyState();
        }

        return Column(
          children: [
            _buildHeader(completed.length),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 6),
                itemCount: completed.length,
                itemBuilder: (context, index) {
                  final task = completed[index];
                  return _buildTaskCard(task, index);
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
