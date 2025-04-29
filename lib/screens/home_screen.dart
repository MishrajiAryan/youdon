import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _showDownloadInput = true;
  double _opacity = 1.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (mounted) {
        setState(() {
          _showDownloadInput = _tabController.index == 0;
          _opacity = _showDownloadInput ? 1.0 : 0.0;
        });
      }
    });
  }

  void _showGlobalSnackBar(String message, {Color? color, IconData? icon}) {
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: color ?? Theme.of(context).colorScheme.primary,
          content: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: Colors.white),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    // Listen for DownloadManager messages for global snackbars
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final downloadManager = Provider.of<DownloadManager>(context, listen: false);
      if (downloadManager.uiMessage != null) {
        final msg = downloadManager.uiMessage!;
        _showGlobalSnackBar(msg.text, color: msg.color, icon: msg.icon);
        downloadManager.clearMessage();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "YouDon - YouTube Downloader",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 5,
        actions: [
          IconButton(
            icon: Icon(
              Provider.of<ThemeNotifier>(context).themeMode == ThemeMode.dark
                  ? Icons.dark_mode
                  : Icons.light_mode,
            ),
            onPressed: () {
              final themeNotifier =
                  Provider.of<ThemeNotifier>(context, listen: false);
              themeNotifier.toggleTheme();

              _showGlobalSnackBar(
                themeNotifier.themeMode == ThemeMode.dark
                    ? "Dark mode enabled"
                    : "Light mode enabled",
                color: Theme.of(context).colorScheme.primary,
                icon: themeNotifier.themeMode == ThemeMode.dark
                    ? Icons.dark_mode
                    : Icons.light_mode,
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.blueAccent,
          indicatorWeight: 3.0,
          tabs: const [
            Tab(icon: Icon(Icons.download), text: 'Ongoing'),
            Tab(icon: Icon(Icons.check_circle), text: 'Completed'),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            AnimatedOpacity(
              opacity: _opacity,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
              child: _showDownloadInput ? const DownloadInput() : const SizedBox(),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
                child: TabBarView(
                  controller: _tabController,
                  children: const [
                    OngoingTasks(),
                    CompletedTasks(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Footer
            Text(
              "Made with ❤️ by Aryan Mishra",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
