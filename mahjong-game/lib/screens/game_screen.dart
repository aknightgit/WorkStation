import 'package:flutter/material.dart';
import '../models/tile_model.dart';
import '../models/player_model.dart';
import '../game_logic/mahjong_game.dart';
import '../widgets/tile_widget.dart';

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

  void _handleDiceAnimationStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed || !_isRollingDice || _game.diceRolled) {
      return;
    }

    _game.rollDice();
    _diceController.stop();
    _diceController.reset();

    if (!mounted) return;
    setState(() {
      _isRollingDice = false;
    });
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
    if (!_game.diceRolled && _isRollingDice) {
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
              Positioned(
                top: 80,
                left: 0,
                right: 0,
                child: Center(child: _buildGameInfo()),
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
        // 左家 (西家)
        Positioned(
          top: 200,
          left: 20,
          child: _buildPlayerAvatar(2),
        ),
        // 自己 (东家)
        Positioned(
          top: 200,
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
          Text('🀄 ${player.handCount}', style: const TextStyle(color: Colors.white70, fontSize: 11)),
          if (player.meldCount > 0)
            Text('🎯 ${player.meldCount}', style: const TextStyle(color: Colors.orange, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildWall() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.black26,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🀄 牌墙', style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 8),
            Text(
              '${_game.remainingTiles} 张',
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (myPlayer.allMelds.isNotEmpty)
            SizedBox(
              height: 35,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: myPlayer.allMelds.map((meld) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Row(
                    children: meld.map((t) => MahjongTileWidget(
                      tile: t,
                      size: 25,
                      isGray: true,
                    )).toList(),
                  ),
                )).toList(),
              ),
            ),
          const SizedBox(height: 5),
          HandTilesWidget(
            tiles: myPlayer.handTiles,
            tileSize: 45,
            selectable: _canHumanDiscard,
            lastDrawnTile: _lastDrawnTile,
            onTileTap: _playTile,
          ),
        ],
      ),
    );
  }

  Widget _buildRightActionMenu() {
    return Positioned(
      right: 20,
      top: 200,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildActionBtn('摸', Colors.blue, _drawCard, enabled: _canDraw),
            const SizedBox(height: 4),
            _buildActionBtn('吃', Colors.orange, _chow, enabled: _availableActions['chow'] ?? false),
            _buildActionBtn('碰', Colors.blue, _pong, enabled: _availableActions['pong'] ?? false),
            _buildActionBtn('胡', Colors.red, _hu, enabled: _availableActions['hu'] ?? false),
            _buildActionBtn('杠', Colors.teal, _kong, enabled: _availableActions['kong'] ?? false),
            _buildActionBtn('过', Colors.grey, _skip, enabled: _pendingTile != null),
          ],
        ),
      ),
    );
  }

  Widget _buildActionBtn(String text, Color color, VoidCallback onPressed, {bool enabled = true}) {
    return ElevatedButton(
      onPressed: enabled ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: enabled ? color : Colors.grey,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        minimumSize: const Size(50, 36),
      ),
      child: Text(text, style: const TextStyle(fontSize: 14)),
    );
  }
}
