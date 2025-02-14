import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart'; // Correct path
import 'theme_notifier.dart';
import 'models/download_manager.dart'; // Import your DownloadManager

void main() {
  runApp(
    MultiProvider( // Use MultiProvider
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeNotifier(),
        ),
        ChangeNotifierProvider( // Add this for DownloadManager
          create: (_) => DownloadManager(),
        ),
      ],
      child: const YouDonApp(), // const added
    ),
  );
}

class YouDonApp extends StatelessWidget {
  const YouDonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, child) {
        return MaterialApp(
          title: 'YouDon - YouTube Downloader',
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: themeNotifier.themeMode,
          home: const HomeScreen(), // const added
        );
      },
    );
  }
}