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
    size: Vector2(52, 42), // Slightly larger bounding box for beautiful geometry details
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

    final w = size.x;
    final h = size.y;

    // 1. Shaders & Gradients configuration based on dynamic component size
    final backWingShader = LinearGradient(
      colors: [
        const Color(0xFF0D47A1), // Very dark blue
        const Color(0xFF01579B), // Medium dark blue
      ],
      begin: Alignment.bottomRight,
      end: Alignment.topLeft,
    ).createShader(Rect.fromLTWH(0, 0, w, h));

    final tailShader = LinearGradient(
      colors: [
        const Color(0xFF01579B),
        const Color(0xFF0288D1), // Sky blue
      ],
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
    ).createShader(Rect.fromLTWH(0, 0, w, h));

    final bodyShader = LinearGradient(
      colors: [
        const Color(0xFF02569B), // Flutter Primary Blue
        const Color(0xFF0175C2), // Flutter Secondary Blue
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).createShader(Rect.fromLTWH(0, 0, w, h));

    final bellyShader = LinearGradient(
      colors: [
        const Color(0xFF00E5FF), // Bright Cyan / Turquoise
        const Color(0xFF00B0FF), // Light Sky Blue
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ).createShader(Rect.fromLTWH(0, 0, w, h));

    final frontWingShader1 = LinearGradient(
      colors: [
        const Color(0xFF80DEEA), // Light pastel cyan
        const Color(0xFF00ACC1), // Deep turquoise
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ).createShader(Rect.fromLTWH(0, 0, w, h));

    final frontWingShader2 = LinearGradient(
      colors: [
        const Color(0xFF00B0FF),
        const Color(0xFF01579B),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).createShader(Rect.fromLTWH(0, 0, w, h));

    final beakShader = LinearGradient(
      colors: [
        const Color(0xFFFFD54F), // Amber
        const Color(0xFFFF8F00), // Dark Amber / Orange
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).createShader(Rect.fromLTWH(w * 0.75, h * 0.35, w * 0.4, h * 0.2));

    // 2. Render Back Wing (placed behind body)
    final backWingPaint = Paint()..shader = backWingShader;
    final backWingPath = Path()
      ..moveTo(w * 0.32, h * 0.35)
      ..lineTo(w * 0.08, h * -0.05)
      ..lineTo(w * 0.22, h * -0.02)
      ..lineTo(w * 0.38, h * 0.32)
      ..close();
    canvas.drawPath(backWingPath, backWingPaint);

    // 3. Render Tail (placed behind body)
    final tailPaint = Paint()..shader = tailShader;
    final tailPath = Path()
      ..moveTo(w * 0.15, h * 0.5)
      ..lineTo(w * -0.15, h * 0.58) // Extend tail slightly backward
      ..lineTo(w * -0.08, h * 0.72)
      ..lineTo(w * 0.25, h * 0.62)
      ..close();
    canvas.drawPath(tailPath, tailPaint);

    // 4. Render Main Body (Geometric Blue Core)
    final bodyPaint = Paint()..shader = bodyShader;
    final bodyPath = Path()
      ..moveTo(w * 0.15, h * 0.5)
      ..lineTo(w * 0.28, h * 0.28)
      ..lineTo(w * 0.55, h * 0.22) // Head top
      ..lineTo(w * 0.75, h * 0.35) // Head front
      ..lineTo(w * 0.78, h * 0.45) // Throat
      ..lineTo(w * 0.62, h * 0.55)
      ..lineTo(w * 0.38, h * 0.65)
      ..lineTo(w * 0.15, h * 0.5)
      ..close();
    canvas.drawPath(bodyPath, bodyPaint);

    // 5. Render Belly and Chest (Geometric Turquoise/Cyan accent)
    final bellyPaint = Paint()..shader = bellyShader;
    final bellyPath = Path()
      ..moveTo(w * 0.62, h * 0.55)
      ..lineTo(w * 0.78, h * 0.45)
      ..lineTo(w * 0.72, h * 0.6)   // Chest puff
      ..lineTo(w * 0.52, h * 0.78)   // Belly curve
      ..lineTo(w * 0.32, h * 0.72)   // Lower belly
      ..lineTo(w * 0.38, h * 0.65)
      ..close();
    canvas.drawPath(bellyPath, bellyPaint);

    // 6. Render Beak (hummingbird sharp orange style)
    final beakPaint = Paint()..shader = beakShader;
    final beakPath = Path()
      ..moveTo(w * 0.76, h * 0.36)
      ..lineTo(w * 1.15, h * 0.44) // Extends past the right edge
      ..lineTo(w * 0.76, h * 0.46)
      ..close();
    canvas.drawPath(beakPath, beakPaint);

    // 7. Render Front Wing Layers (Geometric origami folded layers)
    // Wing Layer 1 (Darker Cyan Base)
    final frontWingPaint1 = Paint()..shader = frontWingShader2;
    final frontWingPath1 = Path()
      ..moveTo(w * 0.35, h * 0.45)
      ..lineTo(w * 0.12, h * 0.05)
      ..lineTo(w * 0.24, h * 0.08)
      ..lineTo(w * 0.42, h * 0.42)
      ..close();
    canvas.drawPath(frontWingPath1, frontWingPaint1);

    // Wing Layer 2 (Lighter Turquoise highlights)
    final frontWingPaint2 = Paint()..shader = frontWingShader1;
    final frontWingPath2 = Path()
      ..moveTo(w * 0.42, h * 0.42)
      ..lineTo(w * 0.24, h * 0.08)
      ..lineTo(w * 0.34, h * 0.12)
      ..lineTo(w * 0.48, h * 0.38)
      ..close();
    canvas.drawPath(frontWingPath2, frontWingPaint2);

    // Wing Highlight Facet (Small origami fold)
    final wingHighlightPaint = Paint()..color = const Color(0xFFE0F7FA).withAlpha(180);
    final wingHighlightPath = Path()
      ..moveTo(w * 0.48, h * 0.38)
      ..lineTo(w * 0.34, h * 0.12)
      ..lineTo(w * 0.4, h * 0.18)
      ..lineTo(w * 0.52, h * 0.35)
      ..close();
    canvas.drawPath(wingHighlightPath, wingHighlightPaint);

    // 8. Render Big Eye (Dash-style friendly circular eye)
    final eyeWhitePaint = Paint()..color = Colors.white;
    final eyeCenter = Offset(w * 0.65, h * 0.33);
    final eyeRadius = h * 0.13;
    canvas.drawCircle(eyeCenter, eyeRadius, eyeWhitePaint);

    // Pupil
    final eyePupilPaint = Paint()..color = Colors.black;
    final pupilCenter = Offset(w * 0.67, h * 0.33);
    final pupilRadius = h * 0.07;
    canvas.drawCircle(pupilCenter, pupilRadius, eyePupilPaint);

    // Reflection Dot
    final eyeReflectionPaint = Paint()..color = Colors.white;
    final reflectionCenter = Offset(w * 0.69, h * 0.31);
    final reflectionRadius = h * 0.025;
    canvas.drawCircle(reflectionCenter, reflectionRadius, eyeReflectionPaint);
  }
}
