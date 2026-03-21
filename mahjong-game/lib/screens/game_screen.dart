import 'package:flutter/material.dart';
import '../models/tile_model.dart';
import '../models/player_model.dart';
import '../game_logic/mahjong_game.dart';
import '../widgets/tile_widget.dart';

// 梯形麻将桌布Painter
class TrapezoidPainter extends CustomPainter {
  final double topWidth;
  final double bottomWidth;
  final Color color;

  TrapezoidPainter({required this.topWidth, required this.bottomWidth, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..style = PaintingStyle.fill;
    final height = size.height;
    final topOffset = (bottomWidth - topWidth) / 2;

    final path = Path()
      ..moveTo(topOffset, 0)
      ..lineTo(topOffset + topWidth, 0)
      ..lineTo(bottomWidth, height)
      ..lineTo(0, height)
      ..close();

    canvas.drawPath(path, paint);
    
    final borderPaint = Paint()
      ..color = Colors.green.shade800
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class GameScreen extends StatefulWidget {
  final MahjongGame game;

  const GameScreen({super.key, required this.game});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late MahjongGame _game;

  late AnimationController _diceController;

  bool _isRollingDice = false;
  bool _isDealing = false;
  bool _hasDealt = false;
  bool _mustDiscardAfterClaim = false;

  int _currentPlayerIndex = 0;
  Tile? _lastDrawnTile;
  Tile? _pendingTile;

  Map<String, bool> _availableActions = {
    'chow': false,
    'pong': false,
    'kong': false,
    'hu': false,
  };

  // 玩家头像颜色
  final List<Color> _avatarColors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
  ];

  @override
  void initState() {
    super.initState();
    _game = widget.game;

    _diceController = AnimationController(
      duration: const Duration(milliseconds: 400), // 加快4倍
      vsync: this,
    )..addStatusListener(_handleDiceAnimationStatus);

    _startGame();
  }

  @override
  void dispose() {
    _diceController.removeStatusListener(_handleDiceAnimationStatus);
    _diceController.dispose();
    super.dispose();
  }

  int _diceClickCount = 0;
  
  void _handleDiceAnimationStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed || !_isRollingDice) {
      return;
    }

    _game.rollDice();
    _diceClickCount++;
    
    if (_diceClickCount < 2) {
      // 还可以再掷一次
      _diceController.stop();
      _diceController.reset();
      _diceController.forward(from: 0);
    } else {
      // 已经掷了2次，结束掷骰
      _diceController.stop();
      _diceController.reset();
      setState(() {
        _isRollingDice = false;
        _diceClickCount = 0;
      });
    }

    if (!mounted) return;
    setState(() {});
  }

  void _startGame() {
    _game.initGame();

    setState(() {
      _isRollingDice = true;
      _isDealing = false;
      _hasDealt = false;
      _mustDiscardAfterClaim = false;
      _lastDrawnTile = null;
      _pendingTile = null;
      _currentPlayerIndex = 0;
      _availableActions = {
        'chow': false,
        'pong': false,
        'kong': false,
        'hu': false,
      };
    });
  }

  void _onDiceClick() {
    if (_isRollingDice && _diceClickCount < 2) {
      // 重置计数器以便再次掷骰
      setState(() {
        _game.diceRolled = false;
      });
      _diceController.forward(from: 0);
    }
  }

  Future<void> _startDealing() async {
    if (!_game.diceRolled) return;

    setState(() {
      _isDealing = true;
      _hasDealt = false;
      _mustDiscardAfterClaim = false;
    });

    _game.startRound();

    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    setState(() {
      _isDealing = false;
      _hasDealt = true;
      _currentPlayerIndex = _game.dealerIndex;
    });

    _doDrawOrPlay();
  }

  void _doDrawOrPlay() {
    if (!mounted) return;

    if (_currentPlayerIndex == 0) {
      // 人类玩家：根据当前状态决定摸牌/打牌/响应
      _checkActions();
    } else {
      // AI玩家
      _aiPlay();
    }
  }

