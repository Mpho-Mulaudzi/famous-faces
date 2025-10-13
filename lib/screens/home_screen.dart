import 'package:flutter/material.dart';
import '../widgets/animated_background.dart';
import '../widgets/glow_button.dart';
import 'quiz_screen.dart';
import 'licenses_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) => AnimatedBackground(
    child: Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text("FamousFaces"), backgroundColor: Colors.transparent, elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Spacer(),
          const Text("Famous Scientists Quiz",
              style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(height: 50),
          GlowButton(
              text: "Play",
              color: const Color(0xFFFF92F9), // pink
              onPressed: () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => const QuizScreen()))),
          GlowButton(
              text: "Image Sources & Licenses",
              color: const Color(0xFF00E5FF), // blue
              onPressed: () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => const LicensesScreen()))),
          const Spacer(),
          const Text("© 2025 FamousFaces · Educational use only",
              style: TextStyle(color: Colors.white54, fontSize: 12))
        ]),
      ),
    ),
  );
}