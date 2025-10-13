// lib/widgets/animated_background.dart
import 'package:flutter/material.dart';

class AnimatedBackground extends StatefulWidget {
  final Widget child;
  const AnimatedBackground({super.key, required this.child});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> color1;
  late Animation<Color?> color2;

  @override
  void initState() {
    super.initState();
    _controller =
    AnimationController(vsync: this, duration: const Duration(seconds: 6))
      ..repeat(reverse: true);
    color1 =
        ColorTween(begin: const Color(0xFF4B169D), end: const Color(0xFFBA00E5))
            .animate(_controller);
    color2 =
        ColorTween(begin: const Color(0xFFBA00E5), end: const Color(0xFF4B169D))
            .animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _controller,
    builder: (context, _) => Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color1.value!, color2.value!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: widget.child,
    ),
  );
}