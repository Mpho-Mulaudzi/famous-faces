
import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() => runApp(const FamousFacesApp());

class FamousFacesApp extends StatelessWidget {
  const FamousFacesApp({super.key});

  @override
  Widget build(BuildContext context) {
    const gradient = LinearGradient(
      colors: [Color(0xFF4B169D), Color(0xFFBA00E5)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "FamousFaces – Quiz",
      theme: ThemeData(
        fontFamily: "Poppins",
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00E5FF),
          secondary: Color(0xFFC77DFF),
          tertiary: Color(0xFFFF92F9),
        ),
        scaffoldBackgroundColor: Colors.transparent,
      ),
      home: Container(
        decoration: const BoxDecoration(gradient: gradient),
        child: const SplashScreen(),
      ),
    );
  }
}