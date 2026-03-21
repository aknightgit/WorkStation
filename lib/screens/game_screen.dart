import 'dart:math' as math;
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
  late AnimationController _dealButtonController; // 发牌按钮跳动动画

  bool _isRollingDice = false;
  bool _isDealing = false;
  bool _hasDealt = false;
  bool _mustDiscardAfterClaim = false;
  int _diceClickCount = 0; // 掷骰子点击计数（支持双击）

  int _currentPlayerIndex = 0;
  Tile? _lastDrawnTile;
  Tile? _pendingTile;
  int? _pendingNextPlayerIndex;
  bool _isResolvingPending = false;
  String? _selectedAction; // 当前选中的动作（用于特效显示）

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
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..addStatusListener(_handleDiceAnimationStatus);

    _dealButtonController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true); // 循环跳动

    _startGame();
  }

  @override
  void dispose() {
    _diceController.removeStatusListener(_handleDiceAnimationStatus);
    _diceController.dispose();
    _dealButtonController.dispose();
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
      _pendingNextPlayerIndex = null;
      _isResolvingPending = false;
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
      _diceClickCount++;
      if (_diceClickCount >= 2) {
        // 双击后立即掷骰
        _diceClickCount = 0;
        _game.rollDice();
        _diceController.stop();
        _diceController.reset();
        if (!mounted) return;
        setState(() {
          _isRollingDice = false;
        });
      } else {
        // 第一次点击只是开始动画
        _diceController.forward(from: 0);
      }
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
      _pendingNextPlayerIndex = null;
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
      _pendingNextPlayerIndex = nextIndex;
      _lastDrawnTile = null;
      _mustDiscardAfterClaim = false;
      // AI出牌后，先给人类响应窗口（吃/碰/杠/胡）
      _currentPlayerIndex = 0;
    });

    _checkActions();
  }

  void _checkActions() {
    // 这里只给人类玩家（0号位）计算动作
    final player = _game.players[0];
    final hasPendingTile = _pendingTile != null;

    final canPong = hasPendingTile ? _game.canPong(player, _pendingTile!) : false;
    final canChow = hasPendingTile ? _game.canChow(player, _pendingTile!) : false;
    final canExposedKong = hasPendingTile ? _game.canExposedKong(player, _pendingTile!) : false;
    final canRon = hasPendingTile ? _game.canRonWithTile(player, _pendingTile!) : false;

    // 暗杠/自摸只允许在“自己摸牌后的回合”触发，不在响应他人出牌窗口触发
    final canHiddenKong = !hasPendingTile && !_mustDiscardAfterClaim && _game.canHiddenKong(player);
    final canSelfDrawHu = !hasPendingTile && !_mustDiscardAfterClaim && _game.canHu(
      player,
      newTile: _lastDrawnTile,
      isSelfDrawn: _lastDrawnTile != null,
    );

    setState(() {
      _availableActions['pong'] = canPong;
      _availableActions['chow'] = canChow;
      _availableActions['kong'] = hasPendingTile ? canExposedKong : canHiddenKong;
      _availableActions['hu'] = hasPendingTile ? canRon : canSelfDrawHu;
    });

    if (hasPendingTile && !(canPong || canChow || canExposedKong || canRon)) {
      _autoPassPendingTile();
    }
  }

  Future<void> _autoPassPendingTile() async {
    if (_isResolvingPending || _pendingTile == null) return;
    _isResolvingPending = true;

    await Future.delayed(const Duration(milliseconds: 250));
    if (!mounted) return;

    // 期间若玩家已经操作（如吃/碰/胡），则不再自动过牌
    if (_pendingTile != null) {
      await _passPendingTileToNextPlayer();
    }

    _isResolvingPending = false;
  }

  Future<void> _passPendingTileToNextPlayer() async {
    final nextIndex = _pendingNextPlayerIndex;
    if (nextIndex == null) return;

    setState(() {
      _pendingTile = null;
      _pendingNextPlayerIndex = null;
      _lastDrawnTile = null;
      _mustDiscardAfterClaim = false;
      _currentPlayerIndex = nextIndex;
      _availableActions = {
        'chow': false,
        'pong': false,
        'kong': false,
        'hu': false,
      };
    });

    await Future.delayed(const Duration(milliseconds: 120));
    if (!mounted) return;
    _doDrawOrPlay();
  }

  Future<void> _nextTurn() async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    setState(() {
      _currentPlayerIndex = (_currentPlayerIndex + 1) % 4;
      _pendingTile = null;
      _pendingNextPlayerIndex = null;
      _lastDrawnTile = null;
      _mustDiscardAfterClaim = false;
      _availableActions = {
        'chow': false,
        'pong': false,
        'kong': false,
        'hu': false,
      };
    });
    _doDrawOrPlay();
  }

  void _playTile(Tile tile) {
    if (!_canHumanDiscard) return;

    final player = _game.players[_currentPlayerIndex];
    _game.playTile(player, tile);

    setState(() {
      _lastDrawnTile = null;
      _pendingTile = null;
      _pendingNextPlayerIndex = null;
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
      _pendingNextPlayerIndex = null;
      _lastDrawnTile = null;
      _mustDiscardAfterClaim = true;
      _availableActions = {
        'chow': false,
        'pong': false,
        'kong': false,
        'hu': false,
      };
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
      _pendingNextPlayerIndex = null;
      _lastDrawnTile = null;
      _mustDiscardAfterClaim = true;
      _availableActions = {
        'chow': false,
        'pong': false,
        'kong': false,
        'hu': false,
      };
    });
  }

  void _hiddenKong() {
    final player = _game.players[_currentPlayerIndex];
    final meld = _game.hiddenKong(player);
    if (meld == null) return;

    setState(() {
      _pendingTile = null;
      _pendingNextPlayerIndex = null;
      _lastDrawnTile = null;
      _mustDiscardAfterClaim = false;
      _availableActions = {
        'chow': false,
        'pong': false,
        'kong': false,
        'hu': false,
      };
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
        _pendingNextPlayerIndex = null;
        _lastDrawnTile = null;
        _mustDiscardAfterClaim = false;
        _availableActions = {
          'chow': false,
          'pong': false,
          'kong': false,
          'hu': false,
        };
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
      _pendingNextPlayerIndex = null;
      _lastDrawnTile = null;
      _mustDiscardAfterClaim = false;
      _availableActions = {
        'chow': false,
        'pong': false,
        'kong': false,
        'hu': false,
      };
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

    if (hadPendingTile) {
      _passPendingTileToNextPlayer();
      return;
    }

    setState(() {
      _pendingTile = null;
      _pendingNextPlayerIndex = null;
      _lastDrawnTile = null;
      _mustDiscardAfterClaim = false;
    });
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

              // 翻倍提示（右上角醒目显示）
              _buildMultiplierDisplay(),

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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 骰子区域
          GestureDetector(
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
                  Text(
                    _diceClickCount > 0 ? '🎲 点击两次完成' : '🎲 点击掷骰子',
                    style: const TextStyle(color: Colors.white, fontSize: 20),
                  ),
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
          const SizedBox(width: 20),
          // 发牌按钮 - 带跳动特效
          if (_game.diceRolled && !_hasDealt)
            AnimatedBuilder(
              animation: _dealButtonController,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1.0 + (_dealButtonController.value * 0.15), // 15% 跳动幅度
                  child: GestureDetector(
                    onTap: _startDealing,
                    child: Container(
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4CAF50), Color(0xFF8BC34A)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.5),
                            blurRadius: 15,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('🀄', style: TextStyle(fontSize: 50)),
                          SizedBox(height: 8),
                          Text('开始发牌', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
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
        ],
      ),
    );
  }

  // 翻倍提示 - 右上角独立显示，更醒目
  Widget _buildMultiplierDisplay() {
    if (!_hasDealt) return const SizedBox.shrink();
    
    final roundMult = _game.roundMultiplier;
    final globalMult = _game.multiplier;
    final totalMult = roundMult * globalMult;
    
    if (totalMult <= 1) return const SizedBox.shrink();
    
    return Positioned(
      top: 20,
      right: 20,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: totalMult >= 8 
                ? [Colors.red, Colors.deepOrange]
                : totalMult >= 4 
                    ? [Colors.orange, Colors.amber]
                    : [Colors.green, Colors.lightGreen],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: (totalMult >= 8 ? Colors.red : totalMult >= 4 ? Colors.orange : Colors.green)
                  .withOpacity(0.6),
              blurRadius: 15,
              spreadRadius: 3,
            ),
          ],
          border: Border.all(
            color: Colors.white.withOpacity(0.8),
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star, color: Colors.white, size: 24),
            const SizedBox(width: 8),
            Text(
              '本局倍数: ×$totalMult',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    color: Colors.black54,
                    blurRadius: 4,
                    offset: Offset(1, 1),
                  ),
                ],
              ),
            ),
            if (globalMult > 1) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '(全局×$globalMult)',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
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
    // 检查是否有任何可用动作
    final hasAnyAction = (_canDraw) || 
        (_availableActions['chow'] ?? false) || 
        (_availableActions['pong'] ?? false) || 
        (_availableActions['hu'] ?? false) || 
        (_availableActions['kong'] ?? false) || 
        (_pendingTile != null);
    
    if (!hasAnyAction) return const SizedBox.shrink();

    // 动作按钮配置 - 圆形排列
    final actions = [
      {'key': 'draw', 'label': '摸', 'color': const Color(0xFF2196F3), 'action': _drawCard, 'enabled': _canDraw},
      {'key': 'chow', 'label': '吃', 'color': const Color(0xFFFF9800), 'action': _chow, 'enabled': _availableActions['chow'] ?? false},
      {'key': 'pong', 'label': '碰', 'color': const Color(0xFF4CAF50), 'action': _pong, 'enabled': _availableActions['pong'] ?? false},
      {'key': 'hu', 'label': '胡', 'color': const Color(0xFFF44336), 'action': _hu, 'enabled': _availableActions['hu'] ?? false},
      {'key': 'kong', 'label': '杠', 'color': const Color(0xFF009688), 'action': _kong, 'enabled': _availableActions['kong'] ?? false},
      {'key': 'skip', 'label': '过', 'color': const Color(0xFF9E9E9E), 'action': _skip, 'enabled': _pendingTile != null},
    ];

    // 圆形排列 - 6个按钮围绕中心
    return Positioned(
      right: 30,
      bottom: 30,
      child: SizedBox(
        width: 180,
        height: 180,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 半透明背景圆
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withOpacity(0.6),
              ),
            ),
            // 按钮容器
            ...actions.asMap().entries.map((entry) {
              final index = entry.key;
              final action = entry.value;
              final enabled = action['enabled'] as bool;
              if (!enabled) return const SizedBox.shrink();
              
              // 计算圆形位置 (60度间隔，-90度从顶部开始)
              final angle = (index * 60 - 90) * math.pi / 180;
              final radius = 55.0;
              final dx = radius * math.cos(angle);
              final dy = radius * math.sin(angle);
              
              return Transform.translate(
                offset: Offset(dx, dy),
                child: _CircularActionButton(
                  key: ValueKey(action['key']),
                  label: action['label'] as String,
                  color: action['color'] as Color,
                  onPressed: action['action'] as VoidCallback,
                  isSelected: _selectedAction == action['key'],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // 圆形动作按钮组件 - 带悬停放大和点击特效
  Widget _CircularActionButton({
    required String label,
    required Color color,
    required VoidCallback onPressed,
    required bool isSelected,
  }) {
    return _AnimatedCircleButton(
      label: label,
      color: color,
      onPressed: () {
        setState(() {
          _selectedAction = label; // 显示点击特效
        });
        // 延迟执行动作，让特效先显示
        Future.delayed(const Duration(milliseconds: 150), () {
          if (mounted) {
            setState(() {
              _selectedAction = null;
            });
            onPressed();
          }
        });
      },
      isSelected: isSelected,
    );
  }
}

// 圆形按钮 with 悬停放大效果
class _AnimatedCircleButton extends StatefulWidget {
  final String label;
  final Color color;
  final VoidCallback onPressed;
  final bool isSelected;

  const _AnimatedCircleButton({
    required this.label,
    required this.color,
    required this.onPressed,
    required this.isSelected,
  });

  @override
  State<_AnimatedCircleButton> createState() => _AnimatedCircleButtonState();
}

class _AnimatedCircleButtonState extends State<_AnimatedCircleButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _controller.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          final scale = _scaleAnimation.value;
          // 如果被选中(点击特效)，额外放大
          final selectedScale = widget.isSelected ? 1.3 : 1.0;
          return Transform.scale(
            scale: scale * selectedScale,
            child: GestureDetector(
              onTap: widget.onPressed,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color,
                  boxShadow: [
                    BoxShadow(
                      color: widget.color.withOpacity(0.5),
                      blurRadius: _isHovered ? 15 : 8,
                      spreadRadius: _isHovered ? 3 : 1,
                    ),
                    if (widget.isSelected)
                      BoxShadow(
                        color: Colors.white.withOpacity(0.8),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                  ],
                  border: widget.isSelected
                      ? Border.all(color: Colors.white, width: 3)
                      : null,
                ),
                child: Center(
                  child: Text(
                    widget.label,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 2,
                          offset: const Offset(1, 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
