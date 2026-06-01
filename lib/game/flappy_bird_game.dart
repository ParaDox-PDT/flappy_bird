import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../domain/models/game_state.dart';

class FlappyBirdGame extends FlameGame {
  // ValueNotifier allows Flutter widgets to easily listen to state changes
  final ValueNotifier<GameState> gameState = ValueNotifier<GameState>(GameState.menu);

  @override
  Future<void> onLoad() async {
    super.onLoad();
    // Assets, background, and components will be loaded here later
  }

  /// Starts the gameplay session
  void startGame() {
    gameState.value = GameState.playing;
    overlays.remove('MainMenu');
    // Start physics, scrolling, spawning bird, etc.
    resumeEngine();
  }

  /// Ends the current gameplay session
  void gameOver() {
    gameState.value = GameState.gameOver;
    pauseEngine();
    // overlays.add('GameOver'); // Will be added later
  }

  /// Returns back to main menu
  void resetGame() {
    gameState.value = GameState.menu;
    overlays.add('MainMenu');
    // overlays.remove('GameOver'); // Will be added later
    pauseEngine();
  }
}
