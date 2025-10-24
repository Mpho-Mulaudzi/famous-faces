import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/audio_service.dart';
import '../services/settings_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final audio = AudioManager();
  bool _showFacts = true;

  @override
  void initState() {
    super.initState();
    _loadShowFactsPref();
  }

  Future<void> _loadShowFactsPref() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _showFacts = prefs.getBool('showFacts') ?? true;
    });
  }

  Future<void> _toggleShowFacts(bool value) async {
    setState(() => _showFacts = value);
    await SettingsService.setShowFacts(value);
    await audio.playSfx('drop');
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
          title: const Text('Settings', style: TextStyle(color: Colors.white)),
        ),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SwitchListTile(
                title: const Text('Music',
                    style: TextStyle(color: Colors.white)),
                value: audio.isMusicOn,
                activeColor: const Color(0xFF00E5FF),
                onChanged: (on) async {
                  setState(() => audio.toggleMusic(on));
                  await audio.playSfx('drop');
                },
              ),
              SwitchListTile(
                title: const Text('Sound Effects',
                    style: TextStyle(color: Colors.white)),
                value: audio.isSfxOn,
                activeColor: const Color(0xFF00E5FF),
                onChanged: (on) async {
                  setState(() => audio.toggleSfx(on));
                  await audio.playSfx('drop');
                },
              ),

              // 👇 NEW "Show Facts" toggle (keeps look consistent)
              SwitchListTile(
                title: const Text('Show Facts After  Quiz',
                    style: TextStyle(color: Colors.white)),
                value: _showFacts,
                activeColor: const Color(0xFF00E5FF),
                onChanged: _toggleShowFacts,
              ),

              const SizedBox(height: 20),
              const Text('Music Volume',
                  style: TextStyle(color: Colors.white)),
              Slider(
                activeColor: const Color(0xFF00E5FF),
                value: audio.musicVolume,
                min: 0,
                max: 1,
                onChanged: (value) => setState(() {
                  audio.setMusicVolume(value);
                }),
              ),
              const Spacer(),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00E5FF),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 60, vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    await audio.playSfx('drop');
                    Navigator.pop(context);
                  },
                  child: const Text('Back',
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> shouldShowFacts() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('showFacts') ?? true;
  }
}