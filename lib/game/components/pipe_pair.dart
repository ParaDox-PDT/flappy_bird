import 'dart:math';
import 'package:flame/components.dart';
import '../flappy_bird_game.dart';
import '../../domain/models/game_state.dart';
import 'pipe.dart';

class PipePair extends PositionComponent with HasGameReference<FlappyBirdGame> {
  final double gapHeight;
  final double gapCenter;
  final double screenHeight;
  final bool isGolden; // Highlights this pipe pair if it matches the current high score
  bool isPassed = false; // Tracks if the bird has cleared this obstacle

  PipePair({
    required double x,
    required double prevGapCenter,
    required this.screenHeight,
    required this.isGolden,
    this.gapHeight = 150.0, // Vertically spaced gap for the bird to fly through
  })  : gapCenter = _calculateGapCenter(prevGapCenter, screenHeight),
        super(position: Vector2(x, 0));

  static double _calculateGapCenter(double prev, double screenHeight) {
    final halfHeight = screenHeight / 2;
    final topBound = -halfHeight;
    final bottomBound = halfHeight;

    final random = Random();
    // Constrain the deviation between consecutive pipes to 100 pixels vertically
    // This ensures the next gap is comfortably reachable by the bird's physics
    const maxVerticalDev = 100.0;
    
    double minCenter = prev - maxVerticalDev;
    double maxCenter = prev + maxVerticalDev;

    // Safety margins from screen edges
    final absoluteMin = topBound + 120.0;
    final absoluteMax = bottomBound - 120.0;

    minCenter = minCenter.clamp(absoluteMin, absoluteMax);
    maxCenter = maxCenter.clamp(absoluteMin, absoluteMax);

    return minCenter + random.nextDouble() * (maxCenter - minCenter);
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();

    final halfHeight = screenHeight / 2;
    final topBound = -halfHeight;
    final bottomBound = halfHeight;

    // Calculate vertical size of top and bottom pipes
    final topPipeHeight = (gapCenter - gapHeight / 2) - topBound;
    final bottomPipeHeight = bottomBound - (gapCenter + gapHeight / 2);

    final pipeWidth = 64.0; // Standard pipe width

    final pipeSprites = isGolden ? game.goldenObstacle : game.normalObstacle;

    // Top Pipe
    add(Pipe(
      sprites: pipeSprites,
      position: Vector2(0, topBound),
      size: Vector2(pipeWidth, topPipeHeight),
      isTop: true,
    ));

    // Bottom Pipe
    add(Pipe(
      sprites: pipeSprites,
      position: Vector2(0, gapCenter + gapHeight / 2),
      size: Vector2(pipeWidth, bottomPipeHeight),
      isTop: false,
    ));
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Score passing check:
    // When the bird's X coordinate crosses past the middle of this pipe, increment score
    if (!isPassed && game.gameState.value == GameState.playing) {
      if (game.bird.position.x > position.x + 32.0) {
        isPassed = true;
        game.score.value++;
      }
    }

    // Automatically remove from the game loop once the pipe pair moves off the left side of the screen
    final cameraX = game.camera.viewfinder.position.x;
    final screenWidth = game.size.x;

    if (position.x < cameraX - screenWidth / 2 - 100) {
      removeFromParent();
    }
  }
}
