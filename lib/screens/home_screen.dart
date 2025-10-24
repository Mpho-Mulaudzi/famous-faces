// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import '../services/audio_service.dart';
import '../services/game_progress_service.dart';
import 'quiz_screen.dart';
import 'settings_screen.dart';
import 'package:flutter/scheduler.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin , WidgetsBindingObserver{
  final audio = AudioManager();

  int topStreak = 0;
  Duration _timeLeft = Duration.zero;
  int _remaining = 10;
  Ticker? _ticker;

  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _checkLastProgress();
    _loadTopStreak();
    WidgetsBinding.instance.addObserver(this);
    _controller =
    AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    // load top streak from storage later if desired
    _initGameProgressWatcher();
  }

  Future<void> _initGameProgressWatcher() async {
    final canPlay = await GameProgressService.canPlayNow();
    final rem = await GameProgressService.remainingQuestions();
    final left = await GameProgressService.timeLeft();

    setState(() {
      _remaining = rem;
      _timeLeft = left;
    });

    _ticker?.dispose();

    // Start a live countdown if user is locked
    if (!canPlay && left > Duration.zero) {
      _ticker = Ticker((elapsed) {
        final secondsLeft = left.inSeconds - elapsed.inSeconds;
        if (secondsLeft <= 0) {
          _ticker?.stop();
          setState(() {
            _timeLeft = Duration.zero;
            _remaining = 10; // reset available plays
          });
        } else {
          setState(() {
            _timeLeft = Duration(seconds: secondsLeft);
          });
        }
      })..start();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _ticker?.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _checkLastProgress() async {
    final progress = await GameProgressService.getLastProgress();
    if (!mounted || progress == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF4B169D),
        title: const Text(
          'Continue last quiz?',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'You last played ${progress['category']} at question ${progress['index'] + 1}.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            child: const Text('Restart',
                style: TextStyle(color: Color(0xFF00E5FF))),
            onPressed: () async {
              await GameProgressService.clearProgress();
              if (mounted) Navigator.pop(context);
            },
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00E5FF),
            ),
            child: const Text('Continue',
                 style:TextStyle(color: Colors.white70)

            ),
            onPressed: () {
              Navigator.pop(context);
              openQuiz(progress['category']);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _loadTopStreak() async {
    final top = await GameProgressService.getTopStreak();
    setState(() {
      topStreak = top;
    });
  }

  void openQuiz(String category) async {
    await audio.playSfx('drop');

    final canPlay = await GameProgressService.canPlayNow();
    if (!canPlay) {
      _showWaitDialog(context);
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuizScreen(
          key: ValueKey(category),
          category: category,
        ),
      ),
    );
  }

  void _showWaitDialog(BuildContext context) async {
    Duration remaining = await GameProgressService.timeLeft();
    late final Ticker _ticker;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        ValueNotifier<Duration> timeLeft = ValueNotifier(remaining);
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
          title: const Text('Take a short break!',
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
                'Please wait $m m $s s before playing again.',
                style: const TextStyle(color: Colors.white70),
              );
            },
          ),
          actions: [
            TextButton(
              child: const Text('OK',
                  style: TextStyle(color: Color(0xFF00E5FF))),
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

  void _showDisclaimerDialog() async {
    await audio.playSfx('drop');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          'Disclaimer',
          style: TextStyle(
            color: Colors.amberAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'No copyright infringement intended.\n'
              'If any content in this game violates your rights'
              'please contact  @christianmpho@gmail.com us to request removal.',
          style: TextStyle(color: Colors.white70, fontSize: 15, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: Colors.amberAccent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const gradient = LinearGradient(
      colors: [Color(0xFF4B169D), Color(0xFFBA00E5)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Container(
      decoration: const BoxDecoration(gradient: gradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            'Famous Faces Quiz',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings, color: Colors.white),
              onPressed: () async {
                await audio.playSfx('drop');
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SettingsScreen(),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.info_outline, color: Colors.white),
              tooltip: 'Disclaimer',
              onPressed: _showDisclaimerDialog,
            ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // ───────────── Top streak indicator ─────────────
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(12),
                    border:
                    Border.all(color: const Color(0xFF00E5FF), width: 1.2),
                  ),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.emoji_events,
                          color: Colors.amberAccent),
                      const SizedBox(width: 8),
                      Text(
                        '🔥Top Streak: $topStreak out 10',
                        style: const TextStyle(
                            color: Colors.white, fontSize: 18),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: _remaining > 0 && _timeLeft == Duration.zero
                      ? Text(
                    '🧠 You can play $_remaining more quizzes before a break',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  )
                      : Text(
                    _timeLeft == Duration.zero
                        ? '🎮 Ready to play!'
                        : '⏳ New quizzes unlock in '
                        '${_timeLeft.inMinutes.remainder(60).toString().padLeft(2, '0')} m '
                        '${_timeLeft.inSeconds.remainder(60).toString().padLeft(2, '0')} s',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ),


                // ───────────── Animated Cards Grid ─────────────
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 20,
                    childAspectRatio: 1.5,
                    children: [
                      _AnimatedCategoryCard(
                        animation: _animation,
                        label: 'Scientists',
                        icon: Icons.science_rounded,
                        color: Colors.cyanAccent,
                        onTap: () => openQuiz('scientists'),
                      ),
                      _AnimatedCategoryCard(
                        animation: _animation,
                        label: 'Actors',
                        icon: Icons.movie_creation_outlined,
                        color: Colors.pinkAccent,
                        onTap: () => openQuiz('actors'),
                      ),
                      _AnimatedCategoryCard(
                        animation: _animation,
                        label: 'Artists',
                        icon: Icons.palette_outlined,
                        color: Colors.orangeAccent,
                        onTap: () => openQuiz('artists'),
                      ),
                      _AnimatedCategoryCard(
                        animation: _animation,
                        label: 'Politicians',
                        icon: Icons.account_balance_rounded,
                        color: Colors.greenAccent,
                        onTap: () => openQuiz('politicians'),
                      ),
                      _AnimatedCategoryCard(
                        animation: _animation,
                        label: 'Sports',
                        icon: Icons.sports_baseball_sharp,
                        color: Colors.cyanAccent,
                        onTap: () => openQuiz('sports'),
                      ),
                    ],
                  ),
                ),

                // ───────────── Footer links ─────────────
                Padding(
                  padding: const EdgeInsets.only(bottom: 8, top: 4),
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    alignment: WrapAlignment.center,
                    spacing: 5,
                    children: [
                      const Text(
                        '© 2025 FamousFaces. Educational use only.\n No Copyright infringement intended.',
                        style: TextStyle(color: Colors.white38, fontSize: 12),
                      ),
                      GestureDetector(
                        onTap: () async {
                          await audio.playSfx('drop');
                          showLicensePage(
                            context: context,
                            applicationName: 'Famous Faces Quiz',
                            applicationVersion: '1.0.0',
                            applicationLegalese:
                            'Sounds from Freesound.org (CC0)\n'
                                'Images from public domain sources.',
                          );
                        },
                        child: const Text(
                          'Licenses / Credits',
                          style: TextStyle(
                            color: Colors.lightBlueAccent,
                            decoration: TextDecoration.underline,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ───────────── Animated Card Widget ─────────────
class _AnimatedCategoryCard extends StatelessWidget {
  final Animation<double> animation;
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _AnimatedCategoryCard({
    required this.animation,
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale:
      Tween<double>(begin: 0.95, end: 1.05).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOut,
      )),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: color, width: 2),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 12,
                spreadRadius: 1,
              )
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 50),
              const SizedBox(height: 10),
              Text(label,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18)),
            ],
          ),
        ),
      ),
    );
  }
}