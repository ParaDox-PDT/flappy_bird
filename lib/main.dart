import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'presentation/screens/game_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Flappy Bird is best played in portrait mode
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set game to fullscreen (hide status bar and navigation bar)
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(const SkyBirdApp());
}

class SkyBirdApp extends StatelessWidget {
  const SkyBirdApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sky Bird',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      home: const GameScreen(),
    );
  }
}
