import 'package:flutter/material.dart';

/// 玩家信息组件
class PlayerAvatar extends StatelessWidget {
  final String name;
  final int position; // 0:自己, 1:下家, 2:对家, 3:上家
  final bool isCurrentTurn;
  final bool isReady;
  final int score;

  const PlayerAvatar({
    super.key,
    required this.name,
    required this.position,
    this.isCurrentTurn = false,
    this.isReady = false,
    this.score = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCurrentTurn ? Colors.red : Colors.grey[300],
                border: Border.all(
                  color: isCurrentTurn ? Colors.red : Colors.grey,
                  width: 3,
                ),
                boxShadow: isCurrentTurn
                    ? [BoxShadow(color: Colors.red.withOpacity(0.5), blurRadius: 10)]
                    : null,
              ),
              child: Center(
                child: Text(
                  _getPositionEmoji(),
                  style: const TextStyle(fontSize: 30),
                ),
              ),
            ),
            if (isReady)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, size: 16, color: Colors.white),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          name,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isCurrentTurn ? FontWeight.bold : FontWeight.normal,
            color: isCurrentTurn ? Colors.red : Colors.black,
          ),
        ),
        if (score > 0)
          Text(
            '$score分',
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
      ],
    );
  }

  String _getPositionEmoji() {
    switch (position) {
      case 0: return '😎'; // 自己
      case 1: return '👤'; // 下家
      case 2: return '😐'; // 对家
      case 3: return '👤'; // 上家
      default: return '❓';
    }
  }
}

/// 座位方向布局
class PlayerPositionLayout extends StatelessWidget {
  final List<PlayerAvatar> players;
  final bool showPositions;

  const PlayerPositionLayout({
    super.key,
    required this.players,
    this.showPositions = true,
  });

  @override
  Widget build(BuildContext context) {
    if (players.length != 4) {
      return const SizedBox();
    }

    return Stack(
      children: [
        // 上家 (3)
        Positioned(
          top: 10,
          left: 10,
          child: players[3],
        ),
        // 对家 (2)
        Positioned(
          top: 10,
          right: 10,
          child: players[2],
        ),
        // 下家 (1)
        Positioned(
          bottom: 10,
          right: 10,
          child: players[1],
        ),
        // 自己 (0)
        Positioned(
          bottom: 10,
          left: 10,
          child: players[0],
        ),
        // 牌桌中心
        const Center(
          child: Text(
            '🀄',
            style: TextStyle(fontSize: 60),
          ),
        ),
      ],
    );
  }
}
