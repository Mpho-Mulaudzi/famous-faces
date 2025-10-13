import 'package:flutter/material.dart';

class OptionButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final bool correct;

  const OptionButton(
      {super.key,
        required this.text,
        required this.onTap,
        required this.correct});

  @override
  Widget build(BuildContext context) {
    final color = correct
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.secondary;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 14),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: onTap,
        child: Text(text),
      ),
    );
  }
}