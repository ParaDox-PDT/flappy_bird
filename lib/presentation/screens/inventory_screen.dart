import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/datasources/local_storage.dart';
import '../../domain/models/bird_skin.dart';
import '../../domain/models/game_theme.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final LocalStorage _localStorage = LocalStorage();
  late String _currentSelectedId;
  late String _currentThemeId;
  int _highScore = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final score = await _localStorage.getHighScore();
    final skinId = await _localStorage.getSelectedSkinId();
    final themeId = await _localStorage.getSelectedThemeId();
    setState(() {
      _highScore = score;
      _currentSelectedId = skinId;
      _currentThemeId = themeId;
      _isLoading = false;
    });
  }

  void _selectSkin(BirdSkin skin) async {
    if (_highScore >= skin.unlockScore) {
      await _localStorage.saveSelectedSkinId(skin.id);
      setState(() {
        _currentSelectedId = skin.id;
      });
    }
  }

  void _selectTheme(GameTheme theme) async {
    if (_highScore >= theme.unlockScore) {
      await _localStorage.saveSelectedThemeId(theme.id);
      setState(() {
        _currentThemeId = theme.id;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.cyanAccent)),
      );
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Container(
          decoration: const BoxDecoration(
            color: Colors.black,
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
                            'Your Best Score: $_highScore points',
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
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(Icons.close, color: Colors.white, size: 28),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Tab Bar for Skins vs Themes selection
              TabBar(
                tabs: const [
                  Tab(text: 'SKINS'),
                  Tab(text: 'THEMES'),
                ],
                indicatorColor: const Color(0xFFFFD700),
                labelColor: const Color(0xFFFFD700),
                unselectedLabelColor: Colors.white60,
                labelStyle: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
                unselectedLabelStyle: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
                dividerColor: Colors.transparent,
              ),
              const Divider(color: Colors.white24, height: 1),
              
              // Tab View
              Expanded(
                child: TabBarView(
                  children: [
                    // Skins Tab
                    _buildSkinsTab(_highScore),
                    
                    // Themes Tab
                    _buildThemesTab(_highScore),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkinsTab(int highScore) {
    return GridView.builder(
      padding: const EdgeInsets.all(20.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.82,
      ),
      itemCount: BirdSkin.allSkins.length,
      itemBuilder: (context, index) {
        final skin = BirdSkin.allSkins[index];
        final isUnlocked = highScore >= skin.unlockScore;
        final isActive = _currentSelectedId == skin.id;

        return GestureDetector(
          onTap: isUnlocked ? () => _selectSkin(skin) : null,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(isUnlocked ? 15 : 5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isActive
                    ? const Color(0xFFFFD700)
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
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: CustomPaint(
                          size: const Size(64, 52),
                          painter: BirdPainter(skin: skin),
                        ),
                      ),
                      if (!isUnlocked)
                        Positioned.fill(
                          child: Container(
                            color: Colors.black.withAlpha(120),
                            child: const Icon(
                              Icons.lock_outline,
                              color: Colors.white70,
                              size: 28,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
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
                  if (!isUnlocked)
                    Text(
                      'Requires ${skin.unlockScore} points',
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
    );
  }

  Widget _buildThemesTab(int highScore) {
    return GridView.builder(
      padding: const EdgeInsets.all(20.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 2.1,
      ),
      itemCount: GameTheme.allThemes.length,
      itemBuilder: (context, index) {
        final theme = GameTheme.allThemes[index];
        final isUnlocked = highScore >= theme.unlockScore;
        final isActive = _currentThemeId == theme.id;

        return GestureDetector(
          onTap: isUnlocked ? () => _selectTheme(theme) : null,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(isUnlocked ? 15 : 5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isActive
                    ? const Color(0xFFFFD700)
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
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Opacity(
                      opacity: isUnlocked ? 0.35 : 0.1,
                      child: Image.asset(
                        'assets/images/${theme.backgroundImage}',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withAlpha(180),
                            Colors.black.withAlpha(80),
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                theme.name,
                                style: GoogleFonts.outfit(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: isUnlocked ? Colors.white : Colors.white54,
                                ),
                              ),
                              const SizedBox(height: 4),
                              if (!isUnlocked)
                                Text(
                                  'Requires ${theme.unlockScore} points',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: Colors.redAccent.shade100,
                                    fontWeight: FontWeight.w600,
                                  ),
                                )
                              else
                                Container(
                                  margin: const EdgeInsets.only(top: 6),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isActive
                                        ? const Color(0xFFFFD700).withAlpha(40)
                                        : Colors.white12,
                                    borderRadius: BorderRadius.circular(8),
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
                      ],
                    ),
                  ),
                  if (!isUnlocked)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withAlpha(100),
                        child: const Icon(
                          Icons.lock_outline,
                          color: Colors.white70,
                          size: 32,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class BirdPainter extends CustomPainter {
  final BirdSkin skin;

  BirdPainter({required this.skin});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final colors = skin.colors;
    final isSpecial = skin.isSpecial;

    // Map customization colors
    final bodyPrimary = colors[0];
    final bodySecondary = colors[1];
    final bellyPrimary = colors[2];
    final bellySecondary = colors[3];
    final wingPrimary = colors[4];
    final wingSecondary = colors[5];

    // Shaders & Gradients configuration based on dynamic skin colors
    final backWingShader = LinearGradient(
      colors: [bodyPrimary, wingSecondary],
      begin: Alignment.bottomRight,
      end: Alignment.topLeft,
    ).createShader(Rect.fromLTWH(0, 0, w, h));

    final tailShader = LinearGradient(
      colors: [bodyPrimary, wingPrimary],
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
    ).createShader(Rect.fromLTWH(0, 0, w, h));

    final bodyShader = LinearGradient(
      colors: [bodyPrimary, bodySecondary],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).createShader(Rect.fromLTWH(0, 0, w, h));

    final bellyShader = LinearGradient(
      colors: [bellyPrimary, bellySecondary],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ).createShader(Rect.fromLTWH(0, 0, w, h));

    final frontWingShader1 = LinearGradient(
      colors: [wingPrimary, wingSecondary],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ).createShader(Rect.fromLTWH(0, 0, w, h));

    final frontWingShader2 = LinearGradient(
      colors: [bodySecondary, wingPrimary],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).createShader(Rect.fromLTWH(0, 0, w, h));

    final beakShader = LinearGradient(
      colors: [
        const Color(0xFFFFD54F), // Bright Yellow
        const Color(0xFFFF8F00), // Orange
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).createShader(Rect.fromLTWH(w * 0.75, h * 0.35, w * 0.4, h * 0.2));

    // 1. Render Back Wing (placed behind body)
    final backWingPaint = Paint()..shader = backWingShader;
    final backWingPath = Path()
      ..moveTo(w * 0.32, h * 0.35)
      ..lineTo(w * 0.08, h * -0.05)
      ..lineTo(w * 0.22, h * -0.02)
      ..lineTo(w * 0.38, h * 0.32)
      ..close();
    canvas.drawPath(backWingPath, backWingPaint);

    // 2. Render Tail (placed behind body)
    final tailPaint = Paint()..shader = tailShader;
    final tailPath = Path()
      ..moveTo(w * 0.15, h * 0.5)
      ..lineTo(w * -0.15, h * 0.58)
      ..lineTo(w * -0.08, h * 0.72)
      ..lineTo(w * 0.25, h * 0.62)
      ..close();
    canvas.drawPath(tailPath, tailPaint);

    // 3. Render Main Body (Geometric Core)
    final bodyPaint = Paint()..shader = bodyShader;
    final bodyPath = Path()
      ..moveTo(w * 0.15, h * 0.5)
      ..lineTo(w * 0.28, h * 0.28)
      ..lineTo(w * 0.55, h * 0.22) // Head top
      ..lineTo(w * 0.75, h * 0.35) // Head front
      ..lineTo(w * 0.78, h * 0.45) // Throat
      ..lineTo(w * 0.62, h * 0.55)
      ..lineTo(w * 0.38, h * 0.65)
      ..lineTo(w * 0.15, h * 0.5)
      ..close();
    canvas.drawPath(bodyPath, bodyPaint);

    // 4. Render Belly and Chest (Geometric Accent)
    final bellyPaint = Paint()..shader = bellyShader;
    final bellyPath = Path()
      ..moveTo(w * 0.62, h * 0.55)
      ..lineTo(w * 0.78, h * 0.45)
      ..lineTo(w * 0.72, h * 0.6)   // Chest puff
      ..lineTo(w * 0.52, h * 0.78)   // Belly curve
      ..lineTo(w * 0.32, h * 0.72)   // Lower belly
      ..lineTo(w * 0.38, h * 0.65)
      ..close();
    canvas.drawPath(bellyPath, bellyPaint);

    // 5. Render Beak (long hummingbird-style beak)
    final beakPaint = Paint()..shader = beakShader;
    final beakPath = Path()
      ..moveTo(w * 0.76, h * 0.36)
      ..lineTo(w * 1.15, h * 0.44) // Extends past the right edge
      ..lineTo(w * 0.76, h * 0.46)
      ..close();
    canvas.drawPath(beakPath, beakPaint);

    // 6. Render Front Wing Layers (Geometric origami folded layers)
    // Wing Layer 1 (Darker Base)
    final frontWingPaint1 = Paint()..shader = frontWingShader2;
    final frontWingPath1 = Path()
      ..moveTo(w * 0.35, h * 0.45)
      ..lineTo(w * 0.12, h * 0.05)
      ..lineTo(w * 0.24, h * 0.08)
      ..lineTo(w * 0.42, h * 0.42)
      ..close();
    canvas.drawPath(frontWingPath1, frontWingPaint1);

    // Wing Layer 2 (Lighter highlights)
    final frontWingPaint2 = Paint()..shader = frontWingShader1;
    final frontWingPath2 = Path()
      ..moveTo(w * 0.42, h * 0.42)
      ..lineTo(w * 0.24, h * 0.08)
      ..lineTo(w * 0.34, h * 0.12)
      ..lineTo(w * 0.48, h * 0.38)
      ..close();
    canvas.drawPath(frontWingPath2, frontWingPaint2);

    // Wing Highlight Facet (Small origami fold with extra shine for special skins)
    final wingHighlightPaint = Paint()
      ..color = isSpecial
          ? const Color(0xFFFFFFFF).withAlpha(190) // Extra bright white shine
          : bellyPrimary.withAlpha(120); // standard theme color highlight

    final wingHighlightPath = Path()
      ..moveTo(w * 0.48, h * 0.38)
      ..lineTo(w * 0.34, h * 0.12)
      ..lineTo(w * 0.4, h * 0.18)
      ..lineTo(w * 0.52, h * 0.35)
      ..close();
    canvas.drawPath(wingHighlightPath, wingHighlightPaint);

    // 7. Render Big Eye (Dash-style friendly circular eye)
    final eyeWhitePaint = Paint()..color = Colors.white;
    final eyeCenter = Offset(w * 0.65, h * 0.33);
    final eyeRadius = h * 0.13;
    canvas.drawCircle(eyeCenter, eyeRadius, eyeWhitePaint);

    // Glowing Aura around the eye for Special Skins
    if (isSpecial) {
      final glowPaint = Paint()
        ..color = const Color(0xFFFFD700).withAlpha(140) // Golden glow
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawCircle(eyeCenter, eyeRadius + 1.2, glowPaint);
    }

    // Pupil
    final eyePupilPaint = Paint()..color = Colors.black;
    final pupilCenter = Offset(w * 0.67, h * 0.33);
    final pupilRadius = h * 0.07;
    canvas.drawCircle(pupilCenter, pupilRadius, eyePupilPaint);

    // Reflection Dot or Sparkling Star for Special Skins
    if (isSpecial) {
      // Draw cross/star reflection in pupil
      final starPaint = Paint()..color = Colors.white;
      final starPath = Path()
        ..moveTo(pupilCenter.dx, pupilCenter.dy - 2.5)
        ..lineTo(pupilCenter.dx + 0.6, pupilCenter.dy - 0.6)
        ..lineTo(pupilCenter.dx + 2.5, pupilCenter.dy)
        ..lineTo(pupilCenter.dx + 0.6, pupilCenter.dy + 0.6)
        ..lineTo(pupilCenter.dx, pupilCenter.dy + 2.5)
        ..lineTo(pupilCenter.dx - 0.6, pupilCenter.dy + 0.6)
        ..lineTo(pupilCenter.dx - 2.5, pupilCenter.dy)
        ..lineTo(pupilCenter.dx - 0.6, pupilCenter.dy - 0.6)
        ..close();
      canvas.drawPath(starPath, starPaint);
    } else {
      // Normal reflection dot
      final eyeReflectionPaint = Paint()..color = Colors.white;
      final reflectionCenter = Offset(w * 0.69, h * 0.31);
      final reflectionRadius = h * 0.025;
      canvas.drawCircle(reflectionCenter, reflectionRadius, eyeReflectionPaint);
    }

    // 8. Render Special Headwear (tiny royal golden crown for special skins)
    if (isSpecial) {
      final crownPaint = Paint()..color = const Color(0xFFFFD700);
      final crownPath = Path()
        ..moveTo(w * 0.50, h * 0.22) // Left base
        ..lineTo(w * 0.44, h * 0.08) // Left peak
        ..lineTo(w * 0.54, h * 0.14) // Left valley
        ..lineTo(w * 0.60, h * 0.04) // Center peak
        ..lineTo(w * 0.66, h * 0.14) // Right valley
        ..lineTo(w * 0.76, h * 0.08) // Right peak
        ..lineTo(w * 0.70, h * 0.22) // Right base
        ..close();
      canvas.drawPath(crownPath, crownPaint);

      // Ruby gemstone on center crown peak
      final gemPaint = Paint()..color = const Color(0xFFFF1744);
      canvas.drawCircle(Offset(w * 0.60, h * 0.04), h * 0.04, gemPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
