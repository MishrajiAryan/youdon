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

  // Enhanced Modern Light Theme
  static final ThemeData _lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF6366F1),
      brightness: Brightness.light,
      primary: const Color(0xFF6366F1),
      secondary: const Color(0xFF8B5CF6),
      tertiary: const Color(0xFF06B6D4),
      surface: const Color(0xFFFAFAFA),
      surfaceContainerHighest: const Color(0xFFF1F5F9),
      onSurface: const Color(0xFF0F172A),
      outline: const Color(0xFFE2E8F0),
    ),
    scaffoldBackgroundColor: const Color(0xFFFBFBFB),
    textTheme: GoogleFonts.interTextTheme().copyWith(
      displayLarge: GoogleFonts.inter(
        fontWeight: FontWeight.w900,
        fontSize: 36,
        letterSpacing: -1.2,
        color: const Color(0xFF0F172A),
      ),
      displayMedium: GoogleFonts.inter(
        fontWeight: FontWeight.w800,
        fontSize: 32,
        letterSpacing: -1.0,
        color: const Color(0xFF0F172A),
      ),
      headlineLarge: GoogleFonts.inter(
        fontWeight: FontWeight.w700,
        fontSize: 28,
        letterSpacing: -0.8,
        color: const Color(0xFF1E293B),
      ),
      headlineMedium: GoogleFonts.inter(
        fontWeight: FontWeight.w600,
        fontSize: 24,
        letterSpacing: -0.6,
        color: const Color(0xFF1E293B),
      ),
      titleLarge: GoogleFonts.inter(
        fontWeight: FontWeight.w600,
        fontSize: 20,
        letterSpacing: -0.4,
        color: const Color(0xFF334155),
      ),
      titleMedium: GoogleFonts.inter(
        fontWeight: FontWeight.w500,
        fontSize: 18,
        letterSpacing: -0.2,
        color: const Color(0xFF475569),
      ),
      bodyLarge: GoogleFonts.inter(
        fontWeight: FontWeight.w400,
        fontSize: 16,
        letterSpacing: 0.1,
        color: const Color(0xFF64748B),
      ),
      bodyMedium: GoogleFonts.inter(
        fontWeight: FontWeight.w400,
        fontSize: 14,
        letterSpacing: 0.2,
        color: const Color(0xFF64748B),
      ),
      labelLarge: GoogleFonts.inter(
        fontWeight: FontWeight.w600,
        fontSize: 14,
        letterSpacing: 0.5,
        color: const Color(0xFF475569),
      ),
    ),
    cardTheme: CardTheme(
      elevation: 0,
      shadowColor: Colors.black.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        shadowColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          letterSpacing: 0.2,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
      ),
      labelStyle: GoogleFonts.inter(
        color: const Color(0xFF64748B),
        fontWeight: FontWeight.w500,
        fontSize: 16,
      ),
      hintStyle: GoogleFonts.inter(
        color: const Color(0xFF94A3B8),
        fontWeight: FontWeight.w400,
        fontSize: 16,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.inter(
        color: const Color(0xFF0F172A),
        fontSize: 28,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.8,
      ),
      iconTheme: const IconThemeData(
        color: Color(0xFF475569),
        size: 24,
      ),
    ),
    tabBarTheme: TabBarTheme(
      indicator: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      indicatorSize: TabBarIndicatorSize.tab,
      labelColor: Colors.white,
      unselectedLabelColor: const Color(0xFF64748B),
      labelStyle: GoogleFonts.inter(
        fontWeight: FontWeight.w600,
        fontSize: 15,
        letterSpacing: 0.2,
      ),
      unselectedLabelStyle: GoogleFonts.inter(
        fontWeight: FontWeight.w500,
        fontSize: 15,
        letterSpacing: 0.2,
      ),
    ),
  );

  // Enhanced Modern Dark Theme
  static final ThemeData _darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF6366F1),
      brightness: Brightness.dark,
      primary: const Color(0xFF6366F1),
      secondary: const Color(0xFF8B5CF6),
      tertiary: const Color(0xFF06B6D4),
      surface: const Color(0xFF0F172A),
      surfaceContainerHighest: const Color(0xFF1E293B),
      onSurface: const Color(0xFFE2E8F0),
      outline: const Color(0xFF334155),
    ),
    scaffoldBackgroundColor: const Color(0xFF020817),
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
      displayLarge: GoogleFonts.inter(
        fontWeight: FontWeight.w900,
        fontSize: 36,
        letterSpacing: -1.2,
        color: const Color(0xFFF8FAFC),
      ),
      displayMedium: GoogleFonts.inter(
        fontWeight: FontWeight.w800,
        fontSize: 32,
        letterSpacing: -1.0,
        color: const Color(0xFFF8FAFC),
      ),
      headlineLarge: GoogleFonts.inter(
        fontWeight: FontWeight.w700,
        fontSize: 28,
        letterSpacing: -0.8,
        color: const Color(0xFFE2E8F0),
      ),
      headlineMedium: GoogleFonts.inter(
        fontWeight: FontWeight.w600,
        fontSize: 24,
        letterSpacing: -0.6,
        color: const Color(0xFFE2E8F0),
      ),
      titleLarge: GoogleFonts.inter(
        fontWeight: FontWeight.w600,
        fontSize: 20,
        letterSpacing: -0.4,
        color: const Color(0xFFCBD5E1),
      ),
      titleMedium: GoogleFonts.inter(
        fontWeight: FontWeight.w500,
        fontSize: 18,
        letterSpacing: -0.2,
        color: const Color(0xFFCBD5E1),
      ),
      bodyLarge: GoogleFonts.inter(
        fontWeight: FontWeight.w400,
        fontSize: 16,
        letterSpacing: 0.1,
        color: const Color(0xFF94A3B8),
      ),
      bodyMedium: GoogleFonts.inter(
        fontWeight: FontWeight.w400,
        fontSize: 14,
        letterSpacing: 0.2,
        color: const Color(0xFF94A3B8),
      ),
      labelLarge: GoogleFonts.inter(
        fontWeight: FontWeight.w600,
        fontSize: 14,
        letterSpacing: 0.5,
        color: const Color(0xFFCBD5E1),
      ),
    ),
    cardTheme: CardTheme(
      elevation: 0,
      shadowColor: Colors.black.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: const Color(0xFF0F172A),
      surfaceTintColor: Colors.transparent,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        shadowColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          letterSpacing: 0.2,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF1E293B),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF334155), width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF334155), width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
      ),
      labelStyle: GoogleFonts.inter(
        color: const Color(0xFF94A3B8),
        fontWeight: FontWeight.w500,
        fontSize: 16,
      ),
      hintStyle: GoogleFonts.inter(
        color: const Color(0xFF64748B),
        fontWeight: FontWeight.w400,
        fontSize: 16,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.inter(
        color: const Color(0xFFF8FAFC),
        fontSize: 28,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.8,
      ),
      iconTheme: const IconThemeData(
        color: Color(0xFFE2E8F0),
        size: 24,
      ),
    ),
    tabBarTheme: TabBarTheme(
      indicator: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      indicatorSize: TabBarIndicatorSize.tab,
      labelColor: Colors.white,
      unselectedLabelColor: const Color(0xFF94A3B8),
      labelStyle: GoogleFonts.inter(
        fontWeight: FontWeight.w600,
        fontSize: 15,
        letterSpacing: 0.2,
      ),
      unselectedLabelStyle: GoogleFonts.inter(
        fontWeight: FontWeight.w500,
        fontSize: 15,
        letterSpacing: 0.2,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, child) {
        return MaterialApp(
          title: 'YouDon - Premium YouTube Downloader',
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
