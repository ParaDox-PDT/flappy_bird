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
    // In Flame 1.x, components placed inside 'world' are viewed by the camera.
    bird = Bird();
    world.add(bird);

    // Initially pause the engine until the player clicks "PLAY NOW"
    pauseEngine();
  }

  /// Starts the gameplay session
  void startGame() {
    gameState.value = GameState.playing;
    overlays.remove('MainMenu');

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
    pauseEngine();
    // overlays.add('GameOver'); // Will be added later
  }

  /// Returns back to main menu
  void resetGame() {
    gameState.value = GameState.menu;
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
      // This keeps the bird positioned on the left side of the screen.
      // Locking Y to 0 allows the bird to move vertically within the camera's viewport.
      camera.viewfinder.position = Vector2(bird.position.x + 120, 0);
    }
  }
}