  void _doDrawTile({bool afterKong = false}) {
    final player = _game.players[_currentPlayerIndex];
    final tile = _game.drawTile(player, afterKong: afterKong);

    if (tile == null) {
      if (_game.isDraw) {
        _handleDraw();
      }
      return;
    }

    setState(() {
      _lastDrawnTile = _currentPlayerIndex == 0 ? tile : null;
      _pendingTile = null;
      _mustDiscardAfterClaim = false;
    });

    _checkActions();
  }

  Future<void> _aiPlay() async {
    final player = _game.players[_currentPlayerIndex];
    final needsDraw = player.handTiles.length % 3 == 1;

    if (needsDraw) {
      final tile = _game.drawTile(player);
      if (tile == null) {
        if (_game.isDraw) {
          _handleDraw();
        }
        return;
      }
    }

    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    final playedTile = _game.aiPlayTile(player);
    if (playedTile == null) return;

    final nextIndex = (_currentPlayerIndex + 1) % 4;
    setState(() {
      _pendingTile = playedTile;
      _lastDrawnTile = null;
      _mustDiscardAfterClaim = false;
      _currentPlayerIndex = nextIndex;
    });

    if (nextIndex == 0) {
      _checkActions();
      return;
    }

    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    _doDrawOrPlay();
  }

  void _checkActions() {
    final player = _game.players[_currentPlayerIndex];
    final hiddenKong = !_mustDiscardAfterClaim && _game.canHiddenKong(player);
    final selfDrawHu = !_mustDiscardAfterClaim && _game.canHu(
      player,
      newTile: _lastDrawnTile,
      isSelfDrawn: _lastDrawnTile != null,
    );

    final canPong = _pendingTile != null ? _game.canPong(player, _pendingTile!) : false;
    final canChow = _pendingTile != null && _currentPlayerIndex == 0
        ? _game.canChow(player, _pendingTile!)
        : false;
    final canExposedKong = _pendingTile != null ? _game.canExposedKong(player, _pendingTile!) : false;
    final canRon = _pendingTile != null ? _game.canRonWithTile(player, _pendingTile!) : false;

    setState(() {
      _availableActions['pong'] = canPong;
      _availableActions['chow'] = canChow;
      _availableActions['kong'] = canExposedKong || hiddenKong;
      _availableActions['hu'] = _pendingTile != null ? canRon : selfDrawHu;
    });
  }

