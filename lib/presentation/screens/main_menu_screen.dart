import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flame_audio/flame_audio.dart';
import '../../data/datasources/local_storage.dart';
import '../../data/datasources/firebase_service.dart';
import '../../domain/models/game_theme.dart';
import 'game_screen.dart';
import 'inventory_screen.dart';
import 'leaderboard_screen.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  final LocalStorage _localStorage = LocalStorage();
  final FirebaseService _firebaseService = FirebaseService();
  int _highScore = 0;
  GameTheme _currentTheme = GameTheme.allThemes.first;
  bool _isLoading = true;
  User? _currentUser;
  bool _isSigningIn = false;
  bool _isMuted = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    _setupAuthListener();
  }

  Future<void> _loadData() async {
    final score = await _localStorage.getHighScore();
    final themeId = await _localStorage.getSelectedThemeId();
    final isMuted = await _localStorage.getIsMuted();
    final theme = GameTheme.allThemes.firstWhere(
      (t) => t.id == themeId,
      orElse: () => GameTheme.allThemes.first,
    );
    setState(() {
      _highScore = score;
      _currentTheme = theme;
      _isMuted = isMuted;
      _isLoading = false;
    });

    // Start background music if not muted
    if (!isMuted) {
      try {
        if (!FlameAudio.bgm.isPlaying) {
          await FlameAudio.bgm.play('clear_summer_canopy.mp3');
        }
      } catch (e) {
        print('Error playing background music: $e');
      }
    }
  }

  void _setupAuthListener() {
    _firebaseService.authStateChanges.listen((user) {
      if (mounted) {
        setState(() {
          _currentUser = user;
        });
        // Proactively sync high score when the user signs in
        if (user != null && _highScore > 0) {
          _firebaseService.submitScore(_highScore);
        }
      }
    });
  }

  Future<void> _toggleMute() async {
    final newMuted = !_isMuted;
    setState(() {
      _isMuted = newMuted;
    });
    await _localStorage.saveIsMuted(newMuted);

    try {
      if (newMuted) {
        await FlameAudio.bgm.stop();
      } else {
        if (!FlameAudio.bgm.isPlaying) {
          await FlameAudio.bgm.play('clear_summer_canopy.mp3');
        }
      }
    } catch (e) {
      print('Error toggling mute: $e');
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isSigningIn = true;
    });
    try {
      await _firebaseService.signInWithGoogle();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Google Sign-In failed: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSigningIn = false;
        });
      }
    }
  }

  Future<void> _handleSignOut() async {
    try {
      await _firebaseService.signOut();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign-out failed: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
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
              color: Colors.black.withAlpha(128), // 0.50 opacity
            ),
          ),
          // Sound Toggle (Top Left)
          Positioned(
            top: 50,
            left: 20,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withAlpha(100),
                border: Border.all(color: Colors.white24, width: 1),
              ),
              child: IconButton(
                icon: Icon(
                  _isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                  color: _isMuted ? Colors.redAccent : Colors.cyanAccent,
                  size: 24,
                ),
                onPressed: _toggleMute,
              ),
            ),
          ),
          // Profile Indicator (Top Right)
          Positioned(
            top: 50,
            right: 20,
            child: _currentUser != null
                ? Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            _currentUser!.displayName ?? 'Player',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          GestureDetector(
                            onTap: _handleSignOut,
                            child: Text(
                              'Sign Out',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.redAccent,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.cyanAccent, width: 1.5),
                        ),
                        child: ClipOval(
                          child: _currentUser!.photoURL != null
                              ? Image.network(
                                  _currentUser!.photoURL!,
                                  width: 36,
                                  height: 36,
                                  fit: BoxFit.cover,
                                )
                              : const Icon(Icons.person, color: Colors.white, size: 24),
                        ),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
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
                    const SizedBox(height: 40),
                    // Play Button
                    _buildMenuButton(
                      text: 'PLAY NOW',
                      isGlow: true,
                      onTap: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const GameScreen()),
                        );
                        _loadData(); // Reload high score and theme on return
                      },
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00E5FF), Color(0xFF2979FF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Leaderboard Button (Conditional or Prompts Google Sign In)
                    _currentUser != null
                        ? _buildMenuButton(
                            text: 'LEADERBOARD',
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (context) => const LeaderboardScreen()),
                              );
                            },
                            icon: Icons.emoji_events,
                          )
                        : _buildMenuButton(
                            text: _isSigningIn ? 'SIGNING IN...' : 'SIGN IN TO LEADERBOARD',
                            onTap: _isSigningIn ? null : _handleGoogleSignIn,
                            icon: Icons.login,
                            backgroundColor: Colors.white.withAlpha(20),
                            borderColor: Colors.white30,
                          ),
                    const SizedBox(height: 16),
                    // Skins & Themes Button
                    _buildMenuButton(
                      text: 'SKINS & THEMES',
                      onTap: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const InventoryScreen()),
                        );
                        _loadData(); // Reload theme in case they changed it
                      },
                      icon: Icons.style_outlined,
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

  Widget _buildMenuButton({
    required String text,
    required VoidCallback? onTap,
    bool isGlow = false,
    IconData? icon,
    Gradient? gradient,
    Color? backgroundColor,
    Color borderColor = Colors.white30,
  }) {
    return MouseRegion(
      cursor: onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: Container(
        width: 280,
        height: 54,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          border: gradient == null ? Border.all(color: borderColor, width: 1.5) : null,
          boxShadow: isGlow && onTap != null
              ? [
                  BoxShadow(
                    color: Colors.cyanAccent.withAlpha(76),
                    blurRadius: 20,
                    spreadRadius: 2,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Material(
            color: gradient == null ? (backgroundColor ?? Colors.white12) : Colors.transparent,
            child: InkWell(
              onTap: onTap,
              splashColor: Colors.white.withAlpha(50),
              child: Container(
                decoration: gradient != null ? BoxDecoration(gradient: gradient) : null,
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        text,
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
    );
  }
}
