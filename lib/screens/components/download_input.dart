import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '/models/download_manager.dart';
import '/models/download_task.dart';

class DownloadInput extends StatefulWidget {
  const DownloadInput({super.key});

  @override
  State<DownloadInput> createState() => _DownloadInputState();
}

class _DownloadInputState extends State<DownloadInput>
    with TickerProviderStateMixin {
  final TextEditingController _urlController = TextEditingController();
  String _selectedFormat = "mp4";
  String _selectedMode = "single";
  
  late AnimationController _bounceController;
  late AnimationController _shimmerController;
  late Animation<double> _bounceAnimation;
  late Animation<double> _shimmerAnimation;
  
  bool _isHovering = false;
  final FocusNode _urlFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    
    _bounceAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticOut,
    ));
    
    _shimmerAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _urlController.dispose();
    _urlFocusNode.dispose();
    _bounceController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {Color? color, IconData? icon}) {
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.05,
            vertical: 16,
          ),
          backgroundColor: color ?? Theme.of(context).colorScheme.primary,
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
                      letterSpacing: 0.1,
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

  void _addToQueue() async {
    final downloadManager = Provider.of<DownloadManager>(context, listen: false);
    final url = _urlController.text.trim();

    // Trigger bounce animation
    _bounceController.forward().then((_) {
      _bounceController.reverse();
    });

    if (url.isEmpty) {
      _showSnackBar(
        "Please enter a YouTube URL first.",
        color: const Color(0xFFEF4444),
        icon: Icons.error_outline_rounded,
      );
      _urlFocusNode.requestFocus();
      return;
    }

    if (downloadManager.downloadPath == null) {
      _showSnackBar(
        "Please select a download destination folder.",
        color: const Color(0xFFEF4444),
        icon: Icons.folder_off_rounded,
      );
      return;
    }

    final newTask = DownloadTask(
      url: url,
      format: _selectedFormat,
      mode: _selectedMode,
      downloadPath: downloadManager.downloadPath!,
    );

    downloadManager.addToQueue(newTask);
    _urlController.clear();
    
    _showSnackBar(
      _selectedFormat == "mp3" 
        ? "🎵 Audio download queued with premium quality"
        : "🎬 Video download queued with best resolution",
      color: const Color(0xFF10B981),
      icon: Icons.check_circle_rounded,
    );
  }

  Widget _buildGradientCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 600 || screenWidth < 400;
    
    return AnimatedBuilder(
      animation: _bounceAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _bounceAnimation.value,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: screenWidth * 0.95,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(isSmallScreen ? 18 : 24),
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
              border: Border.all(
                color: isDark 
                    ? const Color(0xFF334155).withOpacity(0.3)
                    : const Color(0xFFE2E8F0).withOpacity(0.8),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.4 : 0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: const Color(0xFF6366F1).withOpacity(0.1),
                  blurRadius: 40,
                  offset: const Offset(0, 16),
                  spreadRadius: -8,
                ),
              ],
            ),
            child: child,
          ),
        );
      },
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 20.0 : 28.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            SizedBox(height: isSmallScreen ? 20 : 32),
            _buildUrlInput(),
            SizedBox(height: isSmallScreen ? 16 : 24),
            _buildFormatAndModeRow(),
            SizedBox(height: isSmallScreen ? 16 : 24),
            _buildFolderSelection(),
            SizedBox(height: isSmallScreen ? 20 : 32),
            _buildDownloadButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flex(
          direction: isSmallScreen ? Axis.vertical : Axis.horizontal,
          crossAxisAlignment: isSmallScreen ? CrossAxisAlignment.start : CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.download_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            SizedBox(width: isSmallScreen ? 0 : 14, height: isSmallScreen ? 12 : 0),
            Flexible(
              child: Column(
                crossAxisAlignment: isSmallScreen ? CrossAxisAlignment.start : CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Download Content",
                    style: GoogleFonts.inter(
                      fontSize: isSmallScreen ? 18 : 20,
                      fontWeight: FontWeight.w700,
                      color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A),
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "High-quality downloads from YouTube",
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      letterSpacing: 0.1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUrlInput() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "YouTube URL",
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF374151),
            letterSpacing: -0.1,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _urlController,
            focusNode: _urlFocusNode,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.1,
            ),
            decoration: InputDecoration(
              hintText: "Paste your YouTube link here...",
              prefixIcon: Container(
                margin: const EdgeInsets.all(10),
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.link_rounded,
                  color: Color(0xFF6366F1),
                  size: 18,
                ),
              ),
              suffixIcon: _urlController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 20),
                      onPressed: () {
                        setState(() {
                          _urlController.clear();
                        });
                      },
                    )
                  : null,
            ),
            onChanged: (value) {
              setState(() {});
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFormatAndModeRow() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 500;
    
    return Flex(
      direction: isSmallScreen ? Axis.vertical : Axis.horizontal,
      children: [
        Flexible(child: _buildFormatDropdown()),
        SizedBox(width: isSmallScreen ? 0 : 16, height: isSmallScreen ? 16 : 0),
        Flexible(child: _buildModeDropdown()),
      ],
    );
  }

 Widget _buildFormatDropdown() {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        "Quality",
        style: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF374151),
          letterSpacing: -0.1,
        ),
      ),
      const SizedBox(height: 8),
      Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: DropdownButtonFormField<String>(
          value: _selectedFormat,
          decoration: const InputDecoration(
            border: InputBorder.none,
          ),
          isExpanded: true,
          dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          onChanged: (value) => setState(() => _selectedFormat = value!),
          menuMaxHeight: 150, // Limit dropdown height
          items: [
            DropdownMenuItem(
              value: "mp4",
              child: Row(
                mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B82F6).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.high_quality_rounded,
                        color: Color(0xFF3B82F6),
                        size: 16, 
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Best Video",
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              fontSize: 12, 
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
            ),
            DropdownMenuItem(
              value: "mp3",
              child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4), 
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B5CF6).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.audiotrack_rounded,
                        color: Color(0xFF8B5CF6),
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Best Audio",
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
            ),
          ],
        ),
      ),
    ],
  );
}

