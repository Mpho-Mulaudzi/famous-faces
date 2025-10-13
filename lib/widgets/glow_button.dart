// lib/widgets/glow_button.dart
import 'package:flutter/material.dart';

class GlowButton extends StatefulWidget {
  final String text;
  final Color color;
  final VoidCallback onPressed;
  const GlowButton(
      {super.key, required this.text, required this.color, required this.onPressed});

  @override
  State<GlowButton> createState() => _GlowButtonState();
}

class _GlowButtonState extends State<GlowButton> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl =
    AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          final glow = BoxShadow(
              color: widget.color.withOpacity(0.6 + 0.4 * _ctrl.value),
              blurRadius: 20 + 10 * _ctrl.value,
              spreadRadius: 1);
          return Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              width: double.infinity,
              decoration: BoxDecoration(boxShadow: [glow]),
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.color,
                    foregroundColor: Colors.white,
                    padding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                    textStyle:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: widget.onPressed,
                  child: Text(widget.text)));
        });
  }
}