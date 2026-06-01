import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../../game/flappy_bird_game.dart';
import '../overlays/main_menu_overlay.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  // Instance of the Flame Game loop
  late final FlappyBirdGame _game;

  @override
  void initState() {
    super.initState();
    _game = FlappyBirdGame();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget<FlappyBirdGame>(
        game: _game,
        overlayBuilderMap: {
          'MainMenu': (context, game) => MainMenuOverlay(game: game),
          // Additional overlays (e.g. GameOver, Hud) will be mapped here
        },
        // MainMenu starts as visible on loading the game screen
        initialActiveOverlays: const ['MainMenu'],
      ),
    );
  }
}
