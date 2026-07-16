import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/detail_screen.dart';
import 'screens/reading_screen.dart';
import 'services/preferences_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Pre-initialize PreferencesService before running MaterialApp
  await PreferencesService.instance.init();
  
  runApp(const NovelReaderApp());
}

class NovelReaderApp extends StatelessWidget {
  const NovelReaderApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Listens to PreferencesService notifications to update theme indexes and fonts instantly
    return ListenableBuilder(
      listenable: PreferencesService.instance,
      builder: (context, child) {
        final settings = PreferencesService.instance;
        
        return MaterialApp(
          title: 'Novel Reader App',
          debugShowCheckedModeBanner: false,
          themeMode: settings.themeModeIndex == 1
              ? ThemeMode.dark
              : (settings.themeModeIndex == 0 ? ThemeMode.light : ThemeMode.system),
          
          // Light Theme configuration
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF0F172A),
              brightness: Brightness.light,
            ),
            fontFamily: GoogleFonts.getFont(settings.currentFontFamily).fontFamily,
            scaffoldBackgroundColor: const Color(0xFFF8FAFC),
          ),
          
          // Dark Theme configuration
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF00FFCC),
              brightness: Brightness.dark,
            ),
            fontFamily: GoogleFonts.getFont(settings.currentFontFamily).fontFamily,
            scaffoldBackgroundColor: const Color(0xFF0F172A),
          ),
          
          initialRoute: '/',
          routes: {
            '/': (context) => const SplashScreen(),
            '/home': (context) => const HomeScreen(),
            '/detail': (context) => const DetailScreen(),
            '/reading': (context) => const ReadingScreen(),
          },
        );
      },
    );
  }
}
