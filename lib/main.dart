import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'screens/main_layout.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null); // Setup Format Tanggal Indo
  runApp(const OnTrayApp());
}

class OnTrayApp extends StatelessWidget {
  const OnTrayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OnTray Catering',
      debugShowCheckedModeBanner: false,
      
      // KONFIGURASI BAHASA INDONESIA
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('id', 'ID')],

      // TEMA APLIKASI
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3B82F6), // Dodger Blue
          primary: const Color(0xFF3B82F6),
          secondary: const Color(0xFFFF6B6B), // Coral
        ),
        scaffoldBackgroundColor: const Color(0xFFF0F9FF), // Very Light Blue
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(), // Font Modern
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF3B82F6),
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
        ),
      ),
      home: const MainLayout(),
    );
  }
}