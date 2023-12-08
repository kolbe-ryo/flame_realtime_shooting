import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/image_composition.dart' as flame_image;
import 'package:flame_realtime_shooting/game/components/bullet.dart';
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

  void startNewGame() {
    isGameOver = false;
    _playerLifePoint = _initialLifePoints;

    for (final child in children) {
      if (child is Player) {
        child.position = child.initialPosition;
      } else if (child is Bullet) {
        child.removeFromParent();
      }
    }
    _shootBullets();
  }

  /// いずれかのプレーヤーのHPが０になったら呼ばれる関数
  void endGame(bool playerWon) {
    isGameOver = true;
    _onGameOver(playerWon);
  }
}

class _LobbyDialogState extends State<_LobbyDialog> {
  List<String> _userids = [];
  bool _loading = false;

  /// Unique identifier for each players to identify eachother in lobby
  final myUserId = const Uuid().v4();

  late final RealtimeChannel _lobbyChannel;

  @override
  void initState() {
    super.initState();

    _lobbyChannel = supabase.channel(
      'lobby',
      opts: const RealtimeChannelConfig(self: true),
    );
    _lobbyChannel.on(RealtimeListenTypes.presence, ChannelFilter(event: 'sync'), (payload, [ref]) {
      // Update the lobby count
      final presenceState = _lobbyChannel.presenceState();

      setState(() {
        _userids = presenceState.values
            .map((presences) => (presences.first as Presence).payload['user_id'] as String)
            .toList();
      });
    }).on(RealtimeListenTypes.broadcast, ChannelFilter(event: 'game_start'), (payload, [_]) {
      // Start the game if someone has started a game with you
      final participantIds = List<String>.from(payload['participants']);
      if (participantIds.contains(myUserId)) {
        final gameId = payload['game_id'] as String;
        widget.onGameStarted(gameId);
        Navigator.of(context).pop();
      }
    }).subscribe(
      (status, [ref]) async {
        if (status == 'SUBSCRIBED') {
          await _lobbyChannel.track({'user_id': myUserId});
        }
      },
    );
  }

  @override
  void dispose() {
    supabase.removeChannel(_lobbyChannel);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Lobby'),
      content: _loading
          ? const SizedBox(
              height: 100,
              child: Center(child: CircularProgressIndicator()),
            )
          : Text('${_userids.length} users waiting'),
      actions: [
        TextButton(
          onPressed: _userids.length < 2
              ? null
              : () async {
                  setState(() {
                    _loading = true;
                  });

                  final opponentId = _userids.firstWhere((userId) => userId != myUserId);
                  final gameId = const Uuid().v4();
                  await _lobbyChannel.send(
                    type: RealtimeListenTypes.broadcast,
                    event: 'game_start',
                    payload: {
                      'participants': [
                        opponentId,
                        myUserId,
                      ],
                      'game_id': gameId,
                    },
                  );
                },
          child: const Text('start'),
        ),
      ],
    );
  }
}
