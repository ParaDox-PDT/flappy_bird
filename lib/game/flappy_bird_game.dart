import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../domain/models/game_state.dart';
import 'components/bird.dart';

class FlappyBirdGame extends FlameGame with TapCallbacks {
  // ValueNotifier allows Flutter widgets to easily listen to state changes
  final ValueNotifier<GameState> gameState = ValueNotifier<GameState>(GameState.menu);

  late final Bird bird;

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

    // Reset bird physics state
    bird.reset();

    // Center camera's viewport horizontally with an offset so the bird is on the left
    camera.viewfinder.position = Vector2(bird.position.x + 120, 0);

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
    bird.reset();
    camera.viewfinder.position = Vector2(bird.position.x + 120, 0);
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

      // Check vertical boundaries (screen bounds in world coordinates)
      // Since camera viewfinder position Y is locked at 0, the visible vertical
      // range in the world coordinate space is [-size.y / 2, size.y / 2].
      // We check if the bird flies too high or falls below the bottom edge.
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
