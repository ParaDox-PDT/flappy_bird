import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/datasources/local_storage.dart';
import '../../domain/models/game_theme.dart';
import 'game_screen.dart';
import 'inventory_screen.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  final LocalStorage _localStorage = LocalStorage();
  int _highScore = 0;
  GameTheme _currentTheme = GameTheme.allThemes.first;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final score = await _localStorage.getHighScore();
    final themeId = await _localStorage.getSelectedThemeId();
    final theme = GameTheme.allThemes.firstWhere(
      (t) => t.id == themeId,
      orElse: () => GameTheme.allThemes.first,
    );
    setState(() {
      _highScore = score;
      _currentTheme = theme;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.cyanAccent)),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          // Dynamic Theme Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/${_currentTheme.backgroundImage}',
              fit: BoxFit.cover,
            ),
          ),
          // Dark Glassmorphism Overlay
          Positioned.fill(
            child: Container(
              color: Colors.black.withAlpha(115), // 0.45 opacity
            ),
          ),
          // Content
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Title Section with Glow Effect
                    Text(
                      'SKY BIRD',
                      style: GoogleFonts.outfit(
                        fontSize: 54,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 4.0,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            blurRadius: 15.0,
                            color: Colors.cyanAccent.withAlpha(178),
                            offset: const Offset(0, 0),
                          ),
                          Shadow(
                            blurRadius: 30.0,
                            color: Colors.blueAccent.withAlpha(128),
                            offset: const Offset(0, 0),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    // High Score Record Label
                    Text(
                      'Best Score: $_highScore points',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFFFD700),
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Subtitle
                    Text(
                      'Tap to fly. Avoid the obstacles.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withAlpha(191),
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 48),
                    // Play Button
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Container(
                        width: 250,
                        height: 56,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.cyanAccent.withAlpha(76),
                              blurRadius: 20,
                              spreadRadius: 2,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(28),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () async {
                                await Navigator.of(context).push(
                                  MaterialPageRoute(builder: (context) => const GameScreen()),
                                );
                                _loadData(); // Reload high score and theme on return
                              },
                              splashColor: Colors.white.withAlpha(76),
                              highlightColor: Colors.white.withAlpha(26),
                              child: Ink(
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFF00E5FF),
                                      Color(0xFF2979FF),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    'PLAY NOW',
                                    style: GoogleFonts.outfit(
                                      fontSize: 18,
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
                    const SizedBox(height: 16),
                    // Skins & Themes Button
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Container(
                        width: 250,
                        height: 56,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(color: Colors.white30, width: 1.5),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(28),
                          child: Material(
                            color: Colors.white12,
                            child: InkWell(
                              onTap: () async {
                                await Navigator.of(context).push(
                                  MaterialPageRoute(builder: (context) => const InventoryScreen()),
                                );
                                _loadData(); // Reload theme in case they changed it
                              },
                              splashColor: Colors.white.withAlpha(50),
                              child: Center(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.style_outlined, color: Colors.white, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      'SKINS & THEMES',
                                      style: GoogleFonts.outfit(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.5,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
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
        ],
      ),
    );
  }
}
