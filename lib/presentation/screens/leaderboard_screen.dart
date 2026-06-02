import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/datasources/firebase_service.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> with SingleTickerProviderStateMixin {
  final FirebaseService _firebaseService = FirebaseService();
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Future<List<Map<String, dynamic>>> _leaderboardFuture;

  @override
  void initState() {
    super.initState();
    _leaderboardFuture = _firebaseService.getLeaderboard();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = _firebaseService.currentUser;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Ambient neon background glow
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.cyanAccent.withAlpha(26),
                    blurRadius: 120,
                    spreadRadius: 60,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            right: -50,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.blueAccent.withAlpha(26),
                    blurRadius: 140,
                    spreadRadius: 70,
                  ),
                ],
              ),
            ),
          ),
          // Main Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Top Bar Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70, size: 22),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        Text(
                          'GLOBAL LEADERBOARD',
                          style: GoogleFonts.outfit(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2.0,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                blurRadius: 10,
                                color: Colors.cyanAccent.withAlpha(128),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 48), // Balancing spacing
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Leaderboard List
                    Expanded(
                      child: FutureBuilder<List<Map<String, dynamic>>>(
                        future: _leaderboardFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.cyanAccent),
                              ),
                            );
                          }

                          if (snapshot.hasError) {
                            return Center(
                              child: Text(
                                'Failed to load leaderboard.\nPlease try again later.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(color: Colors.white54, fontSize: 15),
                              ),
                            );
                          }

                          final data = snapshot.data ?? [];
                          if (data.isEmpty) {
                            return Center(
                              child: Text(
                                'No scores uploaded yet.\nBe the first to score!',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(color: Colors.white54, fontSize: 16),
                              ),
                            );
                          }

                          return ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            itemCount: data.length,
                            itemBuilder: (context, index) {
                              final player = data[index];
                              final isSelf = currentUser != null && player['userId'] == currentUser.uid;
                              final score = player['score'] as int? ?? 0;
                              final displayName = player['displayName'] as String? ?? 'Player';
                              final photoUrl = player['photoUrl'] as String? ?? '';
                              final rank = index + 1;

                              return _buildLeaderboardItem(
                                rank: rank,
                                displayName: displayName,
                                photoUrl: photoUrl,
                                score: score,
                                isSelf: isSelf,
                              );
                            },
                          );
                        },
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

  Widget _buildLeaderboardItem({
    required int rank,
    required String displayName,
    required String photoUrl,
    required int score,
    required bool isSelf,
  }) {
    Color rankColor = Colors.white60;
    Widget rankIcon = Text(
      '#$rank',
      style: GoogleFonts.outfit(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: rankColor,
      ),
    );

    // Styling for Top 3
    if (rank == 1) {
      rankColor = const Color(0xFFFFD700); // Gold
      rankIcon = const Icon(Icons.emoji_events, color: Color(0xFFFFD700), size: 24);
    } else if (rank == 2) {
      rankColor = const Color(0xFFC0C0C0); // Silver
      rankIcon = const Icon(Icons.emoji_events, color: Color(0xFFC0C0C0), size: 22);
    } else if (rank == 3) {
      rankColor = const Color(0xFFCD7F32); // Bronze
      rankIcon = const Icon(Icons.emoji_events, color: Color(0xFFCD7F32), size: 20);
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isSelf 
            ? Colors.cyanAccent.withAlpha(26) 
            : Colors.white.withAlpha(15), // Glassmorphism container
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelf 
              ? Colors.cyanAccent.withAlpha(128) 
              : Colors.white.withAlpha(26),
          width: isSelf ? 1.5 : 1.0,
        ),
        boxShadow: isSelf ? [
          BoxShadow(
            color: Colors.cyanAccent.withAlpha(26),
            blurRadius: 8,
            spreadRadius: 1,
          )
        ] : [],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            // Rank Number or Trophy
            Container(
              width: 36,
              alignment: Alignment.center,
              child: rankIcon,
            ),
            const SizedBox(width: 12),
            // User Avatar
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelf ? Colors.cyanAccent : rankColor.withAlpha(128),
                  width: 1.5,
                ),
              ),
              child: ClipOval(
                child: photoUrl.isNotEmpty
                    ? Image.network(
                        photoUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.person, color: Colors.white54, size: 20),
                      )
                    : const Icon(Icons.person, color: Colors.white54, size: 20),
              ),
            ),
            const SizedBox(width: 16),
            // User Name
            Expanded(
              child: Text(
                displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: isSelf ? FontWeight.bold : FontWeight.w500,
                  color: isSelf ? Colors.cyanAccent : Colors.white,
                ),
              ),
            ),
            // High Score
            Text(
              '$score pts',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isSelf ? Colors.cyanAccent : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
