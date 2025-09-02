import 'dart:io';
import 'package:flutter/foundation.dart';

class UpdateService {
  static Future<Map<String, dynamic>> updateYtDlp() async {
    try {
      debugPrint("Starting yt-dlp update...");
      
      // Use the same path structure as your downloader
      String ytDlpPath = "dependencies/yt-dlp.exe";
      
      // Run the update command
      ProcessResult result = await Process.run(
        ytDlpPath,
        ['-U'],
        workingDirectory: Directory.current.path,
      );

      debugPrint("Update stdout: ${result.stdout}");
      debugPrint("Update stderr: ${result.stderr}");
      debugPrint("Update exit code: ${result.exitCode}");

      if (result.exitCode == 0) {
        return {
          'success': true,
          'message': 'yt-dlp updated successfully!',
          'output': result.stdout.toString(),
        };
      } else {
        return {
          'success': false,
          'message': 'Update failed',
          'error': result.stderr.toString(),
        };
      }
    } catch (e) {
      debugPrint("Update error: $e");
      return {
        'success': false,
        'message': 'Update failed',
        'error': e.toString(),
      };
    }
  }

  static Future<void> restartApp() async {
    try {
      // Get the current executable path
      String executable = Platform.resolvedExecutable;
      
      // Start a new instance using ProcessStartMode.detached
      await Process.start(
        executable, 
        [],
        mode: ProcessStartMode.detached,  // Use mode parameter instead of detached
      );
      
      // Exit current instance
      exit(0);
    } catch (e) {
      debugPrint("Restart error: $e");
      // Fallback: just exit the app, user can manually restart
      exit(0);
    }
  }
}
