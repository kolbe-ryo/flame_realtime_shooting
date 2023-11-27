import 'dart:async';

import 'package:flame/components.dart';
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
    // 自分のPlayer設定
    final playerImage = await images.load('player.png');
    _player = Player.me();
    _player.add(
      SpriteComponent(
        sprite: Sprite(playerImage),
        size: Vector2.all(_player.radius * 2),
      ),
    );
    add(_player);

    // 相手のPlayer設定
    final opponentImage = await images.load('opponent.png');
    _opponent = Player.opponent();
    _opponent.add(
      SpriteComponent(
        sprite: Sprite(opponentImage),
        size: Vector2.all(_opponent.radius * 2),
      ),
    );
    add(_opponent);

    _playerBulletImage = await images.load('player-bullet.png');
    _opponentBulletImage = await images.load('opponent-bullet.png');

    return super.onLoad();
  }

  // マウスやカーソルの
  @override
  void onPanUpdate(DragUpdateInfo info) {
    _player.move(info.delta.global);
    final mirroredPosition = _player.getMirroredPercentPosition();
    _onGameStateUpdate(mirroredPosition, _playerLifePoint);
    super.onPanUpdate(info);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isGameOver) {
      return;
    }
    for (final child in children) {
      if (child is Bullet && child.hasBeenHit && !child.isMine) {
        _playerLifePoint = _playerLifePoint - child.damage;
        final mirroredPosition = _player.getMirroredPercentPosition();
        onGameStateUpdate(mirroredPosition, _playerLifePoint);
        _player.updateLife(_playerLifePoint / _initialLifePoints);
      }
    }
    if (_playerLifePoint <= 0) {
      endGame(false);
    }
  }

  /// いずれかのプレーヤーのHPが０になったら呼ばれる関数
  void endGame(bool playerWon) {
    isGameOver = true;
    _onGameOver(playerWon);
  }
}
