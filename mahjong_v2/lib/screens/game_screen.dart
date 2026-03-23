import 'package:flutter/material.dart';
import 'dart:math';
import 'package:mahjong_v2/game_logic/mahjong_game.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  final MahjongGame _game = MahjongGame();
  bool isRolling = false;
  bool canRebel = false;
  bool canPong = false, canKong = false, canHu = false, canChow = false;
  int? selectedTileIndex;
  
  // 骰子动画
  late AnimationController _diceAnimController;
  late Animation<double> _diceRotateAnimation;
  List<int> _displayDice = [1, 1];
  
  @override
  void initState() {
    super.initState();
    _diceAnimController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _diceRotateAnimation = Tween<double>(begin: 0, end: 2 * pi).animate(
      CurvedAnimation(parent: _diceAnimController, curve: Curves.easeOut),
    );
    _diceAnimController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          isRolling = false;
          _displayDice = _game.diceValues;
        });
      }
    });
  }

  @override
  void dispose() {
    _diceAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 检查操作选项（花牌可以杠-补花）
    final player = _game.players[0];
    final isMyTurn = _game.currentPlayerIndex == 0;
    final canRespond = _game.awaitingPlayerResponse || isMyTurn;
    final hasFlowerInHand = player.handTiles.any((t) => t.isFlower);
    canPong = canRespond && _game.pendingTile != null && _game.canPong(player);
    canKong = canRespond && (_game.canKong(player) || hasFlowerInHand);
    canHu = canRespond && _game.canHu(player);
    canChow = canRespond && _game.pendingTile != null && _game.canChow(player);
    
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight;
          
          // 梯形: 上宽80%, 下宽100%, 高100%
          final tableTop = 0.0;
          final tableHeight = h;
          final topWidth = w * 0.80;
          final bottomWidth = w * 1.00;
          
          // 牌墙离桌边距离
          final wallOffset = w * 0.08;
          
          // 牌尺寸 - 长边紧靠
          final tileW = w * 0.03;
          final tileH = tileW * 1.3;
          
          return Stack(
            children: [
              // 木纹背景
              Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/backgrounds/light_wood.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              
              // ===== 梯形桌布 =====
              Center(
                child: Container(
                  height: tableHeight,
                  child: CustomPaint(
                    size: Size(bottomWidth, tableHeight),
                    painter: TrapezoidPainter(topWidth, bottomWidth),
                  ),
                ),
              ),
              
              // ===== 牌墙 - 4边各18堆，长边紧靠 =====
              // 上牌墙 (平行于上边)
              Positioned(
                left: (w - topWidth) / 2 + wallOffset,
                right: (w - topWidth) / 2 + wallOffset,
                top: wallOffset,
                child: _buildWallRow(18, tileW * 0.7, tileH * 0.7),
              ),
              // 下牌墙 (平行于下边)
              Positioned(
                left: (w - bottomWidth) / 2 + wallOffset,
                right: (w - bottomWidth) / 2 + wallOffset,
                bottom: wallOffset,
                child: _buildWallRow(18, tileW * 0.7, tileH * 0.7),
              ),
              // 左牌墙 - 平行于梯形左边
              Positioned(
                left: wallOffset * 0.3,
                top: h * 0.12,
                bottom: h * 0.12,
                child: Transform.rotate(
                  angle: -0.15, // 与梯形左边平行
                  child: _buildWallRow(18, tileW * 0.7, tileH * 0.7),
                ),
              ),
              // 右牌墙 - 平行于梯形右边
              Positioned(
                right: wallOffset * 0.3,
                top: h * 0.12,
                bottom: h * 0.12,
                child: Transform.rotate(
                  angle: 0.15, // 与梯形右边平行
                  child: _buildWallRow(18, tileW * 0.7, tileH * 0.7),
                ),
              ),
              
              // ===== 头像 =====
              _buildAvatar('东', Colors.red, w * 0.5, h * 0.05),
              _buildAvatar('南', Colors.green, w * 0.95, h * 0.5),
              _buildAvatar('西', Colors.blue, w * 0.5, h * 0.95),
              _buildAvatar('北', Colors.orange, w * 0.05, h * 0.5),
              
              // ===== 骰子 + 发牌按钮 =====
              if (_game.phase == GamePhase.waiting || _game.phase == GamePhase.diceRolling)
                Positioned(
                  left: w * 0.35,
                  right: w * 0.35,
                  top: h * 0.4,
                  child: Column(
                    children: [
                      _buildDiceWithAnimation(),
                      const SizedBox(height: 16),
                      // 发牌按钮 - 骰子掷完后显示
                      if (_game.diceRolled || _game.phase == GamePhase.diceRolling)
                        _buildDealButton(),
                    ],
                  ),
                ),
              // ===== 倍数显示 =====
              if (_game.phase == GamePhase.playing)
                Positioned(
                  left: w * 0.35,
                  right: w * 0.35,
                  top: h * 0.4,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFD4AF37), width: 2),
                      ),
                      child: Text('本局倍数 x${_game.roundMultiplier}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                ),
              
              // ===== 手牌 =====
              if (_game.phase == GamePhase.playing)
                Positioned(
                  left: 10, right: 10, bottom: 20,
                  child: Row(
                    children: [
                      // 花牌区（碰杠区左侧）
                      if (player.flowerTiles.isNotEmpty)
                        Container(
                          width: tileW * 1.5,
                          height: tileH,
                          child: Column(
                            children: player.flowerTiles.map((t) => Container(
                              width: tileW, height: tileH * 0.3,
                              margin: const EdgeInsets.all(1),
                              decoration: BoxDecoration(
                                color: Colors.pink[200],
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: Center(child: Text('花', style: TextStyle(fontSize: 8))),
                            )).toList(),
                          ),
                        ),
                      // 手牌
                      Expanded(child: _buildMyHand(tileW, tileH)),
                    ],
                  ),
                ),

              // ===== 回合提示 =====
              if (_game.phase == GamePhase.playing)
                Positioned(
                  left: 0, right: 0, bottom: tileH + 50,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(12)),
                      child: Text(_turnHintText(), style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              
              // ===== 造反按钮 =====
              if (canRebel)
                Positioned(
                  top: 50, left: 0, right: 0,
                  child: Center(child: _buildRebelButton()),
                ),
              
              // ===== 操作按钮（置顶） =====
              if (_game.phase == GamePhase.playing)
                _buildActionButtons(),

              // ===== 结算面板（置顶） =====
              if (_game.phase == GamePhase.scoring && _game.lastSettlement != null)
                _buildSettlementOverlay(w, h),
            ],
          );
        },
      ),
    );
  }

  // 牌墙 - 长边紧靠（横向）
  Widget _buildWallRow(int count, double w, double h) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) => Container(
        width: w, height: h,
        margin: const EdgeInsets.symmetric(horizontal: 0), // 长边紧靠
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
          ),
          borderRadius: BorderRadius.circular(3),
          border: Border.all(color: const Color(0xFFD4AF37), width: 1),
        ),
      )),
    );
  }

  // 左右牌墙 - 长边相连（水平方向）
  Widget _buildWallCol(int count, double w, double h) {
    return SizedBox(
      height: w * count, // 旋转90度后宽变高
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(count, (i) => Container(
          width: h, height: w, // 长宽互换
          margin: const EdgeInsets.symmetric(horizontal: 0),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
            ),
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: const Color(0xFFD4AF37), width: 1),
          ),
        )),
      ),
    );
  }

  Widget _buildAvatar(String name, Color c, double x, double y) {
    return Positioned(
      left: x - 20, top: y - 20,
      child: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: c, shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: Center(child: Text(name, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))),
      ),
    );
  }

  // 滚动骰子动画
  // 精美3D骰子动画组件
  Widget _buildDiceWithAnimation() {
    return GestureDetector(
      onTap: isRolling ? null : _onDiceTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFD4AF37), width: 3),
          boxShadow: [
            BoxShadow(color: Colors.black54, blurRadius: 20, offset: const Offset(0, 10)),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _build3DDice(_displayDice[0], 0),
            const SizedBox(width: 24),
            _build3DDice(_displayDice[1], 1),
          ],
        ),
      ),
    );
  }

  // 3D骰子
  Widget _build3DDice(int value, int index) {
    return AnimatedBuilder(
      animation: _diceRotateAnimation,
      builder: (context, child) {
        // 弹跳 + 旋转效果
        final progress = isRolling ? _diceRotateAnimation.value : 0.0;
        final bounce = isRolling ? (1 - (progress * 2 - 1).abs()) * 1.5 : 0.0;
        final rotation = isRolling ? progress * 6.28 : 0.0; // 完整旋转
        
        return Transform(
          transform: Matrix4.identity()
            ..translate(0.0, -bounce)
            ..rotateZ(rotation),
          alignment: Alignment.center,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  const Color(0xFFEEEEEE),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black87, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 8,
                  offset: const Offset(2, 4),
                ),
              ],
            ),
            child: Center(
              child: _buildDiceDots(value),
            ),
          ),
        );
      },
    );
  }

  // 骰子点数（带点数样式）
  Widget _buildDiceDots(int value) {
    return Container(
      width: 50,
      height: 50,
      child: Stack(
        children: _getDots(value),
      ),
    );
  }

  List<Widget> _getDots(int value) {
    final dots = <Widget>[];
    final dotSize = 12.0;
    final color = Colors.red;
    
    // 点位定义
    final positions = {
      1: [(0.5, 0.5)],
      2: [(0.2, 0.2), (0.8, 0.8)],
      3: [(0.2, 0.2), (0.5, 0.5), (0.8, 0.8)],
      4: [(0.2, 0.2), (0.2, 0.8), (0.8, 0.2), (0.8, 0.8)],
      5: [(0.2, 0.2), (0.2, 0.8), (0.5, 0.5), (0.8, 0.2), (0.8, 0.8)],
      6: [(0.2, 0.2), (0.2, 0.5), (0.2, 0.8), (0.8, 0.2), (0.8, 0.5), (0.8, 0.8)],
    };
    
    for (final pos in positions[value] ?? []) {
      dots.add(Positioned(
        left: pos.$1 * 50 - dotSize / 2,
        top: pos.$2 * 50 - dotSize / 2,
        child: Container(
          width: dotSize,
          height: dotSize,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 2)],
          ),
        ),
      ));
    }
    return dots;
  }

  Widget _buildDiceFace(int v) {
    return Container(
      width: 60, height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black, width: 2),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Color(0xFFEEEEEE)],
        ),
      ),
      child: Center(
        child: Text('$v', style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.red)),
      ),
    );
  }

  Widget _buildDealButton() {
    return GestureDetector(
      onTap: _onDealTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)]),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [BoxShadow(color: Colors.green.withOpacity(0.5), blurRadius: 10)],
        ),
        child: const Text('发牌', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }

  Widget _buildMyHand(double w, double h) {
    final player = _game.players[0];
    return Container(
      height: h + 30,
      decoration: BoxDecoration(color: Colors.black38, borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (int i = 0; i < player.handTiles.length; i++)
            GestureDetector(
              onTap: () => _playTile(i),
              child: Container(
                width: w, height: h,
                margin: const EdgeInsets.symmetric(horizontal: 1, vertical: 3),
                decoration: BoxDecoration(
                  color: selectedTileIndex == i ? Colors.yellow[200] : Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: const Color(0xFFD4AF37)),
                ),
                child: Image.asset(player.handTiles[i].imagePath, fit: BoxFit.contain, errorBuilder: (_, __, ___) => Center(child: Text(player.handTiles[i].displayName, style: const TextStyle(fontSize: 9)))),
              ),
            ),
        ],
      ),
    );
  }

  // 环绕式操作菜单 - 摸大圆 + 吃/碰/杠/胡环绕右侧
  Widget _buildActionButtons() {
    final btnSize = 70.0;
    final subBtnSize = btnSize * 0.55;
    final orbitRadius = btnSize * 1.1;
    final showDraw = false; // 发牌后隐藏“摸”按钮
    
    return Positioned(
      right: 10,
      bottom: 30,
      child: SizedBox(
        width: btnSize * 2.5,
        height: btnSize * 2.5,
        child: Stack(
          children: [
            // 摸（隐藏）
            if (showDraw)
              Positioned(
                left: btnSize * 0.5,
                top: btnSize * 0.5,
                child: GestureDetector(
                  onTap: (!_game.mustDiscard && _game.pendingTile == null) ? _drawTile : null,
                  child: Container(
                    width: btnSize,
                    height: btnSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: (!_game.mustDiscard && _game.pendingTile == null) ? Colors.red : Colors.grey[700],
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [BoxShadow(color: Colors.red.withValues(alpha: 0.5), blurRadius: 10)],
                    ),
                    child: Center(child: Text('摸', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white))),
                  ),
                ),
              ),
            // 吃
            Positioned(left: btnSize * 0.5 + orbitRadius, top: btnSize * 0.5, child: _buildOrbitBtn('吃', Colors.orange, canChow, subBtnSize, _onChow)),
            // 碰
            Positioned(left: btnSize * 0.5 + orbitRadius * 0.85, top: btnSize * 0.5 - orbitRadius * 0.7, child: _buildOrbitBtn('碰', Colors.cyan, canPong, subBtnSize, _onPong)),
            // 杠
            Positioned(left: btnSize * 0.5 + orbitRadius * 0.85, top: btnSize * 0.5 + orbitRadius * 0.7, child: _buildOrbitBtn('杠', Colors.purple, canKong, subBtnSize, _onKong)),
            // 胡
            Positioned(left: btnSize * 0.5 + orbitRadius * 1.3, top: btnSize * 0.5, child: _buildOrbitBtn('胡', Colors.yellow[700]!, canHu, subBtnSize, _onHu)),
            // 过
            Positioned(left: btnSize * 0.5 + orbitRadius * 0.4, top: btnSize * 0.5 + orbitRadius * 1.2, child: _buildOrbitBtn('过', Colors.blueGrey, _game.awaitingPlayerResponse, subBtnSize * 0.9, _onPass)),
          ],
        ),
      ),
    );
  }

  Widget _buildOrbitBtn(String label, Color baseColor, bool enabled, double size, VoidCallback onTap) {
    final color = enabled ? baseColor : Colors.grey[600]!;
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          border: Border.all(color: enabled ? Colors.white : Colors.grey[400]!, width: 2),
          boxShadow: enabled ? [BoxShadow(color: color.withValues(alpha: 0.6), blurRadius: 10)] : null,
        ),
        child: Center(child: Text(label, style: TextStyle(fontSize: size * 0.35, fontWeight: FontWeight.bold, color: enabled ? Colors.white : Colors.grey[400]))),
      ),
    );
  }

  Widget _buildRebelButton() {
    return GestureDetector(
      onTap: _rebel,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
        decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(25), border: Border.all(color: Colors.white, width: 2)),
        child: const Text('我要造反', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }

  String _turnHintText() {
    if (_game.awaitingPlayerResponse) return '可吃/碰/杠/胡，或点“过”';
    if (_game.currentPlayerIndex == 0) {
      return _game.mustDiscard ? '轮到你出牌' : '轮到你摸牌';
    }
    return '等待其他玩家...';
  }

  Widget _buildSettlementOverlay(double w, double h) {
    final s = _game.lastSettlement!;
    return Positioned.fill(
      child: Container(
        color: Colors.black54,
        child: Center(
          child: Container(
            width: w * 0.72,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFD4AF37), width: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(s.isDraw ? '流局结算' : '本局结算', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                if (!s.isDraw && s.winnerIndex != null)
                  Text('胜者：${_game.players[s.winnerIndex!].name}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text('原因：${s.reason}', style: const TextStyle(fontSize: 14)),
                const SizedBox(height: 4),
                Text('底分 ${s.basePoints} × 回合${s.roundMultiplier} × 额外${s.extraMultiplier} = ${s.totalPoints}', style: const TextStyle(fontSize: 14)),
                const SizedBox(height: 10),
                Column(
                  children: List.generate(4, (i) {
                    final delta = s.deltas[i] ?? 0;
                    final color = delta >= 0 ? Colors.green : Colors.red;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_game.players[i].name, style: const TextStyle(fontSize: 14)),
                          Text(delta >= 0 ? '+$delta' : '$delta', style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _onNextRound,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32)),
                  child: const Text('下一局', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onNextRound() {
    setState(() {
      _game.resetForNextRound();
    });
  }

  void _onDiceTap() {
    setState(() {
      isRolling = true;
      _displayDice = [Random().nextInt(6) + 1, Random().nextInt(6) + 1];
    });
    _diceAnimController.forward(from: 0);
    _game.rollDice();
  }

  void _onDealTap() {
    setState(() { 
      _game.deal(); 
      canRebel = _game.checkWuDuSan();
    });
    // 如果庄家不是玩家，AI先出牌
    if (_game.currentPlayerIndex != 0) {
      Future.delayed(const Duration(milliseconds: 500), () {
        _game.aiDiscard(_game.currentPlayerIndex);
        setState(() {});
      });
    }
  }

  void _drawTile() {
    if (_game.currentPlayerIndex != 0 || _game.mustDiscard) return;
    final p = _game.players[_game.currentPlayerIndex];
    _game.drawTile(p);
    setState(() {});
  }

  void _onKong() {
    final p = _game.players[0];
    if (_game.currentPlayerIndex != 0 && !_game.awaitingPlayerResponse) return;
    
    // 优先补花
    if (p.handTiles.any((t) => t.isFlower)) {
      while (_game.wall.isNotEmpty) {
        final flowerIndex = p.handTiles.indexWhere((t) => t.isFlower);
        if (flowerIndex == -1) break;
        final flower = p.handTiles.removeAt(flowerIndex);
        p.flowerTiles.add(flower);
        final newTile = _game.wall.removeLast();
        if (newTile.isFlower) {
          p.flowerTiles.add(newTile);
          continue;
        } else {
          p.handTiles.add(newTile);
        }
      }
      setState(() {});
      return;
    }

    // 普通杠
    if (_game.canKong(p)) {
      final kongTiles = _game.getKongableTiles(p);
      if (kongTiles.isNotEmpty) {
        final isHidden = _game.pendingTile == null;
        _game.doKong(p, kongTiles.first, isHidden: isHidden);
        _game.awaitingPlayerResponse = false;
        if (p.index == 0) {
          _game.mustDiscard = false; // 允许补牌
        }
        _game.drawTile(p);
      }
    }
    setState(() {});
  }

  void _onChow() {
    final p = _game.players[0];
    if (!_game.doChow(p, null)) return;
    _game.awaitingPlayerResponse = false;
    setState(() {});
  }

  void _onPong() {
    final p = _game.players[0];
    if (!_game.doPong(p)) return;
    _game.awaitingPlayerResponse = false;
    setState(() {});
  }

  void _onHu() {
    _game.awaitingPlayerResponse = false;
    _game.playerWins(0);
    setState(() {});
  }

  void _onPass() {
    _game.playerPass();
    setState(() {});
  }
  
  void _playTile(int i) {
    if (_game.currentPlayerIndex != 0) return;
    if (!_game.mustDiscard) return; // 必须先摸牌
    final p = _game.players[0];
    final t = p.handTiles[i];
    _game.playTile(p, t);
    selectedTileIndex = null;
    setState(() {});
  }

  void _rebel() {
    _game.resolveRebelAsDraw(_game.dealerIndex);
    setState(() {});
  }
}

// 梯形画家
class TrapezoidPainter extends CustomPainter {
  final double topW, bottomW;
  TrapezoidPainter(this.topW, this.bottomW);
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF87CEEB), Color(0xFFB0C4DE)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    
    final path = Path();
    final topOffset = (size.width - topW) / 2;
    path.moveTo(topOffset, 0);
    path.lineTo(topOffset + topW, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    
    canvas.drawPath(path, paint);
    
    // 金边
    final borderPaint = Paint()
      ..color = const Color(0xFFD4AF37)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawPath(path, borderPaint);
  }
  
  @override
  bool shouldRepaint(TrapezoidPainter old) => topW != old.topW || bottomW != old.bottomW;
}
