import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../game/flappy_bird_game.dart';

class HudOverlay extends StatelessWidget {
  final FlappyBirdGame game;

  const HudOverlay({
    super.key,
    required this.game,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 24.0),
            child: ValueListenableBuilder<int>(
              valueListenable: game.score,
              builder: (context, score, child) {
                return Text(
                  '$score',
                  style: GoogleFonts.outfit(
                    fontSize: 56,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 8.0,
                        color: Colors.cyanAccent.withAlpha(150),
                        offset: Offset.zero,
                      ),
                      Shadow(
                        blurRadius: 15.0,
                        color: Colors.black.withAlpha(200),
                        offset: const Offset(2, 2),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
