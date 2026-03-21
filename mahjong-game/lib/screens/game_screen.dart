import 'package:flutter/material.dart';
import '../models/tile_model.dart';
import '../models/player_model.dart';
import '../game_logic/mahjong_game.dart';
import '../widgets/tile_widget.dart';

// 梯形麻将桌布Painter
class TrapezoidPainter extends CustomPainter {
  final double topWidth;
  final double bottomWidth;
  final Color topColor;
  final Color bottomColor;

  TrapezoidPainter({
    required this.topWidth,
    required this.bottomWidth,
    required this.topColor,
    required this.bottomColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final height = size.height;
    final topOffset = (bottomWidth - topWidth) / 2;

    final path = Path()
      ..moveTo(topOffset, 0)
      ..lineTo(topOffset + topWidth, 0)
      ..lineTo(bottomWidth, height)
      ..lineTo(0, height)
      ..close();

    final rect = Rect.fromLTWH(0, 0, bottomWidth, height);
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [topColor, bottomColor],
      ).createShader(rect)
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, paint);

    final borderPaint = Paint()
      ..color = Colors.green.shade900
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
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
  bool _waitingSecondRoll = false;
  
  void _handleDiceAnimationStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed || !_isRollingDice) {
      return;
    }

    _game.rollDice();
    _diceClickCount++;
    _diceController.stop();
    _diceController.reset();

    if (_diceClickCount == 1) {
      // 第一次掷骰结束，可直接发牌，也可再掷一次
      _game.diceRolled = true;
      _isRollingDice = false;
      _waitingSecondRoll = true;
    } else {
      // 第二次掷骰结束
      _game.diceRolled = true;
      _isRollingDice = false;
      _diceClickCount = 0;
      _waitingSecondRoll = false;
    }

    if (!mounted) return;
    setState(() {});
  }

  void _startGame() {
    _game.initGame();

    setState(() {
      _diceClickCount = 0;
      _waitingSecondRoll = false;
      _isRollingDice = false;
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
    if (_isRollingDice) return;

    if (_diceClickCount == 0) {
      setState(() {
        _game.diceRolled = false;
        _isRollingDice = true;
      });
      _diceController.forward(from: 0);
      return;
    }

    if (_waitingSecondRoll) {
      setState(() {
        _game.diceRolled = false;
        _waitingSecondRoll = false;
        _isRollingDice = true;
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

    // 记录打出的牌
    setState(() {
      _pendingTile = playedTile;
      _lastDrawnTile = null;
    });

    // 检查所有其他玩家是否可以响应（吃/碰/杠/胡）
    final nextIndex = (_currentPlayerIndex + 1) % 4;
    setState(() {
      _mustDiscardAfterClaim = false;
      _currentPlayerIndex = nextIndex;
    });

    // 立即检查玩家0是否可以直接响应（别人打牌时）
    if (nextIndex != 0) {
      _checkActions();
      // 如果玩家0可以响应，暂停游戏等待玩家操作
      if (_availableActions.values.any((v) => v)) {
        // 有可用的响应，等待玩家操作，不继续AI回合
        return;
      }
      // 如果玩家0不能响应，继续游戏
    }

    if (nextIndex == 0) {
      _checkActions();
      return;
    }

    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    _doDrawOrPlay();
  }

  void _checkActions() {
    final player = _game.players[0]; // 总是检查人类玩家
    
    // 优先响应：检查别人打牌时我是否可以吃/碰/杠/胡
    final canPong = _pendingTile != null ? _game.canPong(player, _pendingTile!) : false;
    final canChow = _pendingTile != null ? _game.canChow(player, _pendingTile!) : false;
    final canExposedKong = _pendingTile != null ? _game.canExposedKong(player, _pendingTile!) : false;
    final canRon = _pendingTile != null ? _game.canRonWithTile(player, _pendingTile!) : false;
    
    // 自己摸牌后的响应
    final hiddenKong = !_mustDiscardAfterClaim && _game.canHiddenKong(player);
    final selfDrawHu = !_mustDiscardAfterClaim && _game.canHu(
      player,
      newTile: _lastDrawnTile,
      isSelfDrawn: _lastDrawnTile != null,
    );

    setState(() {
      _availableActions['pong'] = canPong;
      _availableActions['chow'] = canChow;
      _availableActions['kong'] = canExposedKong || hiddenKong;
      _availableActions['hu'] = canRon || selfDrawHu;
    });
  }
  
  // 检查是否有可用的响应（别人打牌时我可以吃/碰/杠/胡）
  bool _hasResponseAvailable() {
    return _pendingTile != null && 
        (_availableActions['chow'] == true || 
         _availableActions['pong'] == true || 
         _availableActions['kong'] == true || 
         _availableActions['hu'] == true);
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

              // 对手手牌（牌背）
              _buildOpponentHands(),

              // 门口牌（吃碰杠）
              _buildOpponentMelds(),

              // 牌墙
              _buildWall(),
              // 牌桌中央：打出的牌
              _buildPlayedTiles(),

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


              // 人类玩家手牌
              Positioned(
                left: 0,
                right: 0,
                bottom: 20,
                child: _buildMyHand(),
              ),

              // 右侧动作菜单 - 自己回合 或 有响应可使用时显示
              if ((_currentPlayerIndex == 0 || _hasResponseAvailable()) && !_isRollingDice && !_isDealing)
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final h = constraints.maxHeight;
        final topY = 20.0;
        final bottomY = h * 0.2;
        final sideTop = h * 0.55; // 左右两家下移

        return Stack(
          children: [
            // 对家 (西家) - 顶部
            Positioned(
              top: topY,
              left: 0,
              right: 0,
              child: Center(child: _buildPlayerAvatar(2)),
            ),
            // 自己 (东家) - 底部
            Positioned(
              bottom: bottomY,
              left: 0,
              right: 0,
              child: Center(child: _buildPlayerAvatar(0)),
            ),
            // 左家 (北家)
            Positioned(
              top: sideTop,
              left: 20,
              child: _buildPlayerAvatar(3),
            ),
            // 右家 (南家)
            Positioned(
              top: sideTop,
              right: 20,
              child: _buildPlayerAvatar(1),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPlayerAvatar(int index) {
    final player = _game.players[index];
    final isCurrent = index == _currentPlayerIndex;
    final isDealer = index == _game.dealerIndex;

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
          
        ],
      ),
    );
  }

  // 对手手牌（牌背）
  Widget _buildOpponentHands() {
    return Stack(
      children: [
        // 对家（上方） - 玩家2
        Positioned(
          top: 110,
          left: 0,
          right: 0,
          child: Center(
            child: _buildBackRow(_game.players[2].handCount, 18),
          ),
        ),
        // 左家（左侧） - 玩家3
        Positioned(
          left: 40,
          top: 250,
          child: _buildBackColumn(_game.players[3].handCount, 16, rotate: true),
        ),
        // 右家（右侧） - 玩家1
        Positioned(
          right: 40,
          top: 250,
          child: _buildBackColumn(_game.players[1].handCount, 16, rotate: true),
        ),
      ],
    );
  }

  // 门口牌（吃碰杠）
  Widget _buildOpponentMelds() {
    return Stack(
      children: [
        // 对家门口牌
        if (_game.players[2].allMelds.isNotEmpty)
          Positioned(
            top: 150,
            left: 0,
            right: 0,
            child: Center(child: _buildMeldRow(_game.players[2], 22)),
          ),
        // 左家门口牌
        if (_game.players[3].allMelds.isNotEmpty)
          Positioned(
            left: 80,
            top: 300,
            child: _buildMeldColumn(_game.players[3], 20, rotate: true),
          ),
        // 右家门口牌
        if (_game.players[1].allMelds.isNotEmpty)
          Positioned(
            right: 80,
            top: 300,
            child: _buildMeldColumn(_game.players[1], 20, rotate: true),
          ),
      ],
    );
  }

  Widget _buildBackRow(int count, double size) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count.clamp(0, 14), (i) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 1),
        child: MahjongTileWidget(
          tile: Tile(type: TileType.wan1, id: -1),
          size: size,
          showBack: true,
        ),
      )),
    );
  }

  Widget _buildBackColumn(int count, double size, {bool rotate = false}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count.clamp(0, 14), (i) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 1),
        child: rotate
            ? Transform.rotate(
                angle: 1.5708,
                child: MahjongTileWidget(
                  tile: Tile(type: TileType.wan1, id: -1),
                  size: size,
                  showBack: true,
                ),
              )
            : MahjongTileWidget(
                tile: Tile(type: TileType.wan1, id: -1),
                size: size,
                showBack: true,
              ),
      )),
    );
  }

  Widget _buildMeldRow(Player player, double size) {
    final tiles = <Widget>[];
    for (final meld in player.exposedMelds) {
      for (final t in meld) {
        tiles.add(Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1),
          child: MahjongTileWidget(tile: t, size: size),
        ));
      }
    }
    for (final meld in player.concealedMelds) {
      for (final t in meld) {
        tiles.add(Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1),
          child: MahjongTileWidget(tile: t, size: size, showBack: true),
        ));
      }
    }
    return Row(mainAxisSize: MainAxisSize.min, children: tiles);
  }

  Widget _buildMeldColumn(Player player, double size, {bool rotate = false}) {
    final tiles = <Widget>[];
    void addTile(Tile t, {bool back = false}) {
      tiles.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 1),
        child: rotate
            ? Transform.rotate(
                angle: 1.5708,
                child: MahjongTileWidget(tile: t, size: size, showBack: back),
              )
            : MahjongTileWidget(tile: t, size: size, showBack: back),
      ));
    }
    for (final meld in player.exposedMelds) {
      for (final t in meld) {
        addTile(t, back: false);
      }
    }
    for (final meld in player.concealedMelds) {
      for (final t in meld) {
        addTile(t, back: true);
      }
    }
    return Column(mainAxisSize: MainAxisSize.min, children: tiles);
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
              topColor: const Color(0xFF2E7D32),
              bottomColor: const Color(0xFF1B5E20),
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
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        const stacksPerSide = 18;
        const gap = 2.0;

        final sizeByWidth = (w * 0.62 - gap * (stacksPerSide - 1)) / stacksPerSide;
        final sizeByHeight = (h * 0.36 - gap * (stacksPerSide - 1)) / stacksPerSide;
        final size = sizeByWidth.clamp(16.0, 28.0) < sizeByHeight
            ? sizeByWidth.clamp(16.0, 28.0)
            : sizeByHeight.clamp(16.0, 28.0);

        return Stack(
          children: [
            Positioned(
              top: h * 0.16,
              left: w * 0.14,
              right: w * 0.14,
              child: Center(child: _buildWallRow(stacksPerSide, size)),
            ),
            Positioned(
              bottom: h * 0.28,
              left: w * 0.14,
              right: w * 0.14,
              child: Center(child: _buildWallRow(stacksPerSide, size)),
            ),
            Positioned(
              left: w * 0.1,
              top: h * 0.24,
              child: _buildWallColumn(stacksPerSide, size),
            ),
            Positioned(
              right: w * 0.1,
              top: h * 0.24,
              child: _buildWallColumn(stacksPerSide, size),
            ),
            Positioned(
              top: h * 0.26,
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

  Widget _buildWallRow(int count, double size) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        count,
        (i) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1),
          child: _buildWallStack(size),
        ),
      ),
    );
  }

  Widget _buildWallColumn(int count, double size) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        count,
        (i) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 1),
          child: Transform.rotate(
            angle: 1.5708,
            child: _buildWallStack(size),
          ),
        ),
      ),
    );
  }

  Widget _buildWallStack(double size) {
    final backTile = MahjongTileWidget(
      tile: Tile(type: TileType.wan1, id: -1),
      size: size,
      showBack: true,
    );
    return SizedBox(
      width: size,
      height: size * 1.5 * 2 + 2,
      child: Stack(
        children: [
          Positioned(top: 0, child: backTile),
          Positioned(top: size * 0.35, child: backTile),
        ],
      ),
    );
  }

  // 牌桌中央：各家打出的牌（中央方阵）
  Widget _buildPlayedTiles() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final tileSize = (w * 0.04).clamp(18.0, 26.0);

        return Stack(
          children: [
            if (_game.players[0].playedTiles.isNotEmpty)
              Align(
                alignment: const Alignment(0, 0.35),
                child: _buildPlayedGrid(_game.players[0], tileSize, rotate: 0),
              ),
            if (_game.players[3].playedTiles.isNotEmpty)
              Align(
                alignment: const Alignment(0, -0.35),
                child: _buildPlayedGrid(_game.players[3], tileSize, rotate: 0),
              ),
            if (_game.players[2].playedTiles.isNotEmpty)
              Align(
                alignment: const Alignment(-0.6, 0),
                child: _buildPlayedGrid(_game.players[2], tileSize, rotate: 1.5708),
              ),
            if (_game.players[1].playedTiles.isNotEmpty)
              Align(
                alignment: const Alignment(0.6, 0),
                child: _buildPlayedGrid(_game.players[1], tileSize, rotate: -1.5708),
              ),
          ],
        );
      },
    );
  }

  Widget _buildPlayedGrid(Player player, double tileSize, {double rotate = 0}) {
    final isLastPlayed = _game.lastPlayedTile != null &&
        player.playedTiles.isNotEmpty &&
        player.playedTiles.last.id == _game.lastPlayedTile!.id;

    const columns = 6;
    const spacing = 2.0;
    final tiles = player.playedTiles;

    final grid = Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(8),
        border: isLastPlayed ? Border.all(color: Colors.red, width: 2) : null,
      ),
      child: SizedBox(
        width: columns * tileSize + (columns - 1) * spacing,
        child: Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: List.generate(tiles.length, (i) {
            return MahjongTileWidget(
              tile: tiles[i],
              size: tileSize,
              isSelected: i == tiles.length - 1 && isLastPlayed,
            );
          }),
        ),
      ),
    );

    if (rotate == 0) return grid;
    return Transform.rotate(angle: rotate, child: grid);
  }
  
  Widget _buildDiceSection() {
    final diceLabel = _diceClickCount == 0
        ? '🎲 点击掷骰子'
        : (_waitingSecondRoll ? '🎲 可再掷一次（可选）' : '🎲 掷骰中...');

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
              Text(diceLabel, style: const TextStyle(color: Colors.white, fontSize: 20)),
              const SizedBox(height: 14),
              if (_diceClickCount > 0)
                Text(
                  '点数：${_game.diceValues[0]} + ${_game.diceValues[1]}',
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
              const SizedBox(height: 16),
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
