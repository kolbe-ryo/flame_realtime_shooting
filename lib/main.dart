import 'package:flame_realtime_shooting/widget/pages/game_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const SHootingApp());
}

class SHootingApp extends StatelessWidget {
  const SHootingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Shooting Game',
      home: GamePage(),
    );
  }
}
