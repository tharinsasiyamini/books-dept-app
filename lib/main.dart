import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/root_page.dart';

void main() {
  runApp(const BookstoreApp());
}

class BookstoreApp extends StatelessWidget {
  const BookstoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Books Dept',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8C0D5D),
          primary: const Color(0xFF8C0D5D),
          secondary: const Color(0xFFFFB8E5),
          background: const Color(0xFFF2F0EF),
        ),
        scaffoldBackgroundColor: const Color(0xFFF2F0EF),
        textTheme: GoogleFonts.interTextTheme(
          Theme.of(context).textTheme,
        ),
        useMaterial3: true,
      ),
      home: const RootPage(),
    );
  }
}
