import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:confetti/confetti.dart';
import '../widgets/animated_background.dart';
import '../services/audio_service.dart';
import '../services/ad_service.dart';
import 'results_screen.dart';
import '../services/game_progress_service.dart';
import '../services/settings_service.dart';
import 'package:flutter/scheduler.dart';

class QuizScreen extends StatefulWidget {
  final String category;
  const QuizScreen({super.key, required this.category});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final AudioManager _audio = AudioManager(); // use your singleton
  List _questions = [];
  int index = 0;
  int score = 0;
  int? selectedIndex;
  bool answered = false;
  int correctStreak = 0;
  final AdManager _ads = AdManager();
  int _nextAdThreshold = 3;

  late ConfettiController _confetti;


  @override
  void initState() {
    super.initState();
    _loadQuestions();
    _confetti = ConfettiController(duration: const Duration(seconds: 2));

    // 🔊 Make sure BGM is running
    _audio.playBgm();

    _ads.loadAd();
  }
  Future<void> _checkAvailability() async {
    final canPlay = await GameProgressService.canPlayNow();
    if (!canPlay && mounted) {
      final rem = await GameProgressService.remainingQuestions();
      _showWaitDialog(); // define below
    } else {
      await _loadQuestions();
    }
  }

  void _showWaitDialog() async {
    Duration remaining = await GameProgressService.timeLeft();

    late final Ticker _ticker;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        ValueNotifier<Duration> timeLeft = ValueNotifier(remaining);
        // update countdown every second
        _ticker = Ticker((elapsed) {
          final secondsLeft = remaining.inSeconds - elapsed.inSeconds;
          if (secondsLeft <= 0) {
            _ticker.stop();
            timeLeft.value = Duration.zero;
          } else {
            timeLeft.value = Duration(seconds: secondsLeft);
          }
        })..start();

        return AlertDialog(
          backgroundColor: const Color(0xFF4B169D),
          title: const Text('You’ve hit your limit!',
              style: TextStyle(color: Colors.white)),
          content: ValueListenableBuilder<Duration>(
            valueListenable: timeLeft,
            builder: (_, time, __) {
              if (time == Duration.zero) {
                return const Text(
                  'You can now continue playing!',
                  style: TextStyle(color: Colors.white70),
                );
              }
              final m = time.inMinutes.remainder(60).toString().padLeft(2, '0');
              final s = time.inSeconds.remainder(60).toString().padLeft(2, '0');
              return Text(
                'Please wait $m m $s s before playing again.',
                style: const TextStyle(color: Colors.white70),
              );
            },
          ),
          actions: [
            TextButton(
              child: const Text('OK', style: TextStyle(color: Color(0xFF00E5FF))),
              onPressed: () {
                _ticker.dispose();
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }


  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    try {
      final data = await rootBundle
          .loadString('assets/questions/${widget.category}.json');
      final decoded = jsonDecode(data);
      if (decoded is List && decoded.isNotEmpty) {
        decoded.shuffle();
        setState(() => _questions = decoded);
      }
    } catch (e) {
      debugPrint('❌ Error loading questions: $e');
    }
  }

  void selectOption(int i) async {
    if (answered || _questions.isEmpty) return;

    await _audio.playSfx('drop');

    final q = _questions[index];
    final isCorrect = i == q["correctIndex"];

    setState(() {
      selectedIndex = i;
      answered = true;
    });

    if (isCorrect) {
      await _audio.playSfx('correct');
      score++;
      correctStreak++;
      if (correctStreak == 3) _triggerConfetti();
    } else {
      await _audio.playSfx('wrong');
      correctStreak = 0;
    }

    Future.delayed(const Duration(milliseconds: 800), () async {
      final showFacts = await SettingsService.shouldShowFacts();

      if (showFacts) {
        _showFact(q);
      } else {
        _nextQuestion();
      }
    });
  }

  void _triggerConfetti() {
    _confetti.play();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      backgroundColor: Colors.pinkAccent,
      content: Text("🎉 Well done! 3 in a row!",
          textAlign: TextAlign.center),
    ));
    correctStreak = 0;
  }

  void _showFact(dynamic q) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.black87,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Did You Know?",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            )),
        content: Text(
          q["fact"] ?? "Keep learning!",
          style: const TextStyle(color: Colors.white70, fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _nextQuestion();
            },
            child: const Text("Next →",
                style:
                TextStyle(color: Color(0xFFFF92F9), fontSize: 16)),
          ),
        ],
      ),
    );
  }

  void _nextQuestion() async {
    _audio.playSfx('drop');

    await GameProgressService.incrementPlayCount(
      category: widget.category,
      index: index,
    );

    // ✅ Check if user already answered 10 questions
    if (index + 1 >= 10) {
      // Save score and show results
      await GameProgressService.saveScore(score);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultsScreen(score: score, total: 10),
        ),
      );
      return; // Exit the method
    }

    if (index < _questions.length - 1) {
      setState(() {
        index++;
        answered = false;
        selectedIndex = null;
      });

      // 👇 Show ads after 3rd question, then every 5th afterwards
      if ((index + 1) == _nextAdThreshold) {
        _ads.showAdIfAvailable();
        _nextAdThreshold += _nextAdThreshold == 3 ? 3 : 5;
      }
    } else {
      // fallback if there are fewer than 10 questions
      await GameProgressService.saveScore(score);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultsScreen(score: score, total: _questions.length),
        ),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    final q = _questions[index];

    return AnimatedBackground(
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              title: Text(
                "Question ${index + 1}",
                style: const TextStyle(color: Colors.white),
              ),
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Card(
                      color: Colors.black26,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset(
                                q["imagePath"] ?? '',
                                height: 220,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                const SizedBox(
                                  height: 220,
                                  child: Center(
                                    child: Icon(Icons.broken_image,
                                        color: Colors.white38, size: 60),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              q["scientistName"] ?? '',
                              style: const TextStyle(
                                fontSize: 22,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      q["question"] ?? '',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 20),
                    for (int i = 0; i < (q["options"]?.length ?? 0); i++)
                      _buildOption(q, i),
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confetti,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [Colors.pink, Colors.blue, Colors.cyan],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOption(dynamic q, int i) {
    final correct = q["correctIndex"] == i;
    final isSelected = selectedIndex == i;

    Color color;
    IconData? icon;

    if (!answered) {
      color = const Color(0xFF00E5FF);
    } else if (correct) {
      color = Colors.greenAccent;
      icon = Icons.check;
    } else if (isSelected && !correct) {
      color = Colors.redAccent;
      icon = Icons.close;
    } else {
      color = const Color(0xFF00E5FF).withOpacity(0.3);
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: Icon(
          icon ?? Icons.circle_outlined,
          color: icon == null ? Colors.transparent : Colors.white,
        ),
        label: Text(
          q["options"][i],
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () => selectOption(i),
      ),
    );
  }
}