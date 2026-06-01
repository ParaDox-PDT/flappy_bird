import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../domain/models/game_state.dart';
import '../domain/models/bird_skin.dart';
import '../data/datasources/local_storage.dart';
import 'components/bird.dart';
import 'components/pipe_pair.dart';

class FlappyBirdGame extends FlameGame with TapCallbacks, HasCollisionDetection {
  // ValueNotifier allows Flutter widgets to easily listen to state changes
  final ValueNotifier<GameState> gameState = ValueNotifier<GameState>(GameState.menu);
  
  // Real-time score notifier
  final ValueNotifier<int> score = ValueNotifier<int>(0);

  late final Bird bird;
  final LocalStorage _localStorage = LocalStorage();

  // Score & Spawner tracking variables
  int highScore = 0;
  int pipesSpawnedCount = 0; // Tracks the count of pipes generated in the current run
  double lastSpawnX = 0.0;
  double lastGapCenter = 0.0;
  static const double pipeSpacing = 350.0; // Distance between each pipe pair

  // Skin inventory variables
  String selectedSkinId = 'default';

  /// Resolves the currently active skin object
  BirdSkin get selectedSkin => BirdSkin.allSkins.firstWhere(
        (s) => s.id == selectedSkinId,
        orElse: () => BirdSkin.allSkins.first,
      );

  /// Returns the list of all skins currently unlocked by the player's high score
  List<BirdSkin> getUnlockedSkins() {
    return BirdSkin.allSkins.where((s) => highScore >= s.unlockScore).toList();
  }

  /// Sets and persists a new skin selection if it has been unlocked
  Future<void> changeSkin(String skinId) async {
    final skin = BirdSkin.allSkins.firstWhere((s) => s.id == skinId, orElse: () => BirdSkin.allSkins.first);
    if (highScore >= skin.unlockScore) {
      selectedSkinId = skinId;
      await _localStorage.saveSelectedSkinId(skinId);
    }
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // Load persisted high score and skin selection from shared_preferences
    highScore = await _localStorage.getHighScore();
    selectedSkinId = await _localStorage.getSelectedSkinId();

    // Instantiate and add the bird to the game world.
    bird = Bird();
    world.add(bird);

    // Initially pause the engine until the player clicks "PLAY NOW"
    pauseEngine();
  }

  /// Starts or restarts the gameplay session
  void startGame() {
    gameState.value = GameState.playing;
    
    // Clear menu and game over overlays, display HUD
    overlays.remove('MainMenu');
    overlays.remove('GameOver');
    overlays.add('Hud');

    // Remove any pipes remaining from the previous run
    world.children.whereType<PipePair>().forEach((p) => p.removeFromParent());

    // Reset bird physics state
    bird.reset();

    // Center camera's viewport horizontally with an offset so the bird is on the left
    camera.viewfinder.position = Vector2(bird.position.x + 120, 0);

    // Reset spawning parameters & scores
    score.value = 0;
    pipesSpawnedCount = 0;
    lastGapCenter = 0.0;
    
    lastSpawnX = bird.position.x + 400.0;
    pipesSpawnedCount++;

    // First pipe pair: check if it matches high score record to color it gold
    final isGolden = highScore > 0 && pipesSpawnedCount == highScore;
    final firstPipe = PipePair(
      x: lastSpawnX,
      prevGapCenter: lastGapCenter,
      screenHeight: size.y,
      isGolden: isGolden,
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
    
    // Remove HUD and display Game Over screen
    overlays.remove('Hud');
    overlays.add('GameOver');
    
    pauseEngine();

    // Verify if player reached a new High Score record
    if (score.value > highScore) {
      highScore = score.value;
      _localStorage.saveHighScore(highScore);
    }
  }

  /// Returns back to main menu
  void resetGame() {
    gameState.value = GameState.menu;
    overlays.remove('GameOver');
    overlays.remove('Hud');
    overlays.add('MainMenu');
    
    // Clean up active obstacles
    world.children.whereType<PipePair>().forEach((p) => p.removeFromParent());
    bird.reset();
    camera.viewfinder.position = Vector2(bird.position.x + 120, 0);
    lastGapCenter = 0.0;
    score.value = 0;
    pipesSpawnedCount = 0;
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
        pipesSpawnedCount++;

        // Determine if this spawned pipe corresponds to the current High Score record
        final isGolden = highScore > 0 && pipesSpawnedCount == highScore;
        
        final newPipe = PipePair(
          x: lastSpawnX,
          prevGapCenter: lastGapCenter,
          screenHeight: size.y,
          isGolden: isGolden,
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
