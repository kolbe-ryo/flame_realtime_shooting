import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class Player extends PositionComponent with HasGameRef, CollisionCallbacks {
  Player._(this._isMyPlayer);

  factory Player.me() => Player._(true);

  factory Player.opponent() => Player._(false);

  final bool _isMyPlayer;

  static const _radius = 30.0;

  double get radius => _radius;

  late final Vector2 initialPosition;

  Vector2 velocity = Vector2.zero();

  @override
  FutureOr<void> onLoad() {
    // TODO: implement onLoad
    return super.onLoad();
  }

  void move(Vector2 delta) {
    position += delta;
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    // TODO: implement onCollision
    super.onCollision(intersectionPoints, other);
  }
}
