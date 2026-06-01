import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/material.dart';
import '../domain/models/game_state.dart';
import '../domain/models/bird_skin.dart';
import '../domain/models/game_theme.dart';
import '../data/datasources/local_storage.dart';
import 'components/bird.dart';
import 'components/pipe_pair.dart';

class ObstacleSprites {
  final Sprite topEnd;
  final Sprite shaft;
  final Sprite bottomEnd;
  final double topEndHeight;
  final double bottomEndHeight;

  ObstacleSprites({
    required this.topEnd,
    required this.shaft,
    required this.bottomEnd,
    required this.topEndHeight,
    required this.bottomEndHeight,
  });
}

class FlappyBirdGame extends FlameGame with TapCallbacks, HasCollisionDetection {
  // ValueNotifier allows Flutter widgets to easily listen to state changes
  final ValueNotifier<GameState> gameState = ValueNotifier<GameState>(GameState.menu);
  
  // Real-time score notifier
  final ValueNotifier<int> score = ValueNotifier<int>(0);

  late final Bird bird;
  late ObstacleSprites normalObstacle;
  late final ObstacleSprites goldenObstacle;
  late ParallaxComponent background;
  final LocalStorage _localStorage = LocalStorage();

  // Score & Spawner tracking variables
  int highScore = 0;
  int pipesSpawnedCount = 0; // Tracks the count of pipes generated in the current run
  double lastSpawnX = 0.0;
  double lastGapCenter = 0.0;
  static const double pipeSpacing = 350.0; // Distance between each pipe pair
  static const double virtualHeight = 844.0;

  // Skin & Theme inventory variables
  String selectedSkinId = 'default';
  String selectedThemeId = 'theme_1';

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

  /// Resolves the currently active theme object
  GameTheme get selectedTheme => GameTheme.allThemes.firstWhere(
        (t) => t.id == selectedThemeId,
        orElse: () => GameTheme.allThemes.first,
      );

  /// Returns the list of all themes currently unlocked by the player's high score
  List<GameTheme> getUnlockedThemes() {
    return GameTheme.allThemes.where((t) => highScore >= t.unlockScore).toList();
  }

  /// Sets, persists, and dynamically reloads a new theme selection
  Future<void> changeTheme(String themeId) async {
    final theme = GameTheme.allThemes.firstWhere((t) => t.id == themeId, orElse: () => GameTheme.allThemes.first);
    if (highScore >= theme.unlockScore) {
      selectedThemeId = themeId;
      await _localStorage.saveSelectedThemeId(themeId);
      
      // Reload obstacle sprites for the new theme
      normalObstacle = ObstacleSprites(
        topEnd: await loadSprite(theme.obstacleImage, srcPosition: theme.topEndPos, srcSize: theme.topEndSize),
        shaft: await loadSprite(theme.obstacleImage, srcPosition: theme.shaftPos, srcSize: theme.shaftSize),
        bottomEnd: await loadSprite(theme.obstacleImage, srcPosition: theme.bottomEndPos, srcSize: theme.bottomEndSize),
        topEndHeight: theme.topEndHeight,
        bottomEndHeight: theme.bottomEndHeight,
      );

      // Recreate the parallax background
      background.removeFromParent();
      background = await loadParallaxComponent(
        [
          ParallaxImageData(theme.backgroundImage),
        ],
        baseVelocity: Vector2(10.0, 0),
        repeat: ImageRepeat.repeatX,
      );
      camera.backdrop.add(background);
    }
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // Load persisted high score, skin and theme selection from shared_preferences
    highScore = await _localStorage.getHighScore();
    selectedSkinId = await _localStorage.getSelectedSkinId();
    selectedThemeId = await _localStorage.getSelectedThemeId();

    final theme = selectedTheme;

    // Load normal obstacle slices (aspect-ratio preserved heights for 64px width) based on selected theme
    normalObstacle = ObstacleSprites(
      topEnd: await loadSprite(theme.obstacleImage, srcPosition: theme.topEndPos, srcSize: theme.topEndSize),
      shaft: await loadSprite(theme.obstacleImage, srcPosition: theme.shaftPos, srcSize: theme.shaftSize),
      bottomEnd: await loadSprite(theme.obstacleImage, srcPosition: theme.bottomEndPos, srcSize: theme.bottomEndSize),
      topEndHeight: theme.topEndHeight,
      bottomEndHeight: theme.bottomEndHeight,
    );

    // Load golden obstacle slices (always use golden_obstacle_1)
    goldenObstacle = ObstacleSprites(
      topEnd: await loadSprite('golden_obstacle_1.png', srcPosition: Vector2(276, 128), srcSize: Vector2(472, 210)),
      shaft: await loadSprite('golden_obstacle_1.png', srcPosition: Vector2(304, 338), srcSize: Vector2(416, 830)),
      bottomEnd: await loadSprite('golden_obstacle_1.png', srcPosition: Vector2(282, 1168), srcSize: Vector2(460, 290)),
      topEndHeight: 29.0, // 64 * (210/472)
      bottomEndHeight: 40.0, // 64 * (290/460)
    );

    // Add parallax background to camera backdrop
    background = await loadParallaxComponent(
      [
        ParallaxImageData(theme.backgroundImage),
      ],
      baseVelocity: Vector2(10.0, 0),
      repeat: ImageRepeat.repeatX,
    );
    camera.backdrop.add(background);

    // Instantiate and add the bird to the game world.
    bird = Bird();
    world.add(bird);

    // Start the game session immediately upon loading
    startGame();
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
      screenHeight: virtualHeight,
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
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    // Ensure the game height in world coordinates is always 844
    camera.viewfinder.zoom = size.y / virtualHeight;
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Update background parallax velocity based on game state
    if (gameState.value == GameState.playing) {
      background.parallax?.baseVelocity = Vector2(48.0, 0);
    } else if (gameState.value == GameState.gameOver) {
      background.parallax?.baseVelocity = Vector2.zero();
    } else {
      background.parallax?.baseVelocity = Vector2(10.0, 0);
    }

    if (gameState.value == GameState.playing) {
      // Camera viewfinder follows bird's X position with a fixed offset (+120)
      camera.viewfinder.position = Vector2(bird.position.x + 120, 0);

      // Procedural Obstacle Spawning
      // We calculate the right edge of the screen in world coordinates.
      // If the camera is getting close to the last spawned pipe, spawn another one.
      final cameraX = camera.viewfinder.position.x;
      final visibleWidth = size.x / camera.viewfinder.zoom;
      final rightEdge = cameraX + visibleWidth / 2;

      // Spawn buffer: 200 pixels before the pipe actually enters the viewport from the right
      if (rightEdge + 200 > lastSpawnX) {
        lastSpawnX += pipeSpacing;
        pipesSpawnedCount++;

        // Determine if this spawned pipe corresponds to the current High Score record
        final isGolden = highScore > 0 && pipesSpawnedCount == highScore;
        
        final newPipe = PipePair(
          x: lastSpawnX,
          prevGapCenter: lastGapCenter,
          screenHeight: virtualHeight,
          isGolden: isGolden,
        );
        world.add(newPipe);
        lastGapCenter = newPipe.gapCenter;
      }

      // Check vertical boundaries (screen bounds in world coordinates)
      final topLimit = -virtualHeight / 2;
      final bottomLimit = virtualHeight / 2;

      // Add small buffer so the bird fully exits the view before triggering Game Over
      if (bird.position.y < topLimit - bird.size.y || 
          bird.position.y > bottomLimit + bird.size.y) {
        gameOver();
      }
    }
  }
}
