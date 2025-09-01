import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home_screen.dart';
import 'theme_notifier.dart';
import 'models/download_manager.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),
        ChangeNotifierProvider(create: (_) => DownloadManager()),
      ],
      child: const YouDonApp(),
    ),
  );
}

class YouDonApp extends StatelessWidget {
  const YouDonApp({super.key});

  // Custom Light Theme
  static final ThemeData _lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF6366F1), // Modern indigo
      brightness: Brightness.light,
    ),
    textTheme: GoogleFonts.interTextTheme().copyWith(
      displayLarge: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 32),
      displayMedium: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 28),
      headlineLarge: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 24),
      headlineMedium: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 20),
      titleLarge: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 18),
      titleMedium: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 16),
      bodyLarge: GoogleFonts.inter(fontWeight: FontWeight.w400, fontSize: 16),
      bodyMedium: GoogleFonts.inter(fontWeight: FontWeight.w400, fontSize: 14),
      labelLarge: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 14),
    ),
    cardTheme: CardTheme(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
      ),
      labelStyle: GoogleFonts.inter(
        color: const Color(0xFF64748B),
        fontWeight: FontWeight.w500,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.inter(
        color: const Color(0xFF0F172A),
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
      iconTheme: const IconThemeData(color: Color(0xFF475569)),
    ),
    tabBarTheme: TabBarTheme(
      indicator: BoxDecoration(
        color: const Color(0xFF6366F1),
        borderRadius: BorderRadius.circular(8),
      ),
      indicatorSize: TabBarIndicatorSize.tab,
      labelColor: Colors.white,
      unselectedLabelColor: const Color(0xFF64748B),
      labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
      unselectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 14),
    ),
  );

  // Custom Dark Theme
  static final ThemeData _darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF6366F1),
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: const Color(0xFF0F172A),
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
      displayLarge: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 32, color: Colors.white),
      displayMedium: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 28, color: Colors.white),
      headlineLarge: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 24, color: Colors.white),
      headlineMedium: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 20, color: Colors.white),
      titleLarge: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 18, color: Colors.white),
      titleMedium: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 16, color: Colors.white),
      bodyLarge: GoogleFonts.inter(fontWeight: FontWeight.w400, fontSize: 16, color: const Color(0xFFE2E8F0)),
      bodyMedium: GoogleFonts.inter(fontWeight: FontWeight.w400, fontSize: 14, color: const Color(0xFFCBD5E1)),
      labelLarge: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 14, color: Colors.white),
    ),
    cardTheme: CardTheme(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: const Color(0xFF1E293B),
      surfaceTintColor: Colors.transparent,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF1E293B),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF334155), width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF334155), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
      ),
      labelStyle: GoogleFonts.inter(
        color: const Color(0xFF94A3B8),
        fontWeight: FontWeight.w500,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF0F172A),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.inter(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
      iconTheme: const IconThemeData(color: Color(0xFFE2E8F0)),
    ),
    tabBarTheme: TabBarTheme(
      indicator: BoxDecoration(
        color: const Color(0xFF6366F1),
        borderRadius: BorderRadius.circular(8),
      ),
      indicatorSize: TabBarIndicatorSize.tab,
      labelColor: Colors.white,
      unselectedLabelColor: const Color(0xFF94A3B8),
      labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
      unselectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 14),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, child) {
        return MaterialApp(
          title: 'YouDon - YouTube Downloader',
          theme: _lightTheme,
          darkTheme: _darkTheme,
          themeMode: themeNotifier.themeMode,
          home: const HomeScreen(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
