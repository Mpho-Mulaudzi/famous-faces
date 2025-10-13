import 'package:famous_faces/widgets/animated_background.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:url_launcher/url_launcher.dart';

class LicensesScreen extends StatefulWidget {
  const LicensesScreen({super.key});
  @override
  State<LicensesScreen> createState() => _LicensesScreenState();
}

class _LicensesScreenState extends State<LicensesScreen> {
  List _licenses = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await rootBundle.loadString('lib/data/questions/famous_faces.json');
    setState(() => _licenses = jsonDecode(data));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Image Sources & Licenses")),
      body: ListView.builder(
        itemCount: _licenses.length,
        itemBuilder: (context, i) {
          final item = _licenses[i];
          final text = item["licenseInfo"];
          final RegExp rx = RegExp(r'(https://[^\s]+)');
          final link = rx.firstMatch(text)?.group(0);
          return ListTile(
            title: Text(item["answer"],
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    link != null
                        ? text.replaceAll(link, '')
                        : text,
                    style: const TextStyle(color: Colors.white70)),
                if (link != null)
                  TextButton(
                    onPressed: () => launchUrl(Uri.parse(link),
                        mode: LaunchMode.externalApplication),
                    child: const Text("View License",
                        style: TextStyle(color: Colors.cyanAccent)),
                  )
              ],
            ),
          );
        },
      ),
    );
  }
}