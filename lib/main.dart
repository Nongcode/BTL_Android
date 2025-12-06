import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Bạn nên thêm thư viện google_fonts vào pubspec.yaml
import 'core/constants/app_colors.dart';
import 'main_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HousePal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        // Sử dụng Font chữ hiện đại (như trong thiết kế có vẻ là Poppins hoặc Roboto)
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme,
        ),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}