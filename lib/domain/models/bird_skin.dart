import 'package:flutter/material.dart';

class BirdSkin {
  final String id;
  final String name;
  final int unlockScore;
  final List<Color> colors; // [bodyPrimary, bodySecondary, bellyPrimary, bellySecondary, wingPrimary, wingSecondary]
  final bool isSpecial; // Triggers extra rendering details like a golden crown

  const BirdSkin({
    required this.id,
    required this.name,
    required this.unlockScore,
    required this.colors,
    required this.isSpecial,
  });

  /// Predefined list of 10 Dash hummingbird skins based on High Score milestones
  static final List<BirdSkin> allSkins = [
    // 1. Default Dash (0 score) - Classic cyan/blue
    const BirdSkin(
      id: 'default',
      name: 'Default Dash',
      unlockScore: 0,
      colors: [
        Color(0xFF02569B), // Body Primary
        Color(0xFF0175C2), // Body Secondary
        Color(0xFF00E5FF), // Belly Primary
        Color(0xFF00B0FF), // Belly Secondary
        Color(0xFF80DEEA), // Wing Primary
        Color(0xFF00ACC1), // Wing Secondary
      ],
      isSpecial: false,
    ),
    // 2. Neon Cyber (5 score) - Vibrant green/purple
    const BirdSkin(
      id: 'neon_cyber',
      name: 'Neon Cyber',
      unlockScore: 5,
      colors: [
        Color(0xFF4A0E4E),
        Color(0xFF7B1FA2),
        Color(0xFF00FF66),
        Color(0xFF00E5FF),
        Color(0xFFB388FF),
        Color(0xFF6200EA),
      ],
      isSpecial: false,
    ),
    // 3. Phoenix Fire (10 score) - Fire orange/yellow/red
    const BirdSkin(
      id: 'phoenix_fire',
      name: 'Phoenix Fire',
      unlockScore: 10,
      colors: [
        Color(0xFFD50000),
        Color(0xFFE65100),
        Color(0xFFFFEA00),
        Color(0xFFFF9100),
        Color(0xFFFFD600),
        Color(0xFFFF3D00),
      ],
      isSpecial: false,
    ),
    // 4. Midnight Shadow (15 score) - Charcoal/slate/neon-blue
    const BirdSkin(
      id: 'midnight_shadow',
      name: 'Midnight Shadow',
      unlockScore: 15,
      colors: [
        Color(0xFF121212),
        Color(0xFF2C2C2C),
        Color(0xFF00E5FF),
        Color(0xFF2979FF),
        Color(0xFF37474F),
        Color(0xFF212121),
      ],
      isSpecial: false,
    ),
    // 5. Golden Royal (20 score) - Bronze/luxury gold (special)
    const BirdSkin(
      id: 'golden_royal',
      name: 'Golden Royal',
      unlockScore: 20,
      colors: [
        Color(0xFF8D6E63),
        Color(0xFFBCAAA4),
        Color(0xFFFFD700),
        Color(0xFFFFF9C4),
        Color(0xFFFFD700),
        Color(0xFFFFFFFF),
      ],
      isSpecial: true, // Will draw a tiny golden crown on head
    ),
    // 6. Emerald Nature (25 score) - Emerald green/mint
    const BirdSkin(
      id: 'emerald_nature',
      name: 'Emerald Nature',
      unlockScore: 25,
      colors: [
        Color(0xFF1B5E20),
        Color(0xFF2E7D32),
        Color(0xFF69F0AE),
        Color(0xFFB9F6CA),
        Color(0xFF4CAF50),
        Color(0xFF81C784),
      ],
      isSpecial: false,
    ),
    // 7. Cosmic Nebula (30 score) - Indigo/magenta/neon-purple
    const BirdSkin(
      id: 'cosmic_nebula',
      name: 'Cosmic Nebula',
      unlockScore: 30,
      colors: [
        Color(0xFF311B92),
        Color(0xFF4A148C),
        Color(0xFFFF4081),
        Color(0xFFE040FB),
        Color(0xFFD500F9),
        Color(0xFF00E5FF),
      ],
      isSpecial: false,
    ),
    // 8. Frozen Ice (35 score) - Teal/ice-white/sky-blue
    const BirdSkin(
      id: 'frozen_ice',
      name: 'Frozen Ice',
      unlockScore: 35,
      colors: [
        Color(0xFF006064),
        Color(0xFF00838F),
        Color(0xFFE0F7FA),
        Color(0xFF80DEEA),
        Color(0xFFB2EBF2),
        Color(0xFF00B0FF),
      ],
      isSpecial: false,
    ),
    // 9. Ruby Crimson (40 score) - Dark brown/ruby/black
    const BirdSkin(
      id: 'ruby_crimson',
      name: 'Ruby Crimson',
      unlockScore: 40,
      colors: [
        Color(0xFF3E2723),
        Color(0xFF880E4F),
        Color(0xFFD50000),
        Color(0xFFFF1744),
        Color(0xFF212121),
        Color(0xFFC2185B),
      ],
      isSpecial: false,
    ),
    // 10. Galaxy Overlord (50 score) - Space black/nebula gold (special)
    const BirdSkin(
      id: 'galaxy_overlord',
      name: 'Galaxy Overlord',
      unlockScore: 50,
      colors: [
        Color(0xFF000000),
        Color(0xFF1A1A2E),
        Color(0xFFFFD700),
        Color(0xFFFFAB40),
        Color(0xFF3F51B5),
        Color(0xFFFFD700),
      ],
      isSpecial: true, // Will draw a tiny golden crown on head
    ),
  ];
}
