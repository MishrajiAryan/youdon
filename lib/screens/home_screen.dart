import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'components/download_input.dart';
import 'components/ongoing_tasks.dart';
import 'components/completed_tasks.dart';
import '../theme_notifier.dart';
import '../models/download_manager.dart';

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
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  bool _showDownloadInput = true;
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    
    _tabController = TabController(length: 2, vsync: this);
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
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
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
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
        } else {
          _fadeController.reverse();
        }
      }
    });

    // Start initial animations
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _showEnhancedSnackBar(String message, {Color? color, IconData? icon}) {
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          backgroundColor: color ?? Theme.of(context).colorScheme.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 8,
          content: Row(
            children: [
              if (icon != null) ...[
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
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
          duration: const Duration(seconds: 4),
        ),
      );
  }

  Widget _buildEnhancedAppBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
      surfaceTintColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
        title: AnimatedBuilder(
          animation: _slideAnimation,
          builder: (context, child) {
            return SlideTransition(
              position: _slideAnimation,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "YouDon",
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    "YouTube Downloader",
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isDark 
                          ? const Color(0xFF94A3B8) 
                          : const Color(0xFF64748B),
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark 
                  ? [
                      const Color(0xFF0F172A),
                      const Color(0xFF1E293B).withOpacity(0.8),
                    ]
                  : [
                      Colors.white,
                      const Color(0xFFF8FAFC),
                    ],
            ),
          ),
        ),
      ),
      actions: [
        Consumer<ThemeNotifier>(
          builder: (context, themeNotifier, child) {
            return Container(
              margin: const EdgeInsets.only(right: 16),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  color: isDark 
                      ? const Color(0xFF334155).withOpacity(0.6)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark 
                        ? const Color(0xFF475569).withOpacity(0.3)
                        : const Color(0xFFE2E8F0),
                    width: 1,
                  ),
                ),
                child: IconButton(
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    transitionBuilder: (child, animation) {
                      return ScaleTransition(scale: animation, child: child);
                    },
                    child: Icon(
                      themeNotifier.themeMode == ThemeMode.dark
                          ? Icons.light_mode_rounded
                          : Icons.dark_mode_rounded,
                      key: ValueKey(themeNotifier.themeMode),
                      color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF475569),
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
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark 
              ? const Color(0xFF334155).withOpacity(0.5)
              : const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: LinearGradient(
            colors: [
              const Color(0xFF6366F1),
              const Color(0xFF8B5CF6),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6366F1).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: isDark 
            ? const Color(0xFF94A3B8) 
            : const Color(0xFF64748B),
        labelStyle: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.download_rounded,
                    size: _currentTabIndex == 0 ? 20 : 18,
                  ),
                ),
                const SizedBox(width: 8),
                const Text('Active'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.check_circle_rounded,
                    size: _currentTabIndex == 1 ? 20 : 18,
                  ),
                ),
                const SizedBox(width: 8),
                const Text('Completed'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedFooter() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 40),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0))
                      .withOpacity(0.5),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Crafted with ",
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: isDark 
                      ? const Color(0xFF94A3B8) 
                      : const Color(0xFF64748B),
                  fontWeight: FontWeight.w400,
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 1000),
                curve: Curves.easeInOut,
                child: const Text(
                  "❤️",
                  style: TextStyle(fontSize: 14),
                ),
              ),
              Text(
                " by ",
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: isDark 
                      ? const Color(0xFF94A3B8) 
                      : const Color(0xFF64748B),
                  fontWeight: FontWeight.w400,
                ),
              ),
              Text(
                "Aryan Mishra",
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: const Color(0xFF6366F1),
                  fontWeight: FontWeight.w600,
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            _buildEnhancedAppBar(),
          ];
        },
        body: Column(
          children: [
            _buildEnhancedTabBar(),
            
            // Download Input with enhanced animations
            AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOutCubic,
                  height: _showDownloadInput ? null : 0,
                  child: Opacity(
                    opacity: _fadeAnimation.value,
                    child: _showDownloadInput 
                        ? Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, -0.3),
                                end: Offset.zero,
                              ).animate(CurvedAnimation(
                                parent: _fadeController,
                                curve: Curves.easeOutBack,
                              )),
                              child: const DownloadInput(),
                            ),
                          )
                        : const SizedBox(),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 20),
            
            // Tab Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: const OngoingTasks(),
                    ),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: const CompletedTasks(),
                    ),
                  ],
                ),
              ),
            ),
            
            _buildEnhancedFooter(),
          ],
        ),
      ),
    );
  }
}
