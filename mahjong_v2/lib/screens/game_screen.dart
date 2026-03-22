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
    _diceRotateAnimation = Tween<double>(begin: 0, end: 4 * pi).animate(
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
              // 浅蓝色渐变灰背景
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFB0C4DE), Color(0xFF708090)],
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
                child: _buildWallRow(18, tileW, tileH),
              ),
              // 下牌墙 (平行于下边)
              Positioned(
                left: (w - bottomWidth) / 2 + wallOffset,
                right: (w - bottomWidth) / 2 + wallOffset,
                bottom: wallOffset,
                child: _buildWallRow(18, tileW, tileH),
              ),
              // 左牌墙 (倾斜平行于左边)
              Positioned(
                left: wallOffset * 0.5,
                top: h * 0.15,
                bottom: h * 0.15,
                child: Transform.rotate(
                  angle: -0.12,
                  child: _buildWallCol(18, tileW, tileH),
                ),
              ),
              // 右牌墙 (倾斜平行于右边)
              Positioned(
                right: wallOffset * 0.5,
                top: h * 0.15,
                bottom: h * 0.15,
                child: Transform.rotate(
                  angle: 0.12,
                  child: _buildWallCol(18, tileW, tileH),
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
                      if (_game.phase == GamePhase.diceRolling)
                        _buildDealButton(),
                    ],
                  ),
                ),
              
              // ===== 手牌 =====
              if (_game.phase == GamePhase.playing)
                Positioned(
                  left: 10, right: 10, bottom: 20,
                  child: _buildMyHand(tileW, tileH),
                ),
              
              // ===== 操作按钮 =====
              if (_game.phase == GamePhase.playing)
                _buildActionButtons(),
              
              // ===== 造反按钮 =====
              if (canRebel)
                Positioned(
                  top: 50, left: 0, right: 0,
                  child: Center(child: _buildRebelButton()),
                ),
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

  // 牌墙 - 长边紧靠（竖向）
  Widget _buildWallCol(int count, double w, double h) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(count, (i) => Container(
        width: w, height: h,
        margin: const EdgeInsets.symmetric(vertical: 0), // 长边紧靠
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
  Widget _buildDiceWithAnimation() {
    return GestureDetector(
      onTap: isRolling ? null : _onDiceTap,
      child: AnimatedBuilder(
        animation: _diceRotateAnimation,
        builder: (context, child) {
          return Transform.rotate(
            angle: isRolling ? _diceRotateAnimation.value : 0,
            child: child,
          );
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFD4AF37), width: 3),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDiceFace(_displayDice[0]),
              const SizedBox(width: 20),
              _buildDiceFace(_displayDice[1]),
            ],
          ),
        ),
      ),
    );
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
      height: h + 20,
      decoration: BoxDecoration(color: Colors.black38, borderRadius: BorderRadius.circular(8)),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: player.handTiles.length,
        itemBuilder: (ctx, i) => GestureDetector(
          onTap: () => _playTile(i),
          child: Container(
            width: w, height: h,
            margin: const EdgeInsets.symmetric(horizontal: 1, vertical: 3),
            decoration: BoxDecoration(
              color: selectedTileIndex == i ? Colors.yellow[200] : Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: const Color(0xFFD4AF37)),
            ),
            child: Center(child: Text(player.handTiles[i].displayName, style: const TextStyle(fontSize: 9))),
          ),
        ),
      ),
    );
  }

  // 环绕式操作菜单 - 摸大圆 + 吃/碰/杠/胡环绕右侧
  Widget _buildActionButtons() {
    final btnSize = 70.0; // 摸按钮大小
    final subBtnSize = btnSize * 0.5; // 子按钮大小 (一半)
    final orbitRadius = btnSize * 0.7; // 环绕半径
    
    return Positioned(
      right: 10,
      bottom: 30,
      child: SizedBox(
        width: btnSize * 2,
        height: btnSize * 2,
        child: Stack(
          children: [
            // 摸 - 大圆形按钮（中心）
            Positioned(
              left: btnSize * 0.5,
              top: btnSize * 0.5,
              child: GestureDetector(
                onTap: _game.pendingTile == null ? _drawTile : null,
                child: Container(
                  width: btnSize,
                  height: btnSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _game.pendingTile == null ? Colors.red : Colors.grey[700],
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(color: Colors.red.withOpacity(0.5), blurRadius: 10),
                    ],
                  ),
                  child: const Center(
                    child: Text('摸', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ),
            ),
            // 吃 - 环绕在摸的右侧
            Positioned(
              left: btnSize * 0.5 + orbitRadius,
              top: btnSize * 0.5,
              child: _buildOrbitBtn('吃', Colors.orange, canChow, subBtnSize, () {}),
            ),
            // 碰 - 吃上方
            Positioned(
              left: btnSize * 0.5 + orbitRadius * 0.9,
              top: btnSize * 0.5 - orbitRadius * 0.4,
              child: _buildOrbitBtn('碰', Colors.cyan, canPong, subBtnSize, () {}),
            ),
            // 杠 - 吃下方
            Positioned(
              left: btnSize * 0.5 + orbitRadius * 0.9,
              top: btnSize * 0.5 + orbitRadius * 0.4,
              child: _buildOrbitBtn('杠', Colors.purple, canKong, subBtnSize, () {}),
            ),
            // 胡 - 最外侧
            Positioned(
              left: btnSize * 0.5 + orbitRadius * 1.1,
              top: btnSize * 0.5,
              child: _buildOrbitBtn('胡', Colors.yellow[700]!, canHu, subBtnSize, () {}),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrbitBtn(String label, Color color, bool enabled, double size, VoidCallback onTap) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: enabled ? color : Colors.grey[700],
          border: Border.all(
            color: enabled ? Colors.white : Colors.grey,
            width: 2,
          ),
          boxShadow: enabled ? [
            BoxShadow(color: color.withOpacity(0.5), blurRadius: 8),
          ] : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: size * 0.35,
              fontWeight: FontWeight.bold,
              color: enabled ? Colors.white : Colors.grey,
            ),
          ),
        ),
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

  void _onDiceTap() {
    setState(() {
      isRolling = true;
      _displayDice = [Random().nextInt(6) + 1, Random().nextInt(6) + 1];
    });
    _diceAnimController.forward(from: 0);
    _game.rollDice();
  }

  void _onDealTap() {
    setState(() { _game.deal(); canRebel = _game.checkWuDuSan(); });
  }

  void _drawTile() {
    final p = _game.players[_game.currentPlayerIndex];
    _game.drawTile(p);
    setState(() {});
  }

  void _playTile(int i) {
    final p = _game.players[0];
    final t = p.handTiles[i];
    _game.playTile(p, t);
    _game.pendingTile = t;
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
