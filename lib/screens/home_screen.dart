import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'package:youdon/models/download_task.dart';
import '../services/downloader.dart';
import '../utils/file_picker.dart';
import 'components/download_input.dart';
import 'components/ongoing_tasks.dart';
import 'components/completed_tasks.dart';
import '../theme_notifier.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _urlController = TextEditingController();
  String _selectedFormat = "mp4";
  String _selectedMode = "single";
  String? _downloadPath;
  List<DownloadTask> downloadQueue = [];
  List<DownloadTask> completedTasks = [];
  late TabController _tabController;
  ThemeMode _themeMode = ThemeMode.system;
  bool _showDownloadInput = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (mounted) {
        setState(() {
          _showDownloadInput = _tabController.index == 0;
        });
      }
    });
  }

  void _loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _downloadPath = prefs.getString('downloadPath');
        int themeModeIndex = prefs.getInt('themeMode') ?? ThemeMode.system.index;
        _themeMode = ThemeMode.values[themeModeIndex];
        Provider.of<ThemeNotifier>(context, listen: false).setTheme(_themeMode);

        String? completedTasksJson = prefs.getString('completedTasks');
        if (completedTasksJson != null) {
          completedTasks = (jsonDecode(completedTasksJson) as List)
              .map((taskJson) => DownloadTask.fromJson(taskJson))
              .toList();
        }
      });
    }
  }

  void _savePreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('downloadPath', _downloadPath ?? "");
    await prefs.setInt('themeMode', _themeMode.index);

    String completedTasksJson =
        jsonEncode(completedTasks.map((task) => task.toJson()).toList());
    await prefs.setString('completedTasks', completedTasksJson);
  }

  void _selectDownloadPath() async {
    String? path = await pickDownloadFolder();
    if (path != null && mounted) {
      setState(() {
        _downloadPath = path;
        _savePreferences();
      });
    }
  }

  void _addToQueue() {
    if (_urlController.text.isEmpty || _downloadPath == null) return;

    DownloadTask newTask = DownloadTask(
      url: _urlController.text,
      format: _selectedFormat,
      mode: _selectedMode,
      downloadPath: _downloadPath!,
    );

    setState(() {
      downloadQueue.add(newTask);
    });

    _startDownload(newTask);
    _urlController.clear();
  }

  void _startDownload(DownloadTask task) async {
    bool isMounted = mounted;

    task.isDownloading = true;
    if (isMounted) {
      setState(() {});
    }

    try {
      debugPrint("Starting download for: ${task.url}");

      await startDownload(
        url: task.url,
        format: task.format,
        downloadMode: task.mode,
        downloadPath: task.downloadPath,
        onProgress: (progress) {
          if (isMounted) {
            setState(() {
              task.progress = progress;
            });
          }
        },
        onTitleReceived: (title) {
          if (isMounted) {
            setState(() {
              task.title = title.isNotEmpty ? title : "Untitled Video";
            });
          }
        },
        onComplete: () {
          debugPrint("Download Complete for: ${task.title ?? task.url}");
          if (isMounted) {
            setState(() {
              task.isCompleted = true;
              task.isDownloading = false;
              downloadQueue.remove(task);
              completedTasks = List.from(completedTasks)..add(task);
              _savePreferences();

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Download of ${task.title ?? task.url} complete!'),
                  duration: const Duration(seconds: 3),
                ),
              );
            });
          }
        },
        onError: (errorMessage) {
          debugPrint("Download Error for: ${task.url}: $errorMessage");
          if (isMounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Download Error: $errorMessage')),
            );
            setState(() {
              task.isDownloading = false;
              _savePreferences();
            });
          }
        },
        createPlaylistFolder: true,
      );
    } catch (e) {
      debugPrint("Exception in _startDownload: $e");
      if (isMounted) {
        setState(() {
          task.isDownloading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("YouDon - YouTube Downloader"),
        actions: [
          Switch(
            value: Provider.of<ThemeNotifier>(context).themeMode == ThemeMode.dark,
            onChanged: (value) {
              _themeMode = value ? ThemeMode.dark : ThemeMode.light;
              Provider.of<ThemeNotifier>(context, listen: false).toggleTheme();
              _savePreferences();
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
            if (_showDownloadInput)
              DownloadInput(
                urlController: _urlController,
                selectedFormat: _selectedFormat,
                selectedMode: _selectedMode,
                downloadPath: _downloadPath,
                onFormatChanged: (newValue) {
                  setState(() {
                    _selectedFormat = newValue!;
                  });
                },
                onModeChanged: (newValue) {
                  setState(() {
                    _selectedMode = newValue!;
                  });
                },
                onSelectDownloadPath: _selectDownloadPath,
                onAddToQueue: _addToQueue,
              ),
            const SizedBox(height: 20),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  OngoingTasks(downloadQueue: downloadQueue),
                  CompletedTasks(completedTasks: completedTasks),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
