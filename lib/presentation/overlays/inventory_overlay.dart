import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../game/flappy_bird_game.dart';
import '../../domain/models/bird_skin.dart';

class InventoryOverlay extends StatefulWidget {
  final FlappyBirdGame game;

  const InventoryOverlay({
    super.key,
    required this.game,
  });

  @override
  State<InventoryOverlay> createState() => _InventoryOverlayState();
}

class _InventoryOverlayState extends State<InventoryOverlay> {
  late String _currentSelectedId;

  @override
  void initState() {
    super.initState();
    _currentSelectedId = widget.game.selectedSkinId;
  }

  void _selectSkin(BirdSkin skin) async {
    // Only select if it is unlocked
    if (widget.game.highScore >= skin.unlockScore) {
      await widget.game.changeSkin(skin.id);
      setState(() {
        _currentSelectedId = skin.id;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final highScore = widget.game.highScore;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withAlpha(180),
          ),
          child: Column(
            children: [
              // Header Section
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'INVENTORY',
                            style: GoogleFonts.outfit(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2.0,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  blurRadius: 10.0,
                                  color: Colors.cyanAccent.withAlpha(120),
                                  offset: Offset.zero,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Your Best Score: $highScore pts',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withAlpha(150),
                            ),
                          ),
                        ],
                      ),
                      // Back Button
                      IconButton(
                        onPressed: () {
                          widget.game.overlays.remove('Inventory');
                          widget.game.overlays.add('MainMenu');
                        },
                        icon: const Icon(Icons.close, color: Colors.white, size: 28),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(color: Colors.white24, height: 1),
              // Skins Grid
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(20.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: BirdSkin.allSkins.length,
                  itemBuilder: (context, index) {
                    final skin = BirdSkin.allSkins[index];
                    final isUnlocked = highScore >= skin.unlockScore;
                    final isActive = _currentSelectedId == skin.id;

                    // Shaders for preview
                    final bodyGradient = LinearGradient(
                      colors: [skin.colors[0], skin.colors[1]],
                    );
                    final bellyGradient = LinearGradient(
                      colors: [skin.colors[2], skin.colors[3]],
                    );

                    return GestureDetector(
                      onTap: isUnlocked ? () => _selectSkin(skin) : null,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(isUnlocked ? 15 : 5),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isActive
                                ? const Color(0xFFFFD700) // Gold border for active skin
                                : (isUnlocked ? Colors.white30 : Colors.white10),
                            width: isActive ? 2.5 : 1.0,
                          ),
                          boxShadow: isActive
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFFFFD700).withAlpha(80),
                                    blurRadius: 15,
                                    spreadRadius: 1,
                                  )
                                ]
                              : null,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Lock Icon overlay / Color preview
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Color Preview Circles (Concentric)
                                  Container(
                                    width: 64,
                                    height: 64,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: bodyGradient,
                                      boxShadow: [
                                        BoxShadow(
                                          color: skin.colors[1].withAlpha(100),
                                          blurRadius: 10,
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: bellyGradient,
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Lock Mask if Locked
                                  if (!isUnlocked)
                                    Container(
                                      width: 64,
                                      height: 64,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.black.withAlpha(160),
                                      ),
                                      child: const Icon(
                                        Icons.lock_outline,
                                        color: Colors.white70,
                                        size: 28,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // Skin Name
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text(
                                  skin.name,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.outfit(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isUnlocked ? Colors.white : Colors.white54,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              // Unlock Description or Button
                              if (!isUnlocked)
                                Text(
                                  'Requires ${skin.unlockScore} pts',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: Colors.redAccent.shade100,
                                    fontWeight: FontWeight.w600,
                                  ),
                                )
                              else
                                Container(
                                  margin: const EdgeInsets.only(top: 6),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isActive
                                        ? const Color(0xFFFFD700).withAlpha(40)
                                        : Colors.white12,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    isActive ? 'ACTIVE' : 'SELECT',
                                    style: GoogleFonts.outfit(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: isActive ? const Color(0xFFFFD700) : Colors.white,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
