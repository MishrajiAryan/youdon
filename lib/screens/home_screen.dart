import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'components/download_input.dart';
import 'components/ongoing_tasks.dart';
import 'components/completed_tasks.dart';
import '../theme_notifier.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _showDownloadInput = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (mounted) {
        setState(() {
          _showDownloadInput = _tabController.index == 0;
        });
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("YouDon - YouTube Downloader"),
        actions: [
          Switch(
            value: Provider.of<ThemeNotifier>(context).themeMode ==
                ThemeMode.dark,
            onChanged: (value) {
              final themeNotifier =
                  Provider.of<ThemeNotifier>(context, listen: false);
              themeNotifier.toggleTheme();
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Ongoing Tasks'),
            Tab(text: 'Completed Tasks'),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_showDownloadInput) const DownloadInput(), // Use const here
            const SizedBox(height: 20),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [ // Use const here
                  OngoingTasks(), // Use const here
                  CompletedTasks(), // Use const here
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}