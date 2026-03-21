import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/game_screen.dart';
import 'providers/game_provider.dart';
import 'providers/multiplayer_provider.dart';
import 'services/game_logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化日志服务
  GameLogger? logger;
  try {
    logger = await GameLogger.getInstance();
  } catch (e) {
    debugPrint('日志服务初始化失败: $e');
  }
  
  runApp(MahjongApp(logger: logger));
}

class MahjongApp extends StatelessWidget {
  final GameLogger? logger;
  
  const MahjongApp({super.key, this.logger});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) {
            final provider = GameProvider();
            if (logger != null) {
              provider.setLogger(logger!);
            }
            return provider;
          },
        ),
        ChangeNotifierProvider(
          create: (_) => MultiplayerProvider(),
        ),
      ],
      child: MaterialApp(
        title: '🀄 长清阁麻将',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          useMaterial3: true,
        ),
        home: const GameHomeScreen(),
      ),
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
              const Text(
                '长清阁麻将',
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 10),
              const Text('血战到底', style: TextStyle(fontSize: 18, color: Colors.white70)),
              const SizedBox(height: 60),
              ElevatedButton.icon(
                onPressed: () => _startSinglePlayer(context),
                icon: const Icon(Icons.person),
                label: const Text('单机练习 (4人)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => _showCreateRoomDialog(context),
                icon: const Icon(Icons.add_home),
                label: const Text('创建房间'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => _showJoinRoomDialog(context),
                icon: const Icon(Icons.login),
                label: const Text('加入房间'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 40),
              const Text('v1.0 测试版', style: TextStyle(color: Colors.white54)),
            ],
          ),
        ),
      ),
    );
  }

  void _startSinglePlayer(BuildContext context) {
    final gameProvider = context.read<GameProvider>();
    gameProvider.initGame();
    gameProvider.startNewRound();
    
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => GameScreen(game: context.read<GameProvider>().game)),
    );
  }

  void _showCreateRoomDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('创建房间'),
        content: TextField(controller: controller, decoration: const InputDecoration(labelText: '房间名称')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isEmpty) return;
              context.read<MultiplayerProvider>().createRoom(roomName: controller.text.trim());
              Navigator.pop(ctx);
              _showComingSoon(context, '房间已创建');
            },
            child: const Text('创建'),
          ),
        ],
      ),
    );
  }

  void _showJoinRoomDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('加入房间'),
        content: TextField(controller: controller, decoration: const InputDecoration(labelText: '房间号')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isEmpty) return;
              context.read<MultiplayerProvider>().joinRoom(controller.text.trim());
              Navigator.pop(ctx);
              _showComingSoon(context, '加入房间');
            },
            child: const Text('加入'),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context, String msg) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(msg),
        content: const Text('该功能正在开发中，敬请期待!'),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('知道了'))],
      ),
    );
  }
}
