import '../widgets/banner_ad.dart';
import '../services/game_progress_service.dart';
import 'package:flutter/material.dart';
import 'home_screen.dart';

class ResultsScreen extends StatelessWidget {
  final int score;
  final int total;
  const ResultsScreen({super.key, required this.score, required this.total});

  @override
  Widget build(BuildContext context) {
    final percent = ((score / total) * 100).round();
    GameProgressService.saveScore(score);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text("Your Results"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("$score / $total",
                  style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
              Text("$percent %",
                  style: const TextStyle(fontSize: 22, color: Colors.white70)),
              const SizedBox(height: 40),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.black),
                  onPressed: () => Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (_) => const HomeScreen())),
                  child: const Text("Play Again")),
              // const BannerAdWidget()
            ],

          ),
        ),
      ),
    );
  }
}
