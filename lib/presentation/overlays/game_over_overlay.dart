import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../game/flappy_bird_game.dart';

class GameOverOverlay extends StatelessWidget {
  final FlappyBirdGame game;

  const GameOverOverlay({
    super.key,
    required this.game,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withAlpha(160), // Darker overlay for game over
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Game Over Glowing Text
                  Text(
                    'GAME OVER',
                    style: GoogleFonts.outfit(
                      fontSize: 54,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 4.0,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          blurRadius: 15.0,
                          color: Colors.redAccent.withAlpha(200),
                          offset: const Offset(0, 0),
                        ),
                        Shadow(
                          blurRadius: 30.0,
                          color: Colors.deepOrangeAccent.withAlpha(150),
                          offset: const Offset(0, 0),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Encouraging message
                  Text(
                    'Your wings clipped. Try again!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withAlpha(180),
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 48),
                  // Restart Button
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.redAccent.withAlpha(76),
                            blurRadius: 20,
                            spreadRadius: 2,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: game.startGame, // Restarts the game instantly
                            splashColor: Colors.white.withAlpha(76),
                            highlightColor: Colors.white.withAlpha(26),
                            child: Ink(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFFFF1744), // Crimson Red
                                    Color(0xFFFF9100), // Orange
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 56,
                                  vertical: 18,
                                ),
                                child: Text(
                                  'RESTART',
                                  style: GoogleFonts.outfit(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2.0,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
