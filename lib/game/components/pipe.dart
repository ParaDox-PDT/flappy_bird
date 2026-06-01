import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../flappy_bird_game.dart';

class Pipe extends PositionComponent with CollisionCallbacks {
  final ObstacleSprites sprites;
  final bool isTop;

  Pipe({
    required this.sprites,
    required Vector2 position,
    required Vector2 size,
    required this.isTop,
  }) : super(
          position: position,
          size: size,
          anchor: Anchor.topLeft,
        );

  @override
  Future<void> onLoad() async {
    super.onLoad();
    // Add a slightly shrunk hitbox horizontally to make close calls feel more realistic
    add(RectangleHitbox(
      size: Vector2(56, size.y),
      position: Vector2(4, 0),
    ));
  }

  @override
  void render(Canvas canvas) {
    final w = size.x;
    final h = size.y;

    double capH = sprites.bottomEndHeight;
    double endH = sprites.topEndHeight;

    // Proportional scaling if total height is too small
    if (h < capH + endH) {
      final ratio = h / (capH + endH);
      capH *= ratio;
      endH *= ratio;
    }

    final shaftH = h - capH - endH;

    if (isTop) {
      // Top pipe: drawn normally (leaves at top Y=0, cap at bottom Y=h)
      // 1. Top End (Leaves/Roots) at Y=0
      sprites.topEnd.render(canvas, position: Vector2(0, 0), size: Vector2(w, endH));

      // 2. Middle Shaft in between
      if (shaftH > 0) {
        sprites.shaft.render(canvas, position: Vector2(0, endH), size: Vector2(w, shaftH));
      }

      // 3. Bottom End (Cap/Cut) at Y=h - capH
      sprites.bottomEnd.render(canvas, position: Vector2(0, h - capH), size: Vector2(w, capH));
    } else {
      // Bottom pipe: flipped vertically (leaves at bottom Y=h, cap at top Y=0)
      
      // 1. Bottom End (Cap/Cut) at Y=0 (flipped)
      _renderFlipped(canvas, sprites.bottomEnd, 0, 0, w, capH);

      // 2. Middle Shaft in between (flipped)
      if (shaftH > 0) {
        _renderFlipped(canvas, sprites.shaft, 0, capH, w, shaftH);
      }

      // 3. Top End (Leaves/Roots) at Y=h - endH (flipped)
      _renderFlipped(canvas, sprites.topEnd, 0, h - endH, w, endH);
    }
  }

  void _renderFlipped(Canvas canvas, Sprite sprite, double x, double y, double width, double height) {
    canvas.save();
    canvas.translate(x, y + height);
    canvas.scale(1.0, -1.0);
    sprite.render(canvas, position: Vector2.zero(), size: Vector2(width, height));
    canvas.restore();
  }
}