  Future<void> _nextTurn() async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    setState(() {
      _currentPlayerIndex = (_currentPlayerIndex + 1) % 4;
      _pendingTile = null;
      _lastDrawnTile = null;
      _mustDiscardAfterClaim = false;
    });
    _doDrawOrPlay();
  }

  void _playTile(Tile tile) {
    if (!_canHumanDiscard) return;

    final player = _game.players[_currentPlayerIndex];
    _game.playTile(player, tile);

    setState(() {
      _lastDrawnTile = null;
      _pendingTile = tile;
      _mustDiscardAfterClaim = false;
    });

    _nextTurn();
  }

  void _chow() {
    if (_pendingTile == null) return;
    final player = _game.players[_currentPlayerIndex];
    final fromPlayer = _game.lastPlayedBy;
    final meld = _game.chow(player, _pendingTile!);
    if (meld == null) return;

    if (fromPlayer != null) {
      _game.recordChow(player, fromPlayer);
    }

    setState(() {
      _pendingTile = null;
      _lastDrawnTile = null;
      _mustDiscardAfterClaim = true;
    });
  }

  void _pong() {
    if (_pendingTile == null) return;
    final player = _game.players[_currentPlayerIndex];
    final fromPlayer = _game.lastPlayedBy;
    final meld = _game.pong(player, _pendingTile!);
    if (meld == null) return;

    if (fromPlayer != null) {
      _game.recordPong(player, fromPlayer);
    }

    setState(() {
      _pendingTile = null;
      _lastDrawnTile = null;
      _mustDiscardAfterClaim = true;
    });
  }

  void _hiddenKong() {
    final player = _game.players[_currentPlayerIndex];
    final meld = _game.hiddenKong(player);
    if (meld == null) return;

    setState(() {
      _lastDrawnTile = null;
      _mustDiscardAfterClaim = false;
    });
    _doDrawTile(afterKong: true);
  }

  void _kong() {
    final player = _game.players[_currentPlayerIndex];
    if (_pendingTile != null && _game.canExposedKong(player, _pendingTile!)) {
      final meld = _game.exposedKong(player, _pendingTile!);
      if (meld == null) return;

      setState(() {
        _pendingTile = null;
        _lastDrawnTile = null;
        _mustDiscardAfterClaim = false;
      });
      _doDrawTile(afterKong: true);
      return;
    }

    if (_game.canHiddenKong(player)) {
      _hiddenKong();
    }
  }

  void _hu() {
    final player = _game.players[_currentPlayerIndex];
    final huTile = _lastDrawnTile ?? _pendingTile;
    final isSelfDrawn = _pendingTile == null;
    final isKaiGang = _game.justDrewAfterKong && isSelfDrawn;
    final huType = _game.checkHuType(player, newTile: huTile);

    final settlement = _game.calculateSettlement(
      player,
      huTile: huTile,
      isSelfDrawn: isSelfDrawn,
      isKaiGang: isKaiGang,
    );

    _game.playerHu(player);

    String huTypeName = isSelfDrawn ? '自摸' : '捉冲';
    if (isKaiGang) huTypeName = '杠开';

    String info = '胡牌方式: $huTypeName\n';
    info += '牌型: ${huType?.name ?? "基础胡"}\n';
    info += '当局翻倍: ×${_game.roundMultiplier}\n';
    info += '全局翻倍: ×${_game.multiplier}\n';
    info += '总倍数: ×${_game.totalMultiplier}\n';
    info += '总点数: ${settlement?.totalPoints ?? 0}\n\n';

    _game.justDrewAfterKong = false;

    if (_game.shouldEndRound()) {
      _showGameEndDialog(player, info);
    } else {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('🎉 ${player.name} 胡牌!'),
          content: Text(info),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                _continueGame();
              },
              child: const Text('继续'),
            ),
          ],
        ),
      );
    }
  }

  void _continueGame() {
    setState(() {
      _pendingTile = null;
      _lastDrawnTile = null;
      _mustDiscardAfterClaim = false;
    });
    _nextTurn();
  }

  void _showGameEndDialog(Player winner, String info) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text('🏁 ${winner.name} 最终获胜!'),
        content: SingleChildScrollView(child: Text(info)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _startGame();
            },
            child: const Text('下一局'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('退出'),
          ),
        ],
      ),
    );
  }

  void _handleDraw() {
    _game.applyDrawMultiplier();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('😐 流局!'),
        content: Text('牌已摸完，无人胡牌。\n下局翻倍：×${_game.multiplier}'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _startGame();
            },
            child: const Text('下一局'),
          ),
        ],
      ),
    );
  }

  void _skip() {
    final hadPendingTile = _pendingTile != null;
    setState(() {
      _pendingTile = null;
      _lastDrawnTile = null;
      _mustDiscardAfterClaim = false;
    });

    if (hadPendingTile) {
      _doDrawTile();
    }
  }

  void _drawCard() {
    // 人类玩家摸牌
    if (_canDraw) {
      _doDrawTile();
    }
  }

  bool get _canDraw {
    if (_currentPlayerIndex != 0 || !_hasDealt || _isRollingDice || _isDealing || !_game.diceRolled) {
      return false;
    }
    if (_pendingTile != null || _lastDrawnTile != null || _mustDiscardAfterClaim) {
      return false;
    }
    return _game.players[0].handTiles.length % 3 == 1;
  }

  bool get _canHumanDiscard {
    if (_currentPlayerIndex != 0 || !_hasDealt || _isRollingDice || _isDealing || !_game.diceRolled) {
      return false;
    }
    if (_pendingTile != null) {
      return false;
    }
    if (_mustDiscardAfterClaim || _lastDrawnTile != null) {
      return true;
    }
    return _game.players[0].handTiles.length % 3 == 2;
  }

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
        child: SafeArea(
          child: Stack(
            children: [
              // 梯形麻将桌布
              _buildMahjongTable(),
              
              // 玩家座位
              _buildPlayerSeats(),

              // 牌墙
              _buildWall(),

              // 掷骰子动画/按钮
              if (!_hasDealt) _buildDiceSection(),

              // 屏幕中间发牌按钮
              if (_game.diceRolled && !_isDealing && !_hasDealt)
                Positioned(
                  left: 0,
                  right: 0,
                  top: 250,
                  child: Center(
                    child: ElevatedButton(
                      onPressed: _startDealing,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      ),
                      child: const Text('发牌', style: TextStyle(fontSize: 18, color: Colors.white)),
                    ),
                  ),
                ),

              // 发牌动画
              if (_isDealing) _buildDealingAnimation(),

              // 庄家/倍数提示
              // 庄家/倍数提示 - 右上角
              Positioned(
                top: 80,
                right: 20,
                child: _buildMultiplierDisplay(),
              ),
              // 庄家提示 - 左上角
              Positioned(
                top: 80,
                left: 20,
                child: _buildDealerInfo(),
              ),

              // 待处理牌
              if (_pendingTile != null)
                Positioned(
                  left: 0,
                  right: 0,
                  top: 150,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.yellow,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('${_game.lastPlayedBy?.name ?? "某玩家"}打出: '),
                          MahjongTileWidget(tile: _pendingTile!, size: 30),
                        ],
                      ),
                    ),
                  ),
                ),

              // 人类玩家手牌
              Positioned(
                left: 0,
                right: 0,
                bottom: 20,
                child: _buildMyHand(),
              ),

              // 右侧动作菜单
              if (_currentPlayerIndex == 0 && !_isRollingDice && !_isDealing)
                _buildRightActionMenu(),

              // 当前玩家提示
              Positioned(
                left: 0,
                right: 0,
                bottom: 150,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '👤 ${_game.players[_currentPlayerIndex].name} 回合',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerSeats() {
    return Stack(
      children: [
        // 上家 (北家)
        Positioned(
          top: 20,
          left: 0,
          right: 0,
          child: Center(child: _buildPlayerAvatar(3)),
        ),
        // 下家 (南家)
        Positioned(
          bottom: 220,
          left: 0,
          right: 0,
          child: Center(child: _buildPlayerAvatar(1)),
        ),
        // 左家 (西家) - 再下移30%
        Positioned(
          top: 280,
          left: 20,
          child: _buildPlayerAvatar(2),
        ),
        // 自己 (东家) - 再下移30%
        Positioned(
          top: 280,
          right: 20,
          child: _buildPlayerAvatar(0),
        ),
      ],
    );
  }

  Widget _buildPlayerAvatar(int index) {
    final player = _game.players[index];
    final isCurrent = index == _currentPlayerIndex;
    final isDealer = index == _game.dealerIndex;
    final isLeftRight = index == 0 || index == 2; // 左右家需要特殊显示

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isCurrent ? Colors.green : Colors.black45,
        borderRadius: BorderRadius.circular(10),
        border: isCurrent ? Border.all(color: Colors.yellow, width: 2) : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 大头贴
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: _avatarColors[index],
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Center(
              child: Text(
                player.name[0],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isDealer) const Text('🎰 ', style: TextStyle(fontSize: 12)),
              Text(player.name, style: const TextStyle(color: Colors.white, fontSize: 12)),
            ],
          ),
          Text('🀤 ${player.handCount}', style: const TextStyle(color: Colors.white70, fontSize: 11)),
          if (player.meldCount > 0)
            Text('🎯 ${player.meldCount}', style: const TextStyle(color: Colors.orange, fontSize: 11)),
          
          // 打出牌的展示 - 在头像下方
          if (player.playedTiles.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.black38,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 每行显示4张，打出的牌
                  for (int i = 0; i < (player.playedTiles.length > 8 ? 8 : player.playedTiles.length); i += 4)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (int j = i; j < i + 4 && j < player.playedTiles.length; j++)
                          MahjongTileWidget(
                            tile: player.playedTiles[j],
                            size: 28, // 手牌的2/3大小
                            isGray: false,
                          ),
                      ],
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // 梯形麻将桌布
  Widget _buildMahjongTable() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;
        final tableHeight = screenHeight * 0.65;
        final bottomWidth = screenWidth;
        final topWidth = screenWidth * 0.75;
        
        return Positioned(
          left: (screenWidth - bottomWidth) / 2,
          bottom: 0,
          child: CustomPaint(
            size: Size(bottomWidth, tableHeight),
            painter: TrapezoidPainter(
              topWidth: topWidth,
              bottomWidth: bottomWidth,
              color: const Color(0xFF2E7D32),
            ),
          ),
        );
      },
    );
  }
  
  // 模拟牌墙 - 四方格，牌背朝上，纵深感
  Widget _buildWall() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;
        
        // 牌墙参数
        const int tilesPerSide = 6; // 每边6排
        const double maxTileSize = 35; // 最远端（最大）
        const double minTileSize = 25; // 最近端（最小）
        const double gap = 3;
        
        return Stack(
          children: [
            // 上边牌墙（北）- 从左到右，由远到近
            for (int i = 0; i < tilesPerSide; i++)
              Positioned(
                top: 150 - (i * 3), // 逐渐向下
                left: screenWidth * 0.35 + (i * (minTileSize + gap)),
                child: _buildWallTile(maxTileSize - (i * 2)),
              ),
            // 下边牌墙（南）- 从左到右，由近到远
            for (int i = 0; i < tilesPerSide; i++)
              Positioned(
                bottom: 250 + (i * 3),
                left: screenWidth * 0.35 + (i * (minTileSize + gap)),
                child: _buildWallTile(maxTileSize - (i * 2)),
              ),
            // 左边牌墙（西）- 从上到下
            for (int i = 0; i < tilesPerSide; i++)
              Positioned(
                left: 30 + (i * 3),
                top: screenHeight * 0.35 + (i * (minTileSize + gap)),
                child: Transform.rotate(
                  angle: 1.5708, // 90度
                  child: _buildWallTile(maxTileSize - (i * 2)),
                ),
              ),
            // 右边牌墙（东）- 从上到下
            for (int i = 0; i < tilesPerSide; i++)
              Positioned(
                right: 30 + (i * 3),
                top: screenHeight * 0.35 + (i * (minTileSize + gap)),
                child: Transform.rotate(
                  angle: 1.5708,
                  child: _buildWallTile(maxTileSize - (i * 2)),
                ),
              ),
            // 剩余牌数显示
            Positioned(
              top: 200,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '🀄 ${_game.remainingTiles}',
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
  
  // 牌背朝上的牌
  Widget _buildWallTile(double size) {
    return Container(
      width: size,
      height: size * 1.5,
      decoration: BoxDecoration(
        color: Colors.green.shade800,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.green.shade900, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 2,
            offset: const Offset(1, 1),
          ),
        ],
      ),
      child: Center(
        child: Text(
          '🀇',
          style: TextStyle(fontSize: size * 0.6, color: Colors.green.shade700),
        ),
      ),
    );
  }

  Widget _buildDiceSection() {
    return Center(
      child: GestureDetector(
        onTap: _onDiceClick,
        child: Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🎲 点击掷骰子', style: TextStyle(color: Colors.white, fontSize: 20)),
              const SizedBox(height: 20),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedBuilder(
                    animation: _diceController,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _diceController.value * 10,
                        child: const Text('🎲', style: TextStyle(fontSize: 60)),
                      );
                    },
                  ),
                  const SizedBox(width: 20),
                  AnimatedBuilder(
                    animation: _diceController,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: -_diceController.value * 10,
                        child: const Text('🎲', style: TextStyle(fontSize: 60)),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDealingAnimation() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🀄 发牌中...', style: TextStyle(color: Colors.white, fontSize: 24)),
            SizedBox(height: 10),
            SizedBox(
              width: 100,
              height: 20,
              child: LinearProgressIndicator(backgroundColor: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  // 倍数显示 - 右上角
  Widget _buildMultiplierDisplay() {
    final roundMult = _game.roundMultiplier;
    final globalMult = _game.multiplier;
    final totalMult = roundMult * globalMult;
    
    Color textColor;
    if (totalMult >= 8) {
      textColor = Colors.red;
    } else if (totalMult >= 4) {
      textColor = Colors.orange;
    } else if (totalMult >= 2) {
      textColor = Colors.yellow;
    } else {
      textColor = Colors.white;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: textColor, width: 2),
      ),
      child: Text(
        '×$totalMult',
        style: TextStyle(color: textColor, fontSize: 28, fontWeight: FontWeight.bold),
      ),
    );
  }
  
  // 庄家显示 - 左上角
  Widget _buildDealerInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(16)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🎲 庄 ', style: TextStyle(color: Colors.white70, fontSize: 12)),
          Text(_game.players[_game.dealerIndex].name, style: const TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
  
  Widget _buildGameInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🎲 庄家: ', style: TextStyle(color: Colors.white)),
          Text(
            _game.players[_game.dealerIndex].name,
            style: const TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold),
          ),
          if (_game.wildTile != null) ...[
            const SizedBox(width: 20),
            const Text('🃏 百搭: ', style: TextStyle(color: Colors.white)),
            MahjongTileWidget(tile: _game.wildTile!, size: 25),
          ],
          const SizedBox(width: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _game.roundMultiplier > 1 ? Colors.red : Colors.green,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '×${_game.roundMultiplier}',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          if (_game.multiplier > 1) ...[
            const SizedBox(width: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '全局×${_game.multiplier}',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMyHand() {
    final myPlayer = _game.players[0];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 门口牌（吃碰杠）
          if (myPlayer.allMelds.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: myPlayer.allMelds.map((meld) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Row(
                      children: meld.map((t) => MahjongTileWidget(
                        tile: t,
                        size: 30,
                        isGray: false,
                      )).toList(),
                    ),
                  )).toList(),
                ),
              ),
            ),
          const SizedBox(height: 8),
          // 手牌 - 完整显示，增加对比度
          HandTilesWidget(
            tiles: myPlayer.handTiles,
            tileSize: 50, // 增大尺寸
            selectable: _canHumanDiscard,
            lastDrawnTile: _lastDrawnTile,
            onTileTap: _playTile,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  // 玩家操作菜单 - 右下角，摸最大，其他围绕
  Widget _buildRightActionMenu() {
    return Positioned(
      right: 20,
      bottom: 20,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 摸 - 最大，在中间
            _buildActionBtn('摸', Colors.red, _drawCard, enabled: _canDraw, size: 'large'),
            const SizedBox(height: 8),
            // 其他按钮围绕在摸周围
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildActionBtn('吃', Colors.orange, _chow, enabled: _availableActions['chow'] ?? false, size: 'small'),
                const SizedBox(width: 4),
                _buildActionBtn('碰', Colors.blue, _pong, enabled: _availableActions['pong'] ?? false, size: 'small'),
                const SizedBox(width: 4),
                _buildActionBtn('胡', Colors.yellow, _hu, enabled: _availableActions['hu'] ?? false, size: 'small'),
                const SizedBox(width: 4),
                _buildActionBtn('杠', Colors.teal, _kong, enabled: _availableActions['kong'] ?? false, size: 'small'),
              ],
            ),
            const SizedBox(height: 8),
            _buildActionBtn('过', Colors.grey, _skip, enabled: _pendingTile != null, size: 'small'),
          ],
        ),
      ),
    );
  }

  Widget _buildActionBtn(String text, Color color, VoidCallback onPressed, {bool enabled = true, String size = 'small'}) {
    final isLarge = size == 'large';
    return ElevatedButton(
      onPressed: enabled ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: enabled ? color : Colors.grey,
        padding: isLarge 
            ? const EdgeInsets.symmetric(horizontal: 24, vertical: 16)
            : const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        minimumSize: isLarge ? const Size(70, 50) : const Size(40, 30),
      ),
      child: Text(text, style: TextStyle(fontSize: isLarge ? 18 : 12, color: Colors.white)),
    );
  }
}
