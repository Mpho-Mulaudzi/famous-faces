// lib/screens/quiz_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../widgets/animated_background.dart';
import 'results_screen.dart';
import 'package:audioplayers/audioplayers.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});
  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List _questions = [];
  int index = 0;
  int score = 0;
  int? selectedIndex;
  bool answered = false;
  late AudioPlayer _player;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    loadQuiz();

  }

  Future<void> loadQuiz() async {
    final data = await rootBundle.loadString('lib/data/questions/famous_faces.json');
    setState(() => _questions = jsonDecode(data));
  }

  void selectOption(int i) async {
    if (answered) return;
    await _player.play(AssetSource('sounds/drop.mp3'));
    setState(() {
      selectedIndex = i;
      answered = true;
      if (i == _questions[index]["correctIndex"]) score++;
      setState(() => answered = true);
      Future.delayed(const Duration(milliseconds:5000), () {
        showFact(_questions[index]["fact"]);
      });
    });
  }

  void showFact(String fact) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.black87,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Did You Know?",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text(fact,
            style: const TextStyle(color: Colors.white70, fontSize: 16)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              nextQuestion();
            },
            child: const Text("Next →",
                style: TextStyle(color: Color(0xFFFF92F9), fontSize: 16)),
          )
        ],
      ),
    );
  }

  void nextQuestion() {
    if (index < _questions.length - 1) {
      setState(() {
        index++;
        answered = false;
        selectedIndex = null;
      });
    } else {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (_) =>
                  ResultsScreen(score: score, total: _questions.length)));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator(color: Colors.white)));
    }
    final q = _questions[index];

    return AnimatedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text("Question ${index + 1}/${_questions.length}"),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // picture + name
                Card(
                  color: Colors.black26,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(q["imagePath"],
                            height: 220, fit: BoxFit.cover),
                      ),
                      const SizedBox(height: 12),
                      Text(q["scientistName"],
                          style: const TextStyle(
                              fontSize: 22,
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ]),
                  ),
                ),
                const SizedBox(height: 20),
                Text(q["question"],
                    style: const TextStyle(
                        color: Colors.white, fontSize: 18, height: 1.3),
                    textAlign: TextAlign.center),
                const SizedBox(height: 20),
                // options
                for (int i = 0; i < q["options"].length; i++) _buildOption(q, i),
                const SizedBox(height: 20),
                if (answered)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF92F9),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(160, 50),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: nextQuestion,
                    child: const Text("Next →"),
                  ),
                const SizedBox(height: 20)
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOption(dynamic q, int i) {
    final correct = q["correctIndex"] == i;
    final isSelected = selectedIndex == i;

    Color base = const Color(0xFF00E5FF); // blue
    Color correctColor = Colors.greenAccent;
    Color wrongColor = Colors.redAccent;

    Color color;
    IconData? icon;
    if (!answered) {
      color = base;
    } else if (correct) {
      color = correctColor;
      icon = Icons.check;
    } else if (isSelected && !correct) {
      color = wrongColor;
      icon = Icons.close;
    } else {
      color = base.withOpacity(0.3);
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: answered && icon != null
            ? Icon(icon, color: Colors.white)
            : const Icon(Icons.circle_outlined, color: Colors.transparent),
        label: Text(q["options"][i],
            style: const TextStyle(color: Colors.white, fontSize: 16)),
        style: ElevatedButton.styleFrom(
            backgroundColor: color,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12))),
        onPressed: () => selectOption(i),
      ),
    );
  }
}