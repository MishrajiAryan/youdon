import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '/models/download_manager.dart';

class OngoingTasks extends StatefulWidget {
  const OngoingTasks({super.key});

  @override
  State<OngoingTasks> createState() => _OngoingTasksState();
}

class _OngoingTasksState extends State<OngoingTasks>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  bool _isSmallScreen() {
    return MediaQuery.of(context).size.width < 480;
  }

  double _getResponsivePadding() {
    final width = MediaQuery.of(context).size.width;
    if (width < 480) return width * 0.04;
    if (width < 768) return width * 0.06;
    return width * 0.08;
  }

  double _getResponsiveFontSize(double baseSize) {
    final shortestSide = MediaQuery.of(context).size.shortestSide;
    if (shortestSide < 360) return baseSize * 0.85;
    if (shortestSide < 480) return baseSize * 0.9;
    if (shortestSide < 600) return baseSize;
    return baseSize * 1.1;
  }

  double _getResponsiveIconSize(double baseSize) {
    return _getResponsiveFontSize(baseSize);
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
        return const Color(0xFF6B7280);
    }
  }

  // NEW: Better URL formatting for cleaner display
  String _formatDisplayName(String? fileName, String url) {
    if (fileName != null && fileName.isNotEmpty) {
      // Clean up the filename for better display
      String cleanName = fileName;
      if (cleanName.contains('/')) {
        cleanName = cleanName.split('/').last;
      }
      // Remove file path parts and keep just filename
      if (cleanName.contains('\\')) {
        cleanName = cleanName.split('\\').last;
      }
      // Truncate if too long
      if (cleanName.length > 50) {
        cleanName = '${cleanName.substring(0, 47)}...';
      }
      return cleanName;
    } else {
      // Extract video ID from URL for cleaner display
      final regex = RegExp(r'(?:youtube\.com/watch\?v=|youtu\.be/)([^&\s]+)');
      final match = regex.firstMatch(url);
      if (match != null) {
        return 'YouTube Video • ${match.group(1)}';
      }
      // Fallback to domain
      try {
        final uri = Uri.parse(url);
        return '${uri.host} • Content';
      } catch (e) {
        return 'YouTube Content';
      }
    }
  }

  Widget _buildEmptyState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fontSizeTitle = _getResponsiveFontSize(20);
    final fontSizeSubtitle = _getResponsiveFontSize(16);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "No Active Downloads",
            style: GoogleFonts.inter(
              fontSize: fontSizeTitle,
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              "Your downloads will appear here once you add them to the queue",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: fontSizeSubtitle,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(task, int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final formatColor = _getFormatColor(task.format, context);
    final isSmall = _isSmallScreen();

    return AnimatedContainer(
      duration: Duration(milliseconds: 300 + (index * 100)),
      curve: Curves.easeOutBack,
      margin: const EdgeInsets.only(bottom: 8), // REDUCED: Much smaller margin between cards
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF1E293B),
                    const Color(0xFF0F172A),
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
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
            BoxShadow(
              color: formatColor.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 6),
              spreadRadius: -4,
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(isSmall ? 12 : 14), // REDUCED: Less internal padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // IMPROVED: Header section with tighter layout
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Format icon with enhanced styling
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: task.isDownloading ? _pulseAnimation.value : 1.0,
                        child: Container(
                          padding: EdgeInsets.all(isSmall ? 10 : 12),
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
                                color: formatColor.withOpacity(0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            _getFormatIcon(task.format),
                            color: Colors.white,
                            size: _getResponsiveIconSize(20),
                          ),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(width: 12), // REDUCED: Less spacing
                  
                  // Content section with improved hierarchy
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // IMPROVED: Better title display
                        Text(
                          _formatDisplayName(task.fileName, task.url),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: _getResponsiveFontSize(15),
                            fontWeight: FontWeight.w600,
                            color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A),
                            height: 1.2,
                            letterSpacing: -0.2,
                          ),
                        ),
                        
                        const SizedBox(height: 3), // REDUCED: Much less spacing
                        
                        // IMPROVED: Compact metadata badges
                        Row(
                          children: [
                            _buildCompactBadge(
                              task.format == "mp3" ? "Audio" : "Video",
                              task.format == "mp3" 
                                  ? const Color(0xFF8B5CF6)
                                  : const Color(0xFF3B82F6),
                            ),
                            const SizedBox(width: 4), // REDUCED: Less spacing between badges
                            _buildCompactBadge(
                              task.mode == "playlist" ? "Playlist" : "Single",
                              task.mode == "playlist"
                                  ? const Color(0xFFF59E0B)
                                  : const Color(0xFF06B6D4),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(width: 8), // REDUCED: Less spacing
                  
                  // IMPROVED: Status indicator
                  _buildStatusIndicator(task, isDark),
                ],
              ),
              
              const SizedBox(height: 6), // REDUCED: Much less spacing between sections
              
              // IMPROVED: Progress section with better design
              _buildEnhancedProgressSection(task, formatColor, isDark),
            ],
          ),
        ),
      ),
    );
  }

  // NEW: Compact badge widget with smaller padding
  Widget _buildCompactBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1), // REDUCED: Even smaller badge padding
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4), // REDUCED: Smaller radius
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: _getResponsiveFontSize(9), // REDUCED: Smaller badge text
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  // IMPROVED: Status indicator with better design
  Widget _buildStatusIndicator(task, bool isDark) {
    final fontSize = _getResponsiveFontSize(10); // REDUCED: Smaller status text
    final iconSize = _getResponsiveIconSize(12); // REDUCED: Smaller status icons

    if (task.isProcessing) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3), // REDUCED: Smaller status padding
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
          ),
          borderRadius: BorderRadius.circular(8), // REDUCED: Smaller radius
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFF59E0B).withOpacity(0.3),
              blurRadius: 4, // REDUCED: Less shadow
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: iconSize,
              height: iconSize,
              child: const CircularProgressIndicator(
                strokeWidth: 1.5,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(width: 3), // REDUCED: Less spacing
            Text(
              "Processing",
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    if (task.isDownloading) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3), // REDUCED: Smaller status padding
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF10B981), Color(0xFF059669)],
          ),
          borderRadius: BorderRadius.circular(8), // REDUCED: Smaller radius
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF10B981).withOpacity(0.3),
              blurRadius: 4, // REDUCED: Less shadow
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.download_rounded,
              color: Colors.white,
              size: iconSize,
            ),
            const SizedBox(width: 3), // REDUCED: Less spacing
            Text(
              "Downloading",
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3), // REDUCED: Smaller padding
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF374151).withOpacity(0.6)
            : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(8), // REDUCED: Smaller radius
        border: Border.all(
          color: isDark
              ? const Color(0xFF4B5563).withOpacity(0.5)
              : const Color(0xFFE5E7EB),
          width: 1,
        ),
      ),
      child: Text(
        "In Queue",
        style: GoogleFonts.inter(
          fontSize: fontSize,
          fontWeight: FontWeight.w500,
          color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
        ),
      ),
    );
  }

  // IMPROVED: Enhanced progress section with tighter spacing
  Widget _buildEnhancedProgressSection(task, Color formatColor, bool isDark) {
    final fontSize = _getResponsiveFontSize(12); // REDUCED: Smaller progress text
    final progressHeight = 6.0; // REDUCED: Thinner progress bar

    if (!task.isDownloading && !task.isProcessing) {
      return Container(
        padding: const EdgeInsets.all(8), // REDUCED: Less padding for waiting state
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF374151).withOpacity(0.3),
                    const Color(0xFF1F2937).withOpacity(0.2),
                  ]
                : [
                    const Color(0xFFF9FAFB),
                    const Color(0xFFF3F4F6),
                  ],
          ),
          borderRadius: BorderRadius.circular(10), // REDUCED: Smaller radius
          border: Border.all(
            color: isDark
                ? const Color(0xFF4B5563).withOpacity(0.3)
                : const Color(0xFFE5E7EB),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4), // REDUCED: Smaller icon container
              decoration: BoxDecoration(
                color: (isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF)).withOpacity(0.2),
                borderRadius: BorderRadius.circular(6), // REDUCED: Smaller radius
              ),
              child: Icon(
                Icons.schedule_rounded,
                color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                size: _getResponsiveIconSize(14), // REDUCED: Smaller waiting icon
              ),
            ),
            const SizedBox(width: 6), // REDUCED: Less spacing
            Expanded(
              child: Text(
                "Waiting in queue...",
                style: GoogleFonts.inter(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w500,
                  color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(8), // REDUCED: Less progress container padding
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            formatColor.withOpacity(0.05),
            formatColor.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(10), // REDUCED: Smaller radius
        border: Border.all(
          color: formatColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Progress header with tighter layout
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(3), // REDUCED: Smaller progress icon padding
                    decoration: BoxDecoration(
                      color: formatColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4), // REDUCED: Smaller radius
                    ),
                    child: Icon(
                      task.isProcessing ? Icons.settings_rounded : Icons.download_rounded,
                      color: formatColor,
                      size: 10, // REDUCED: Much smaller progress icons
                    ),
                  ),
                  const SizedBox(width: 4), // REDUCED: Less spacing
                  Text(
                    task.isProcessing ? "Processing..." : "Downloading...",
                    style: GoogleFonts.inter(
                      fontSize: fontSize,
                      fontWeight: FontWeight.w600,
                      color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF374151),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1), // REDUCED: Smaller percentage badge
                decoration: BoxDecoration(
                  color: formatColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4), // REDUCED: Smaller radius
                ),
                child: Text(
                  "${(task.progress * 100).toStringAsFixed(1)}%",
                  style: GoogleFonts.inter(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w700,
                    color: formatColor,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 4), // REDUCED: Less spacing before progress bar
          
          // Enhanced progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(progressHeight),
            child: Container(
              height: progressHeight,
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF374151).withOpacity(0.5)
                    : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(progressHeight),
              ),
              child: Stack(
                children: [
                  FractionallySizedBox(
                    widthFactor: task.progress,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            formatColor,
                            formatColor.withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(progressHeight),
                        boxShadow: [
                          BoxShadow(
                            color: formatColor.withOpacity(0.4),
                            blurRadius: 4, // REDUCED: Less progress bar shadow
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Animated shimmer effect
                  if (task.isDownloading && !task.isProcessing)
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return FractionallySizedBox(
                          widthFactor: task.progress,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withOpacity(0.0),
                                  Colors.white.withOpacity(0.3 * _pulseAnimation.value),
                                  Colors.white.withOpacity(0.0),
                                ],
                                stops: const [0.0, 0.5, 1.0],
                              ),
                              borderRadius: BorderRadius.circular(progressHeight),
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
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
        if (downloadManager.downloadQueue.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 16), // REDUCED: Less bottom padding
          itemCount: downloadManager.downloadQueue.length,
          itemBuilder: (context, index) {
            final task = downloadManager.downloadQueue[index];
            return _buildTaskCard(task, index);
          },
        );
      },
    );
  }
}
