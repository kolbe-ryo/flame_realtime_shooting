import 'package:flame/game.dart';
import 'package:flame_realtime_shooting/game/game_engine.dart';
import 'package:flame_realtime_shooting/widget/components/lobby_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  late final GameEngine _gameEngine;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/background.jpg', fit: BoxFit.cover),
          GameWidget(game: _gameEngine),
        ],
      ),
    );
  }

  Future<void> _initialize() async {
    _gameEngine = GameEngine(
      onGameOver: (bool) {},
      onGameStateUpdate: (Vector2, int) {},
    );

    // Widgetがマウントするのを待つために１フレームawaitする
    await Future.delayed(Duration.zero);
    if (mounted) {}
  }

  void _openLobbyDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return LobbyDialog(
          onGameStarted: (String) {},
        );
      },
    );
  }
}
