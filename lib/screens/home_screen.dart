import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'components/download_input.dart';
import 'components/ongoing_tasks.dart';
import 'components/completed_tasks.dart';
import '../theme_notifier.dart';
import '../models/download_manager.dart';
import '../services/update_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _heroController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _heroAnimation;
  
  bool _showDownloadInput = true;
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    
    _tabController = TabController(length: 2, vsync: this);
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _heroController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOutCubic,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.elasticOut,
    ));

    _heroAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _heroController,
      curve: Curves.easeOutBack,
    ));

    _tabController.addListener(() {
      if (mounted && _tabController.indexIsChanging) {
        setState(() {
          _currentTabIndex = _tabController.index;
          _showDownloadInput = _tabController.index == 0;
        });
        
        if (_showDownloadInput) {
          _fadeController.forward();
          _slideController.forward();
        } else {
          _fadeController.reverse();
          _slideController.reverse();
        }
      }
    });

    // Start initial animations
    Future.delayed(const Duration(milliseconds: 200), () {
      _heroController.forward();
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      _fadeController.forward();
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _heroController.dispose();
    super.dispose();
  }

  // Responsive breakpoints
  bool _isSmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < 480;
  }

  bool _isMediumScreen(BuildContext context) {
    return MediaQuery.of(context).size.width >= 480 && MediaQuery.of(context).size.width < 768;
  }

  bool _isLargeScreen(BuildContext context) {
    return MediaQuery.of(context).size.width >= 768;
  }

  double _getResponsivePadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 480) return width * 0.04; // 4% for small screens
    if (width < 768) return width * 0.06; // 6% for medium screens
    if (width < 1200) return width * 0.08; // 8% for large screens
    return width * 0.10; // Reduced max padding
  }

  double _getResponsiveFontSize(BuildContext context, double baseSize) {
    final shortestSide = MediaQuery.of(context).size.shortestSide;
    
    // Scale based on shortest side for better consistency across orientations
    if (shortestSide < 360) return baseSize * 0.85; // Very small phones
    if (shortestSide < 480) return baseSize * 0.9;  // Small phones
    if (shortestSide < 600) return baseSize;        // Normal phones
    if (shortestSide < 900) return baseSize * 1.1;  // Large phones/small tablets
    return baseSize * 1.2; // Tablets and larger
  }

  void _showEnhancedSnackBar(String message, {Color? color, IconData? icon}) {
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(_getResponsivePadding(context)),
          backgroundColor: color ?? Theme.of(context).colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_isSmallScreen(context) ? 12 : 16)
          ),
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
                      fontSize: _getResponsiveFontSize(context, 14),
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

  Future<void> _showUpdateDialog() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.system_update_alt_rounded,
                  color: Color(0xFF6366F1),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "Update yt-dlp",
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          content: Text(
            "This will update yt-dlp to the latest version and restart the app. Continue?",
            style: GoogleFonts.inter(
              fontSize: 14,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: Text(
                "Cancel",
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w500,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _performUpdate();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(
                "Update",
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performUpdate() async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    "Updating yt-dlp...",
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    try {
      // Perform the update
      final result = await UpdateService.updateYtDlp();
      
      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      if (result['success']) {
        // Show success and restart
        _showEnhancedSnackBar(
          "✅ ${result['message']} Restarting app...",
          color: const Color(0xFF10B981),
          icon: Icons.check_circle_rounded,
        );
        
        // Wait a moment for user to see the message, then restart
        await Future.delayed(const Duration(seconds: 2));
        await UpdateService.restartApp();
      } else {
        // Show error
        _showEnhancedSnackBar(
          "❌ ${result['message']}: ${result['error']}",
          color: const Color(0xFFEF4444),
          icon: Icons.error_outline_rounded,
        );
      }
    } catch (e) {
      // Close loading dialog if still open
      if (mounted) Navigator.of(context).pop();
      
      _showEnhancedSnackBar(
        "❌ Update failed: $e",
        color: const Color(0xFFEF4444),
        icon: Icons.error_outline_rounded,
      );
    }
  }

  Widget _buildGradientBackground() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark 
            ? [
                const Color(0xFF020817),
                const Color(0xFF0F172A),
                const Color(0xFF1E293B).withOpacity(0.8),
              ]
            : [
                const Color(0xFFFBFBFB),
                const Color(0xFFF8FAFC),
                const Color(0xFFF1F5F9).withOpacity(0.8),
              ],
          stops: const [0.0, 0.6, 1.0],
        ),
      ),
    );
  }

  Widget _buildEnhancedAppBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenSize = MediaQuery.of(context).size;
    final isSmall = _isSmallScreen(context);
    final expandedHeight = isSmall ? 
      (screenSize.height < 600 ? 80.0 : 100.0) : 
      (_isMediumScreen(context) ? 120.0 : 140.0);
    
    return SliverAppBar(
      expandedHeight: expandedHeight,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFFBFBFB),
      surfaceTintColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: EdgeInsets.only(
          left: _getResponsivePadding(context),
          bottom: isSmall ? 12 : 16,
        ),
        title: AnimatedBuilder(
          animation: _heroAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _heroAnimation.value,
              child: Opacity(
                opacity: _heroAnimation.value,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "YouDon",
                      style: GoogleFonts.inter(
                        fontSize: _getResponsiveFontSize(context, isSmall ? 20 : 24),
                        fontWeight: FontWeight.w900,
                        color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A),
                        letterSpacing: -1.0,
                        shadows: isDark ? [
                          Shadow(
                            color: Colors.black.withOpacity(0.3),
                            offset: const Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ] : null,
                      ),
                    ),
                    if (!isSmall || screenSize.height > 600)
                      Text(
                        "Premium YouTube Downloader",
                        style: GoogleFonts.inter(
                          fontSize: _getResponsiveFontSize(context, 10),
                          fontWeight: FontWeight.w500,
                          color: isDark 
                              ? const Color(0xFF8B5CF6) 
                              : const Color(0xFF6366F1),
                          letterSpacing: 0.5,
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
        background: Stack(
          children: [
            _buildGradientBackground(),
            Positioned(
              top: -50,
              right: -50,
              child: AnimatedBuilder(
                animation: _heroAnimation,
                builder: (context, child) {
                  final circleSize = isSmall ? 120.0 : (_isMediumScreen(context) ? 150.0 : 200.0);
                  return Transform.scale(
                    scale: _heroAnimation.value * 0.8,
                    child: Container(
                      width: circleSize,
                      height: circleSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF6366F1).withOpacity(0.1),
                            const Color(0xFF8B5CF6).withOpacity(0.05),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        // Add the update button
        Container(
          margin: EdgeInsets.only(right: _getResponsivePadding(context) / 2),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark 
                    ? [
                        const Color(0xFF334155).withOpacity(0.8),
                        const Color(0xFF475569).withOpacity(0.6),
                      ]
                    : [
                        const Color(0xFFF1F5F9),
                        const Color(0xFFE2E8F0),
                      ],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark 
                    ? const Color(0xFF475569).withOpacity(0.3)
                    : const Color(0xFFCBD5E1).withOpacity(0.5),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              iconSize: isSmall ? 18 : 20,
              icon: Icon(
                Icons.system_update_alt_rounded,
                color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF475569),
                size: isSmall ? 18 : 20,
              ),
              onPressed: _showUpdateDialog,
              tooltip: "Update yt-dlp",
            ),
          ),
        ),
        // Your existing theme toggle button
        Consumer<ThemeNotifier>(
          builder: (context, themeNotifier, child) {
            return Container(
              margin: EdgeInsets.only(right: _getResponsivePadding(context)),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark 
                        ? [
                            const Color(0xFF334155).withOpacity(0.8),
                            const Color(0xFF475569).withOpacity(0.6),
                          ]
                        : [
                            const Color(0xFFF1F5F9),
                            const Color(0xFFE2E8F0),
                          ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark 
                        ? const Color(0xFF475569).withOpacity(0.3)
                        : const Color(0xFFCBD5E1).withOpacity(0.5),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  iconSize: isSmall ? 18 : 20,
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    transitionBuilder: (child, animation) {
                      return RotationTransition(
                        turns: animation,
                        child: ScaleTransition(scale: animation, child: child),
                      );
                    },
                    child: Icon(
                      themeNotifier.themeMode == ThemeMode.dark
                          ? Icons.light_mode_rounded
                          : Icons.dark_mode_rounded,
                      key: ValueKey(themeNotifier.themeMode),
                      color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF475569),
                      size: isSmall ? 18 : 20,
                    ),
                  ),
                  onPressed: () {
                    themeNotifier.toggleTheme();
                    _showEnhancedSnackBar(
                      themeNotifier.themeMode == ThemeMode.dark
                          ? "Welcome to the dark side ✨"
                          : "Light mode activated ☀️",
                      color: themeNotifier.themeMode == ThemeMode.dark
                          ? const Color(0xFF6366F1)
                          : const Color(0xFFF59E0B),
                      icon: themeNotifier.themeMode == ThemeMode.dark
                          ? Icons.dark_mode_rounded
                          : Icons.light_mode_rounded,
                    );
                  },
                  tooltip: themeNotifier.themeMode == ThemeMode.dark
                      ? "Switch to Light Mode"
                      : "Switch to Dark Mode",
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildEnhancedTabBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final horizontalPadding = _getResponsivePadding(context);
    final isSmall = _isSmallScreen(context);
    
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - _fadeAnimation.value)),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: isSmall ? 12 : 16),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(isSmall ? 12 : 14),
                border: Border.all(
                  color: isDark 
                      ? const Color(0xFF334155).withOpacity(0.5)
                      : const Color(0xFFE2E8F0).withOpacity(0.8),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(isSmall ? 8 : 10),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: Colors.white,
                unselectedLabelColor: isDark 
                    ? const Color(0xFF94A3B8) 
                    : const Color(0xFF64748B),
                labelStyle: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontSize: _getResponsiveFontSize(context, 13),
                  letterSpacing: 0.2,
                ),
                unselectedLabelStyle: GoogleFonts.inter(
                  fontWeight: FontWeight.w500,
                  fontSize: _getResponsiveFontSize(context, 13),
                  letterSpacing: 0.2,
                ),
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            Icons.download_rounded,
                            size: _currentTabIndex == 0 ? 
                              (isSmall ? 16 : 18) : 
                              (isSmall ? 14 : 16),
                          ),
                        ),
                        SizedBox(width: isSmall ? 4 : 6),
                        const Flexible(child: Text('Active')),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            Icons.check_circle_rounded,
                            size: _currentTabIndex == 1 ? 
                              (isSmall ? 16 : 18) : 
                              (isSmall ? 14 : 16),
                          ),
                        ),
                        SizedBox(width: isSmall ? 4 : 6),
                        const Flexible(child: Text('Completed')),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEnhancedFooter() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSmall = _isSmallScreen(context);
    
    return Container(
      padding: EdgeInsets.symmetric(vertical: isSmall ? 16 : 24),
      child: Column(
        children: [
          Container(
            height: 1,
            margin: EdgeInsets.symmetric(horizontal: _getResponsivePadding(context) * 2),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0))
                      .withOpacity(0.6),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          SizedBox(height: isSmall ? 12 : 16),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                "Crafted with ",
                style: GoogleFonts.inter(
                  fontSize: _getResponsiveFontSize(context, 12),
                  color: isDark 
                      ? const Color(0xFF94A3B8) 
                      : const Color(0xFF64748B),
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.2,
                ),
              ),
              Text(
                "❤️",
                style: TextStyle(fontSize: _getResponsiveFontSize(context, 12)),
              ),
              Text(
                " by ",
                style: GoogleFonts.inter(
                  fontSize: _getResponsiveFontSize(context, 12),
                  color: isDark 
                      ? const Color(0xFF94A3B8) 
                      : const Color(0xFF64748B),
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.2,
                ),
              ),
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                ).createShader(bounds),
                child: Text(
                  "Aryan Mishra",
                  style: GoogleFonts.inter(
                    fontSize: _getResponsiveFontSize(context, 12),
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = _getResponsivePadding(context);
    
    // Listen for DownloadManager messages
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final downloadManager = Provider.of<DownloadManager>(context, listen: false);
      if (downloadManager.uiMessage != null) {
        final msg = downloadManager.uiMessage!;
        _showEnhancedSnackBar(msg.text, color: msg.color, icon: msg.icon);
        downloadManager.clearMessage();
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          _buildGradientBackground(),
          CustomScrollView(
            slivers: [
              _buildEnhancedAppBar(),
              SliverToBoxAdapter(
                child: _buildEnhancedTabBar(),
              ),
              SliverToBoxAdapter(
                child: AnimatedBuilder(
                  animation: _fadeAnimation,
                  builder: (context, child) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeInOutCubic,
                      height: _showDownloadInput ? null : 0,
                      child: Opacity(
                        opacity: _fadeAnimation.value,
                        child: _showDownloadInput
                            ? Padding(
                                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                                child: SlideTransition(
                                  position: _slideAnimation,
                                  child: const DownloadInput(),
                                ),
                              )
                            : const SizedBox(),
                      ),
                    );
                  },
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(height: _isSmallScreen(context) ? 12 : 16),
              ),
              SliverToBoxAdapter(
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.6,
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: TabBarView(
                    controller: _tabController,
                    children: const [
                      OngoingTasks(),
                      CompletedTasks(),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: _buildEnhancedFooter(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
