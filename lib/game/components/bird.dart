import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../flappy_bird_game.dart';
import 'pipe.dart';

class Bird extends PositionComponent with CollisionCallbacks, HasGameReference<FlappyBirdGame> {
  // Physics constants
  static const double gravity = 900.0;
  static const double jumpVelocity = -320.0;
  static const double horizontalSpeed = 160.0;

  double velocityY = 0.0;
  bool isDead = false;

  Bird() : super(
    size: Vector2(46, 36),
    anchor: Anchor.center,
  );

  @override
  Future<void> onLoad() async {
    super.onLoad();
    // Add collision detection hitbox
    add(RectangleHitbox());
  }

  @override
  void onMount() {
    super.onMount();
    reset();
  }

  /// Resets the bird's state to starting parameters
  void reset() {
    position = Vector2(0, 0); // Start at world origin
    velocityY = 0.0;
    angle = 0.0;
    isDead = false;
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (isDead) return;

    // Apply gravity to vertical velocity
    velocityY += gravity * dt;

    // Apply velocities to positions
    position.x += horizontalSpeed * dt;
    position.y += velocityY * dt;

    // Tilting micro-animation: rotate the bird body based on vertical speed
    // Clamped between -0.4 radians (tilting up) and 0.7 radians (diving down)
    angle = (velocityY / 1000).clamp(-0.4, 0.7);
  }

  /// Apply upward force to simulate a flap/jump
  void jump() {
    if (isDead) return;
    velocityY = jumpVelocity;
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    // If the bird hits a pipe, trigger Game Over
    if (other is Pipe) {
      game.gameOver();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Base body (vibrant gold/amber color)
    final bodyPaint = Paint()..color = Colors.amber;
    canvas.drawOval(
      Rect.fromLTWH(0, 0, size.x, size.y),
      bodyPaint,
    );

    // Belly (white bottom-front curve)
    final bellyPaint = Paint()..color = Colors.white;
    canvas.drawArc(
      Rect.fromLTWH(size.x * 0.15, size.y * 0.25, size.x * 0.65, size.y * 0.65),
      0,
      3.14,
      false,
      bellyPaint,
    );

    // Eye (white circle)
    final eyePaint = Paint()..color = Colors.white;
    canvas.drawCircle(
      Offset(size.x * 0.72, size.y * 0.3),
      size.y * 0.22,
      eyePaint,
    );

    // Pupil (black circle)
    final pupilPaint = Paint()..color = Colors.black;
    canvas.drawCircle(
      Offset(size.x * 0.76, size.y * 0.3),
      size.y * 0.1,
      pupilPaint,
    );

    // Beak (sharp orange triangle pointing right)
    final beakPaint = Paint()..color = Colors.orangeAccent;
    final beakPath = Path()
      ..moveTo(size.x * 0.95, size.y * 0.28)
      ..lineTo(size.x * 1.15, size.y * 0.38)
      ..lineTo(size.x * 0.95, size.y * 0.48)
      ..close();
    canvas.drawPath(beakPath, beakPaint);

    // Wing (darker yellow flap)
    final wingPaint = Paint()..color = Colors.amber[700]!;
    canvas.drawOval(
      Rect.fromLTWH(size.x * 0.15, size.y * 0.3, size.x * 0.4, size.y * 0.35),
      wingPaint,
    );
  }
}