Widget _buildModeDropdown() {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        "Mode",
        style: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF374151),
          letterSpacing: -0.1,
        ),
      ),
      const SizedBox(height: 8),
      Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: DropdownButtonFormField<String>(
          value: _selectedMode,
          decoration: const InputDecoration(
            border: InputBorder.none,
          ),
          isExpanded: true,
          dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          onChanged: (value) => setState(() => _selectedMode = value!),
          menuMaxHeight: 150, 
          items: [
            DropdownMenuItem(
              value: "single",
              child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4), 
                      decoration: BoxDecoration(
                        color: const Color(0xFF06B6D4).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.music_note_rounded,
                        color: Color(0xFF06B6D4),
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Single",
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
            ),
            DropdownMenuItem(
              value: "playlist",
              child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.queue_music_rounded,
                        color: Color(0xFFF59E0B),
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 8), 
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Playlist",
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
            ),
          ],
        ),
      ),
    ],
  );
}


  Widget _buildQualityInfoCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      constraints: const BoxConstraints(minHeight: 60),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF6366F1).withOpacity(0.1),
                  const Color(0xFF8B5CF6).withOpacity(0.05),
                ]
              : [
                  const Color(0xFF6366F1).withOpacity(0.05),
                  const Color(0xFF8B5CF6).withOpacity(0.08),
                ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF6366F1).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: Color(0xFF6366F1),
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Smart Quality Selection",
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF374151),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _selectedFormat == "mp3"
                      ? "Automatically selects the highest quality audio format available"
                      : "Automatically selects the best video quality with perfect audio sync",
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFolderSelection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Download Location",
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF374151),
            letterSpacing: -0.1,
          ),
        ),
        const SizedBox(height: 10),
        Consumer<DownloadManager>(
          builder: (context, downloadManager, child) {
            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF334155).withOpacity(0.3) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark 
                      ? const Color(0xFF475569).withOpacity(0.5)
                      : const Color(0xFFE2E8F0),
                  width: 1.5,
                ),
              ),
              child: Flex(
                direction: isSmallScreen ? Axis.vertical : Axis.horizontal,
                crossAxisAlignment: isSmallScreen ? CrossAxisAlignment.start : CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: downloadManager.downloadPath != null
                                ? const Color(0xFF10B981).withOpacity(0.1)
                                : const Color(0xFF6B7280).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            downloadManager.downloadPath != null
                                ? Icons.folder_rounded
                                : Icons.folder_outlined,
                            color: downloadManager.downloadPath != null
                                ? const Color(0xFF10B981)
                                : const Color(0xFF6B7280),
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                downloadManager.downloadPath != null ? "Selected Folder" : "No folder selected",
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: downloadManager.downloadPath != null
                                      ? const Color(0xFF10B981)
                                      : const Color(0xFF6B7280),
                                ),
                              ),
                              if (downloadManager.downloadPath != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  downloadManager.downloadPath!,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                  ),
                                ),
                              ] else ...[
                                const SizedBox(height: 2),
                                Text(
                                  "Choose where to save your downloads",
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: isSmallScreen ? 0 : 12, height: isSmallScreen ? 12 : 0),
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6366F1).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      iconSize: 18,
                      onPressed: () async {
                        await downloadManager.setDownloadPath();
                      },
                      icon: const Icon(Icons.folder_open_rounded, color: Colors.white),
                      tooltip: "Choose Download Folder",
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDownloadButton() {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 600;
    
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()..scale(_isHovering ? 1.02 : 1.0),
        child: Container(
          width: double.infinity,
          height: isSmallScreen ? 52 : 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6366F1).withOpacity(0.4),
                blurRadius: _isHovering ? 20 : 12,
                offset: Offset(0, _isHovering ? 8 : 4),
                spreadRadius: _isHovering ? 2 : 0,
              ),
            ],
          ),
          child: AnimatedBuilder(
            animation: _shimmerAnimation,
            builder: (context, child) {
              return Stack(
                children: [
                  // Shimmer effect
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.0),
                            Colors.white.withOpacity(0.1),
                            Colors.white.withOpacity(0.0),
                          ],
                          stops: const [0.0, 0.5, 1.0],
                          begin: Alignment(-1.0 + 2.0 * _shimmerAnimation.value, 0.0),
                          end: Alignment(1.0 + 2.0 * _shimmerAnimation.value, 0.0),
                        ),
                      ),
                    ),
                  ),
                  // Button content
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _addToQueue,
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        width: double.infinity,
                        height: double.infinity,
                        alignment: Alignment.center,
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.download_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              "Add to Download Queue",
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildGradientCard();
  }
}
