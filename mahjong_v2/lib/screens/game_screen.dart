import 'package:flutter/material.dart';
import 'package:mahjong_v2/game_logic/mahjong_game.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late MahjongGame _game;
  
  // UI 状态
  int? selectedTileIndex;
  Tile? pendingTile;
  bool isRolling = false;
  
  // 响应按钮状态
  bool canChow = false;
  bool canPong = false;
  bool canKong = false;
  bool canHu = false;
  bool canRebel = false;

  static const int stacksPerSide = 18;
  // 手牌尺寸（根据屏幕调整）
  static double tileWidth = 40.0;
  static double tileHeight = 54.0;
  
  // 骰子动画
  double _diceAnimationValue = 0.0;

  @override
  void initState() {
    super.initState();
    _game = MahjongGame();
  }

  // 掷骰子
  void _onDiceTap() {
    setState(() {
      isRolling = true;
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _game.rollDice();
        isRolling = false;
        // 发牌
        _game.deal();
        // 检查五毒散
        canRebel = _game.checkWuDuSan();
        // 检查当前玩家响应
        _checkActions();
      });
    });
  }
  
  // 发牌按钮
  Widget _buildDealButton() {
    return Center(
      child: GestureDetector(
        onTap: _onDealTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)]),
            borderRadius: BorderRadius.circular(25),
            boxShadow: [BoxShadow(color: Colors.green.withOpacity(0.5), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: const Text(
            '发牌',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ),
    );
  }
  
  void _onDealTap() {
    setState(() {
      _game.deal();
      canRebel = _game.checkWuDuSan();
      _checkActions();
    });
  }

  // 检查响应
  void _checkActions() {
    final player = _game.players[_game.currentPlayerIndex];
    pendingTile = _game.pendingTile;
    if (pendingTile != null) {
      canPong = _game.canPong(player);
      canKong = _game.canKong(player);
      canHu = _game.canHu(player);
      canChow = _game.canChow(player);
    } else {
      canPong = false;
      canKong = false;
      canHu = false;
      canChow = false;
    }
  }

  // 摸牌
  void _drawTile() {
    final player = _game.players[_game.currentPlayerIndex];
    final tile = _game.drawTile(player);
    if (tile == null) {
      // 流局
      return;
    }
    setState(() {
      // 检查是否能胡
      canHu = _game.canHu(player);
      // 检查五毒散（首轮）
      if (_game.remainingTiles > 130) {
        canRebel = player.isWuDuSan;
      }
    });
  }

  // 打牌
  void _playTile(int index) {
    final player = _game.players[_game.currentPlayerIndex];
    final tile = player.handTiles[index];
    _game.playTile(player, tile);
    _game.lastPlayedTile = tile;
    _game.pendingTile = tile;
    setState(() {
      selectedTileIndex = null;
      // 检查响应
      _checkActions();
      if (!canPong && !canKong && !canHu && !canChow) {
        // 无响应，继续下一家
        _game.nextPlayer();
        pendingTile = null;
      }
    });
  }

  // 碰
  void _pong() {
    if (!canPong) return;
    final player = _game.players[0];
    final tile = pendingTile!;
    // 找到两张相同的牌
    final indices = <int>[];
    for (int i = 0; i < player.handTiles.length; i++) {
      if (player.handTiles[i].type == tile.type && player.handTiles[i].number == tile.number) {
        indices.add(i);
        if (indices.length == 2) break;
      }
    }
    // 移除两张并加入碰牌组
    for (int i = indices.length - 1; i >= 0; i--) {
      player.handTiles.removeAt(indices[i]);
    }
    player.melds.add([tile, tile, tile]);
    // 摸牌
    _drawTile();
  }

  // 杠
  void _kong() {
    if (!canKong) return;
    // 类似碰的实现
    _drawTile();
  }

  // 吃
  void _chow() {
    if (!canChow) return;
    // 实现吃牌逻辑
    _drawTile();
  }

  // 胡
  void _hu() {
    if (!canHu) return;
    // 胡牌结算
    setState(() {
      _game.phase = GamePhase.scoring;
    });
  }

  // 造反
  void _rebel() {
    if (!canRebel) return;
    // 造反结算
    setState(() {
      _game.globalMultiplier = (_game.globalMultiplier * 2).clamp(1, 8);
      _game.dealerIndex = _game.currentPlayerIndex;
      _game.phase = GamePhase.scoring;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D1B2A), Color(0xFF1B263B)],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth;
              final h = constraints.maxHeight;
              
              // 调整尺寸
              _adjustSizes(w, h);
              
              // 桌布：上下撑开100%
              final tableHeight = h;
              final tableTop = 0.0;
              final bottomWidth = w * 0.90;
              final topWidth = w * 0.50;
              
              return Stack(
                children: [
                  // 梯形桌布
                  Positioned(
                    left: (w - bottomWidth) / 2,
                    top: tableTop,
                    child: CustomPaint(
                      size: Size(bottomWidth, tableHeight),
                      painter: TrapezoidPainter(
                        topWidth: topWidth,
                        bottomWidth: bottomWidth,
                        topColor: const Color(0xFF5C7FA5),
                        bottomColor: const Color(0xFF3D5A80),
                      ),
                    ),
                  ),
                  
                  // 牌墙 - 离桌布边25%
                  // 上牌墙
                  Positioned(left: w * 0.25, right: w * 0.25, top: tableTop + h * 0.08, child: _buildWallRow(stacksPerSide)),
                  // 下牌墙
                  Positioned(left: w * 0.25, right: w * 0.25, bottom: h * 0.08, child: _buildWallRow(stacksPerSide)),
                  // 左牌墙（斜向）
                  Positioned(left: w * 0.12, top: tableTop + h * 0.25, bottom: h * 0.25, child: Transform.rotate(angle: 0.15, child: _buildWallColumn(stacksPerSide))),
                  // 右牌墙（斜向）
                  Positioned(right: w * 0.12, top: tableTop + h * 0.25, bottom: h * 0.25, child: Transform.rotate(angle: -0.15, child: _buildWallColumn(stacksPerSide))),
                  
                  // 弃牌区 - 中央6x6
                  Positioned(left: w * 0.25, right: w * 0.25, top: tableTop + tableHeight * 0.30, bottom: tableTop + tableHeight * 0.70, child: _buildDiscardArea()),
                  
                  // 头像 - 四角位置
                  Positioned(top: tableTop - 30, left: 0, right: 0, child: Center(child: _buildAvatar(2))),
                  Positioned(left: w * 0.08, top: tableTop + tableHeight * 0.4, child: _buildAvatar(3)),
                  Positioned(right: w * 0.08, top: tableTop + tableHeight * 0.4, child: _buildAvatar(1)),
                  Positioned(bottom: h - (tableTop + tableHeight) + 8, left: 0, right: 0, child: Center(child: _buildAvatar(0))),
                  
                  // 顶部信息
                  Positioned(top: 80, left: 20, child: _buildDealerInfo()),
                  Positioned(top: 80, right: 20, child: _buildMultiplier()),
                  
                  // 掷骰子 + 发牌按钮
                  if (_game.phase == GamePhase.waiting || _game.phase == GamePhase.diceRolling)
                    Positioned(left: w * 0.40, right: w * 0.40, top: tableTop + tableHeight * 0.45, child: _buildDiceSection()),
                  
                  // 发牌按钮
                  if (_game.phase == GamePhase.diceRolling)
                    Positioned(left: w * 0.40, right: w * 0.40, top: tableTop + tableHeight * 0.45 + 100, child: _buildDealButton()),
                  
                  // 手牌 - 底部居中，紧贴桌布
                  if (_game.phase == GamePhase.playing)
                    Positioned(left: 20, right: 20, bottom: h - (tableTop + tableHeight) + 20, child: _buildMyHand()),
                  
                  // 操作按钮
                  if (_game.phase == GamePhase.playing)
                    Positioned(right: 20, bottom: 40, child: _buildActionButtons()),
                  
                  // 造反按钮
                  if (canRebel)
                    Positioned(top: 130, left: 0, right: 0, child: Center(child: _buildRebelButton())),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildWallRow(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) => Container(
        width: tileWidth * 0.6, height: tileHeight * 0.6,
        margin: const EdgeInsets.symmetric(horizontal: 1),
        decoration: BoxDecoration(
          color: const Color(0xFF1B5E20), // 深绿色
          borderRadius: BorderRadius.circular(3),
          border: Border.all(color: Colors.white30, width: 1),
        ),
      )),
    );
  }

  Widget _buildWallColumn(int count) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(count, (i) => Container(
        width: tileWidth * 0.6, height: tileHeight * 0.6,
        margin: const EdgeInsets.symmetric(vertical: 1),
        decoration: BoxDecoration(
          color: const Color(0xFF1B5E20), // 深绿色
          borderRadius: BorderRadius.circular(3),
          border: Border.all(color: Colors.white30, width: 1),
        ),
      )),
    );
  }

  Widget _buildDiscardArea() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(8)),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 6, mainAxisSpacing: 2, crossAxisSpacing: 2,
        ),
        itemCount: _game.players[0].playedTiles.length,
        itemBuilder: (context, index) {
          final tile = _game.players[0].playedTiles[index];
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(2),
              border: Border.all(color: Colors.black26),
            ),
            child: Center(child: Text(tile.displayName, style: const TextStyle(fontSize: 8))),
          );
        },
      ),
    );
  }

  Widget _buildAvatar(int index) {
    final names = ['东', '南', '西', '北'];
    final colors = [Colors.red, Colors.blue, Colors.green, Colors.orange];
    final player = _game.players[index];
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(8),
        border: _game.currentPlayerIndex == index ? Border.all(color: Colors.yellow, width: 2) : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(radius: 20, backgroundColor: colors[index], child: Text(names[index])),
          const SizedBox(height: 4),
          Text('积分 ${player.totalScore}', style: const TextStyle(color: Colors.white70, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildDealerInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(8)),
      child: Text('庄家: ${['东', '南', '西', '北'][_game.dealerIndex]}', style: const TextStyle(color: Colors.white, fontSize: 12)),
    );
  }

  Widget _buildMultiplier() {
    final mult = _game.roundMultiplier * _game.globalMultiplier;
    Color color = Colors.white;
    if (mult >= 8) color = Colors.red;
    else if (mult >= 4) color = Colors.orange;
    else if (mult >= 2) color = Colors.yellow;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black54, borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 2),
      ),
      child: Text('×$mult', style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  // 根据屏幕大小调整尺寸
  void _adjustSizes(double w, double h) {
    tileWidth = w * 0.045;
    tileHeight = tileWidth * 1.35;
  }
  
  Widget _buildDiceSection() {
    // 发牌后显示当局倍数
    if (_game.phase == GamePhase.playing) {
      final multiplier = _game.globalMultiplier;
      Color bgColor;
      if (multiplier >= 8) {
        bgColor = Colors.red; // 8倍红色
      } else if (multiplier >= 4) {
        bgColor = Colors.orange; // 4倍橙色
      } else if (multiplier >= 2) {
        bgColor = Colors.yellow; // 2倍黄色
      } else {
        bgColor = Colors.black54;
      }
      
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: multiplier >= 8 ? Border.all(color: Colors.white, width: 2) : null,
        ),
        child: Text(
          '×$multiplier',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: multiplier >= 4 ? Colors.white : Colors.black87,
          ),
        ),
      );
    }
    
    // 掷骰子阶段 - 跳动的大骰子动画
    return GestureDetector(
      onTap: _onDiceTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: isRolling ? 100 : 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black87, 
          borderRadius: BorderRadius.circular(20),
          border: isRolling ? Border.all(color: Colors.yellow, width: 3) : Border.all(color: Colors.white30, width: 2),
          boxShadow: isRolling ? [BoxShadow(color: Colors.yellow.withOpacity(0.5), blurRadius: 20)] : null,
        ),
        transform: isRolling ? Matrix4.identity()..translate(0.0, _diceAnimationValue) : Matrix4.identity(),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 第一个大骰子
            _buildDice(_game.diceValues[0]),
            const SizedBox(width: 24),
            // 第二个大骰子
            _buildDice(_game.diceValues[1]),
          ],
        ),
      ),
    );
  }
  
  // 构建单个大骰子
  Widget _buildDice(int value) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: isRolling ? 10 : 0),
      duration: Duration(milliseconds: isRolling ? 100 : 200),
      builder: (context, val, child) {
        return Transform.translate(
          offset: Offset(0, -val * 3),
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black, width: 2),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 4, offset: Offset(2, 2))],
            ),
            child: Center(
              child: Text(
                '$value',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMyHand() {
    final player = _game.players[0];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(player.handTiles.length, (i) => GestureDetector(
          onTap: () => _playTile(i),
          child: Container(
            width: tileWidth,
            height: tileHeight,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border: selectedTileIndex == i ? Border.all(color: Colors.yellow, width: 3) : null,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.asset(
                _getTileImagePath(player.handTiles[i]),
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.white,
                  child: Center(child: Text(player.handTiles[i].displayName, style: const TextStyle(fontSize: 10))),
                ),
              ),
            ),
          ),
        )),
      ),
    );
  }
  
  // 获取麻将牌图片路径
  String _getTileImagePath(Tile tile) {
    // 文件名格式: Man1.png (万), Pin1.png (筒), Sou1.png (条), Ton.png (东), etc.
    String prefix;
    switch (tile.suit) {
      case TileSuit.wan:
        prefix = 'Man';
        break;
      case TileSuit.tong:
        prefix = 'Pin';
        break;
      case TileSuit.tiao:
        prefix = 'Sou';
        break;
      case TileSuit.hua:
        if (tile.type == TileType.flower) {
          return 'assets/images/tiles/Regular/Front.png';
        }
        return 'assets/images/tiles/Regular/Blank.png';
    }
    
    if (tile.type == TileType.wind) {
      final winds = ['Ton', 'Nan', 'Shaa', 'Pei'];
      return 'assets/images/tiles/Regular/${winds[tile.number - 1]}.png';
    } else if (tile.type == TileType.dragon) {
      final dragons = ['Chun', 'Hatsu', 'Haku'];
      return 'assets/images/tiles/Regular/${dragons[tile.number - 1]}.png';
    }
    
    return 'assets/images/tiles/Regular/$prefix${tile.number}.png';
  }

  Widget _buildActionButtons() {
    final isMyTurn = _game.currentPlayerIndex == 0;
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: Colors.grey.shade800, borderRadius: BorderRadius.circular(12)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _actionBtn('摸', Colors.red, isMyTurn && _game.pendingTile == null, _drawTile),
          _actionBtn('吃', Colors.orange, canChow, _chow),
          _actionBtn('碰', Colors.cyan, canPong, _pong),
          _actionBtn('杠', Colors.purple, canKong, _kong),
          _actionBtn('胡', Colors.yellow, canHu, _hu),
        ],
      ),
    );
  }

  Widget _actionBtn(String label, Color color, bool enabled, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: ElevatedButton(
        onPressed: enabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: enabled ? color : Colors.grey[700],
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          minimumSize: const Size(40, 28),
        ),
        child: Text(label, style: const TextStyle(fontSize: 12, color: Colors.white)),
      ),
    );
  }

  Widget _buildRebelButton() {
    return GestureDetector(
      onTap: _rebel,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.5), blurRadius: 10)],
        ),
        child: const Text('我要造反!', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class TrapezoidPainter extends CustomPainter {
  final double topWidth, bottomWidth;
  final Color topColor, bottomColor;
  TrapezoidPainter({required this.topWidth, required this.bottomWidth, required this.topColor, required this.bottomColor});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [topColor, bottomColor])
      .createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    final path = Path()
      ..moveTo((size.width - topWidth) / 2, 0)
      ..lineTo((size.width + topWidth) / 2, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, paint);
    canvas.drawPath(path, Paint()..color = Colors.white24..style = PaintingStyle.stroke..strokeWidth = 2);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
