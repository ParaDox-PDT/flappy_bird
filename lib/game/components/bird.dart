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
    size: Vector2(52, 42), // Bounding box for Dash mascot
    anchor: Anchor.center,
  );

  @override
  Future<void> onLoad() async {
    super.onLoad();
    // Add a smaller hitbox that only covers the core body of the bird,
    // leaving margins for wings and beak to make collisions feel fair and realistic.
    add(RectangleHitbox(
      size: Vector2(36, 24),
      position: Vector2(8, 9),
    ));
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

    // Retrieve active skin configuration from the game controller
    final skin = game.selectedSkin;
    final colors = skin.colors;
    final isSpecial = skin.isSpecial;

    // Map customization colors
    final bodyPrimary = colors[0];
    final bodySecondary = colors[1];
    final bellyPrimary = colors[2];
    final bellySecondary = colors[3];
    final wingPrimary = colors[4];
    final wingSecondary = colors[5];

    // Shaders & Gradients configuration based on dynamic skin colors
    final backWingShader = LinearGradient(
      colors: [bodyPrimary, wingSecondary],
      begin: Alignment.bottomRight,
      end: Alignment.topLeft,
    ).createShader(Rect.fromLTWH(0, 0, w, h));

    final tailShader = LinearGradient(
      colors: [bodyPrimary, wingPrimary],
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
    ).createShader(Rect.fromLTWH(0, 0, w, h));

    final bodyShader = LinearGradient(
      colors: [bodyPrimary, bodySecondary],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).createShader(Rect.fromLTWH(0, 0, w, h));

    final bellyShader = LinearGradient(
      colors: [bellyPrimary, bellySecondary],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ).createShader(Rect.fromLTWH(0, 0, w, h));

    final frontWingShader1 = LinearGradient(
      colors: [wingPrimary, wingSecondary],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ).createShader(Rect.fromLTWH(0, 0, w, h));

    final frontWingShader2 = LinearGradient(
      colors: [bodySecondary, wingPrimary],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).createShader(Rect.fromLTWH(0, 0, w, h));

    final beakShader = LinearGradient(
      colors: [
        const Color(0xFFFFD54F), // Bright Yellow
        const Color(0xFFFF8F00), // Orange
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).createShader(Rect.fromLTWH(w * 0.75, h * 0.35, w * 0.4, h * 0.2));

    // 1. Render Back Wing (placed behind body)
    final backWingPaint = Paint()..shader = backWingShader;
    final backWingPath = Path()
      ..moveTo(w * 0.32, h * 0.35)
      ..lineTo(w * 0.08, h * -0.05)
      ..lineTo(w * 0.22, h * -0.02)
      ..lineTo(w * 0.38, h * 0.32)
      ..close();
    canvas.drawPath(backWingPath, backWingPaint);

    // 2. Render Tail (placed behind body)
    final tailPaint = Paint()..shader = tailShader;
    final tailPath = Path()
      ..moveTo(w * 0.15, h * 0.5)
      ..lineTo(w * -0.15, h * 0.58)
      ..lineTo(w * -0.08, h * 0.72)
      ..lineTo(w * 0.25, h * 0.62)
      ..close();
    canvas.drawPath(tailPath, tailPaint);

    // 3. Render Main Body (Geometric Core)
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

    // 4. Render Belly and Chest (Geometric Accent)
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

    // 5. Render Beak (long hummingbird-style beak)
    final beakPaint = Paint()..shader = beakShader;
    final beakPath = Path()
      ..moveTo(w * 0.76, h * 0.36)
      ..lineTo(w * 1.15, h * 0.44) // Extends past the right edge
      ..lineTo(w * 0.76, h * 0.46)
      ..close();
    canvas.drawPath(beakPath, beakPaint);

    // 6. Render Front Wing Layers (Geometric origami folded layers)
    // Wing Layer 1 (Darker Base)
    final frontWingPaint1 = Paint()..shader = frontWingShader2;
    final frontWingPath1 = Path()
      ..moveTo(w * 0.35, h * 0.45)
      ..lineTo(w * 0.12, h * 0.05)
      ..lineTo(w * 0.24, h * 0.08)
      ..lineTo(w * 0.42, h * 0.42)
      ..close();
    canvas.drawPath(frontWingPath1, frontWingPaint1);

    // Wing Layer 2 (Lighter highlights)
    final frontWingPaint2 = Paint()..shader = frontWingShader1;
    final frontWingPath2 = Path()
      ..moveTo(w * 0.42, h * 0.42)
      ..lineTo(w * 0.24, h * 0.08)
      ..lineTo(w * 0.34, h * 0.12)
      ..lineTo(w * 0.48, h * 0.38)
      ..close();
    canvas.drawPath(frontWingPath2, frontWingPaint2);

    // Wing Highlight Facet (Small origami fold with extra shine for special skins)
    final wingHighlightPaint = Paint()
      ..color = isSpecial
          ? const Color(0xFFFFFFFF).withAlpha(190) // Extra bright white shine
          : bellyPrimary.withAlpha(120); // standard theme color highlight

    final wingHighlightPath = Path()
      ..moveTo(w * 0.48, h * 0.38)
      ..lineTo(w * 0.34, h * 0.12)
      ..lineTo(w * 0.4, h * 0.18)
      ..lineTo(w * 0.52, h * 0.35)
      ..close();
    canvas.drawPath(wingHighlightPath, wingHighlightPaint);

    // 7. Render Big Eye (Dash-style friendly circular eye)
    final eyeWhitePaint = Paint()..color = Colors.white;
    final eyeCenter = Offset(w * 0.65, h * 0.33);
    final eyeRadius = h * 0.13;
    canvas.drawCircle(eyeCenter, eyeRadius, eyeWhitePaint);

    // Glowing Aura around the eye for Special Skins
    if (isSpecial) {
      final glowPaint = Paint()
        ..color = const Color(0xFFFFD700).withAlpha(140) // Golden glow
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawCircle(eyeCenter, eyeRadius + 1.5, glowPaint);
    }

    // Pupil
    final eyePupilPaint = Paint()..color = Colors.black;
    final pupilCenter = Offset(w * 0.67, h * 0.33);
    final pupilRadius = h * 0.07;
    canvas.drawCircle(pupilCenter, pupilRadius, eyePupilPaint);

    // Reflection Dot or Sparkling Star for Special Skins
    if (isSpecial) {
      // Draw cross/star reflection in pupil
      final starPaint = Paint()..color = Colors.white;
      final starPath = Path()
        ..moveTo(pupilCenter.dx, pupilCenter.dy - 3)
        ..lineTo(pupilCenter.dx + 0.8, pupilCenter.dy - 0.8)
        ..lineTo(pupilCenter.dx + 3, pupilCenter.dy)
        ..lineTo(pupilCenter.dx + 0.8, pupilCenter.dy + 0.8)
        ..lineTo(pupilCenter.dx, pupilCenter.dy + 3)
        ..lineTo(pupilCenter.dx - 0.8, pupilCenter.dy + 0.8)
        ..lineTo(pupilCenter.dx - 3, pupilCenter.dy)
        ..lineTo(pupilCenter.dx - 0.8, pupilCenter.dy - 0.8)
        ..close();
      canvas.drawPath(starPath, starPaint);
    } else {
      // Normal reflection dot
      final eyeReflectionPaint = Paint()..color = Colors.white;
      final reflectionCenter = Offset(w * 0.69, h * 0.31);
      final reflectionRadius = h * 0.025;
      canvas.drawCircle(reflectionCenter, reflectionRadius, eyeReflectionPaint);
    }

    // 8. Render Special Headwear (tiny royal golden crown for special skins)
    if (isSpecial) {
      final crownPaint = Paint()..color = const Color(0xFFFFD700);
      final crownPath = Path()
        ..moveTo(w * 0.50, h * 0.22) // Left base
        ..lineTo(w * 0.44, h * 0.08) // Left peak
        ..lineTo(w * 0.54, h * 0.14) // Left valley
        ..lineTo(w * 0.60, h * 0.04) // Center peak
        ..lineTo(w * 0.66, h * 0.14) // Right valley
        ..lineTo(w * 0.76, h * 0.08) // Right peak
        ..lineTo(w * 0.70, h * 0.22) // Right base
        ..close();
      canvas.drawPath(crownPath, crownPaint);

      // Ruby gemstone on center crown peak
      final gemPaint = Paint()..color = const Color(0xFFFF1744);
      canvas.drawCircle(Offset(w * 0.60, h * 0.04), h * 0.04, gemPaint);
    }
  }
}
