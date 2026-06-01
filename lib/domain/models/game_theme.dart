import 'package:flame/components.dart';

class GameTheme {
  final String id;
  final String name;
  final String backgroundImage;
  final String obstacleImage;
  final int unlockScore;
  
  // Obstacle coordinate configuration for 3-slice rendering
  final Vector2 topEndPos;
  final Vector2 topEndSize;
  final Vector2 shaftPos;
  final Vector2 shaftSize;
  final Vector2 bottomEndPos;
  final Vector2 bottomEndSize;
  final double topEndHeight;
  final double bottomEndHeight;

  const GameTheme({
    required this.id,
    required this.name,
    required this.backgroundImage,
    required this.obstacleImage,
    required this.unlockScore,
    required this.topEndPos,
    required this.topEndSize,
    required this.shaftPos,
    required this.shaftSize,
    required this.bottomEndPos,
    required this.bottomEndSize,
    required this.topEndHeight,
    required this.bottomEndHeight,
  });

  /// Predefined game themes
  static final List<GameTheme> allThemes = [
    GameTheme(
      id: 'theme_1',
      name: 'Classic Green',
      backgroundImage: 'background_1.png',
      obstacleImage: 'obstacle_1.png',
      unlockScore: 0,
      topEndPos: Vector2(619, 149),
      topEndSize: Vector2(300, 150),
      shaftPos: Vector2(642, 299),
      shaftSize: Vector2(252, 390),
      bottomEndPos: Vector2(630, 689),
      bottomEndSize: Vector2(276, 200),
      topEndHeight: 32.0,
      bottomEndHeight: 46.0,
    ),
    GameTheme(
      id: 'theme_2',
      name: 'Golden Autumn',
      backgroundImage: 'background_2.png',
      obstacleImage: 'obstacle_2.png',
      unlockScore: 10,
      topEndPos: Vector2(334, 179),
      topEndSize: Vector2(356, 165),
      shaftPos: Vector2(356, 344),
      shaftSize: Vector2(312, 720),
      bottomEndPos: Vector2(341, 1064),
      bottomEndSize: Vector2(342, 235),
      topEndHeight: 30.0,
      bottomEndHeight: 44.0,
    ),
    GameTheme(
      id: 'theme_3',
      name: 'Night Oasis',
      backgroundImage: 'background_3.png',
      obstacleImage: 'obstacle_3.png',
      unlockScore: 20,
      topEndPos: Vector2(332, 178),
      topEndSize: Vector2(360, 165),
      shaftPos: Vector2(363, 343),
      shaftSize: Vector2(297, 705),
      bottomEndPos: Vector2(346, 1048),
      bottomEndSize: Vector2(332, 219),
      topEndHeight: 29.0,
      bottomEndHeight: 42.0,
    ),
  ];
}
