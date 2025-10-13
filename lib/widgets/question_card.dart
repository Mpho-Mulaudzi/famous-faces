import 'package:flutter/material.dart';

class QuestionCard extends StatelessWidget {
  final Map<String, dynamic> question;
  const QuestionCard({required this.question, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.black26, borderRadius: BorderRadius.circular(18)),
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(question["imagePath"],
              height: 220, fit: BoxFit.cover),
        ),
        const SizedBox(height: 12),
        Text(question["question"],
            textAlign: TextAlign.center,
            style:
            const TextStyle(color: Colors.white, fontSize: 18, height: 1.3))
      ]),
    );
  }
}