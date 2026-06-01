import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class Pipe extends RectangleComponent with CollisionCallbacks {
  Pipe({
    required Vector2 position,
    required Vector2 size,
    required Color color,
  }) : super(
          position: position,
          size: size,
          paint: Paint()..color = color,
          anchor: Anchor.topLeft,
        );

  @override
  Future<void> onLoad() async {
    super.onLoad();
    // Add a hitbox that covers the entire rectangular area of the pipe
    add(RectangleHitbox());
  }
}
