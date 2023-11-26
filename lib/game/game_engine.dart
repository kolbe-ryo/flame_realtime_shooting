import 'dart:async';

import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/image_composition.dart' as flame_image;
import 'package:flame_realtime_shooting/game/components/player.dart';
import 'package:flutter/material.dart';

class GameEngine extends FlameGame with PanDetector, HasCollisionDetection {
  GameEngine({
    required Function(bool) onGameOver,
    required Function(Vector2, int) onGameStateUpdate,
  })  : _onGameOver = onGameOver,
        _onGameStateUpdate = onGameStateUpdate;

  static const _initialLifePoints = 100;

  /// ゲームが終了した際のコールバック
  final void Function(bool didWin) _onGameOver;

  /// ゲームの状態がアップデートされた際のコールバック
  final void Function(Vector2 position, int health) _onGameStateUpdate;

  /// 自分自身の`Player`インスタンス
  late Player _player;

  /// 相手プレーヤーの`Player`インスタンス
  late Player _opponent;

  bool isGameOver = true;

  int _playerLifePoint = _initialLifePoints;

  late final flame_image.Image _playerBulletImage;
  late final flame_image.Image _opponentBulletImage;

  @override
  Color backgroundColor() {
    return Colors.transparent;
  }

  @override
  FutureOr<void> onLoad() async {
    final playerImage = await images.load('player.png');

    return super.onLoad();
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    // TODO: implement onPanUpdate
    super.onPanUpdate(info);
  }

  @override
  void update(double dt) {
    // TODO: implement update
    super.update(dt);
  }
}
