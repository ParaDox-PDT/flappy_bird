import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../domain/models/game_state.dart';
import 'components/bird.dart';
import 'components/pipe_pair.dart';

class FlappyBirdGame extends FlameGame with TapCallbacks, HasCollisionDetection {
  // ValueNotifier allows Flutter widgets to easily listen to state changes
  final ValueNotifier<GameState> gameState = ValueNotifier<GameState>(GameState.menu);

  late final Bird bird;

  // Spawner tracking variables
  double lastSpawnX = 0.0;
  double lastGapCenter = 0.0;
  static const double pipeSpacing = 350.0; // Distance between each pipe pair (extended for playability)

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // Instantiate and add the bird to the game world.
    bird = Bird();
    world.add(bird);

    // Initially pause the engine until the player clicks "PLAY NOW"
    pauseEngine();
  }

  /// Starts or restarts the gameplay session
  void startGame() {
    gameState.value = GameState.playing;
    
    // Clear menu and game over overlays
    overlays.remove('MainMenu');
    overlays.remove('GameOver');

    // Remove any pipes remaining from the previous run
    world.children.whereType<PipePair>().forEach((p) => p.removeFromParent());

    // Reset bird physics state
    bird.reset();

    // Center camera's viewport horizontally with an offset so the bird is on the left
    camera.viewfinder.position = Vector2(bird.position.x + 120, 0);

    // Reset spawning parameters
    lastGapCenter = 0.0; // Start at vertical center
    lastSpawnX = bird.position.x + 400.0;
    
    final firstPipe = PipePair(
      x: lastSpawnX,
      prevGapCenter: lastGapCenter,
      screenHeight: size.y,
    );
    world.add(firstPipe);
    lastGapCenter = firstPipe.gapCenter;

    // Resume the game loop
    resumeEngine();
  }

  /// Ends the current gameplay session
  void gameOver() {
    gameState.value = GameState.gameOver;
    bird.isDead = true;
    overlays.add('GameOver');
    pauseEngine();
  }

  /// Returns back to main menu
  void resetGame() {
    gameState.value = GameState.menu;
    overlays.remove('GameOver');
    overlays.add('MainMenu');
    
    // Clean up active obstacles
    world.children.whereType<PipePair>().forEach((p) => p.removeFromParent());
    bird.reset();
    camera.viewfinder.position = Vector2(bird.position.x + 120, 0);
    lastGapCenter = 0.0;
    pauseEngine();
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    // When the screen is tapped, trigger the bird's jump
    if (gameState.value == GameState.playing) {
      bird.jump();
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (gameState.value == GameState.playing) {
      // Camera viewfinder follows bird's X position with a fixed offset (+120)
      camera.viewfinder.position = Vector2(bird.position.x + 120, 0);

      // Procedural Obstacle Spawning
      // We calculate the right edge of the screen in world coordinates.
      // If the camera is getting close to the last spawned pipe, spawn another one.
      final cameraX = camera.viewfinder.position.x;
      final rightEdge = cameraX + size.x / 2;

      // Spawn buffer: 200 pixels before the pipe actually enters the viewport from the right
      if (rightEdge + 200 > lastSpawnX) {
        lastSpawnX += pipeSpacing;
        final newPipe = PipePair(
          x: lastSpawnX,
          prevGapCenter: lastGapCenter,
          screenHeight: size.y,
        );
        world.add(newPipe);
        lastGapCenter = newPipe.gapCenter;
      }

      // Check vertical boundaries (screen bounds in world coordinates)
      final topLimit = -size.y / 2;
      final bottomLimit = size.y / 2;

      // Add small buffer so the bird fully exits the view before triggering Game Over
      if (bird.position.y < topLimit - bird.size.y || 
          bird.position.y > bottomLimit + bird.size.y) {
        gameOver();
      }
    }
  }
}
