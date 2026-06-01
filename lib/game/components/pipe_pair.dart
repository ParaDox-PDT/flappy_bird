import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../flappy_bird_game.dart';
import 'pipe.dart';

class PipePair extends PositionComponent with HasGameReference<FlappyBirdGame> {
  final double gapHeight;

  PipePair({
    required double x,
    this.gapHeight = 150.0, // Vertically spaced gap for the bird to fly through
  }) : super(position: Vector2(x, 0));

  @override
  Future<void> onLoad() async {
    super.onLoad();

    final screenHeight = game.size.y;
    final halfHeight = screenHeight / 2;
    final topBound = -halfHeight;
    final bottomBound = halfHeight;

    // Randomize the center coordinate of the gap
    // Ensuring it remains within a safe area (at least 120 pixels from edges)
    final random = Random();
    final minGapCenter = topBound + 120.0;
    final maxGapCenter = bottomBound - 120.0;
    final gapCenter = minGapCenter + random.nextDouble() * (maxGapCenter - minGapCenter);

    // Calculate vertical size of top and bottom pipes
    final topPipeHeight = (gapCenter - gapHeight / 2) - topBound;
    final bottomPipeHeight = bottomBound - (gapCenter + gapHeight / 2);

    final pipeWidth = 64.0; // Standard pipe width

    // Top Pipe
    add(Pipe(
      position: Vector2(0, topBound),
      size: Vector2(pipeWidth, topPipeHeight),
      color: const Color(0xFF2E7D32), // Vibrant Dark Green
    ));

    // Bottom Pipe
    add(Pipe(
      position: Vector2(0, gapCenter + gapHeight / 2),
      size: Vector2(pipeWidth, bottomPipeHeight),
      color: const Color(0xFF2E7D32),
    ));
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Automatically remove from the game loop once the pipe pair moves off the left side of the screen
    final cameraX = game.camera.viewfinder.position.x;
    final screenWidth = game.size.x;

    if (position.x < cameraX - screenWidth / 2 - 100) {
      removeFromParent();
    }
  }
}
