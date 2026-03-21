import 'package:flutter/material.dart';
import 'screens/game_screen.dart';
import 'game_logic/mahjong_game.dart';

void main() {
  runApp(const MahjongApp());
}

class MahjongApp extends StatelessWidget {
  const MahjongApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '🀄 长清阁麻将',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const GameHomeScreen(),
    );
  }
}

class GameHomeScreen extends StatelessWidget {
  const GameHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A237E), Color(0xFF0D47A1)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🀄', style: TextStyle(fontSize: 100)),
              const SizedBox(height: 20),
              const Text('长清阁麻将', style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 10),
              const Text('血战到底', style: TextStyle(fontSize: 18, color: Colors.white70)),
              const SizedBox(height: 60),
              ElevatedButton.icon(
                onPressed: () {
                  final game = MahjongGame();
                  game.initGame();
                  Navigator.push(context, MaterialPageRoute(builder: (_) => GameScreen(game: game)));
                },
                icon: const Icon(Icons.person),
                label: const Text('单机练习 (4人)'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20), textStyle: const TextStyle(fontSize: 18)),
              ),
              const SizedBox(height: 40),
              const Text('v1.0 测试版', style: TextStyle(color: Colors.white54)),
            ],
          ),
        ),
      ),
    );
  }
}
