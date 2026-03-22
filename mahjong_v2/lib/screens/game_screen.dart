import 'package:flutter/material.dart';
import 'package:mahjong_v2/game_logic/mahjong_game.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with SingleTickerProviderStateMixin {
  final MahjongGame _game = MahjongGame();
  bool isRolling = false;
  bool canRebel = false;
  bool canPong = false, canKong = false, canHu = false, canChow = false;
  int? selectedTileIndex;
  Tile? pendingTile;
  
  // 动画控制器
  late AnimationController _diceAnimController;
  late Animation<double> _diceAnimation;

  @override
  void initState() {
    super.initState();
    _diceAnimController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    )..repeat(reverse: true);
    
    _diceAnimation = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _diceAnimController, curve: Curves.easeInOut),
    );
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
          
          // 梯形: 上宽80%, 下宽100%, 高90%
          final tableTop = (h - h * 0.90) / 2; // 居中
          final tableHeight = h * 0.90;
          final topWidth = w * 0.80;
          final bottomWidth = w * 1.00;
          
          // 牌墙离桌边150
          final wallOffset = 150.0;
          
          // 牌尺寸减小1/3
          final tileW = w * 0.035;
          final tileH = tileW * 1.35;
          
          return Stack(
            children: [
              // 深蓝渐变背景
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF0D1B2A), Color(0xFF1B263B)],
                  ),
                ),
              ),
              
              // ===== 梯形桌布 =====
              Center(
                child: Container(
                  width: bottomWidth,
                  height: tableHeight,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF1B5E20), Color(0xFF0D3010)],
                    ),
                    border: Border.all(color: const Color(0xFFD4AF37), width: 4),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFD4AF37).withOpacity(0.4),
                        blurRadius: 30,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ClipPath(
                    clipper: TrapezoidClipper(topWidth / bottomWidth),
                    child: Container(color: Colors.transparent),
                  ),
                ),
              ),
              
              // ===== 牌墙 - 4边各18堆 =====
              // 上牌墙 (平行于上边)
              Positioned(
                left: (w - topWidth) / 2 + wallOffset,
                right: (w - topWidth) / 2 + wallOffset,
                top: tableTop + wallOffset,
                child: _buildWallRow(18, tileW, tileH),
              ),
              // 下牌墙 (平行于下边)
              Positioned(
                left: (w - bottomWidth) / 2 + wallOffset,
                right: (w - bottomWidth) / 2 + wallOffset,
                bottom: h - (tableTop + tableHeight) - wallOffset,
                child: _buildWallRow(18, tileW, tileH),
              ),
              // 左牌墙 (平行于左边, 倾斜)
              Positioned(
                left: (w - bottomWidth) / 2 + wallOffset * 0.5,
                top: tableTop + tableHeight * 0.15,
                bottom: h - (tableTop + tableHeight) - tableHeight * 0.15,
                child: Transform.rotate(
                  angle: -0.15,
                  child: _buildWallCol(18, tileW, tileH),
                ),
              ),
              // 右牌墙 (平行于右边, 倾斜)
              Positioned(
                right: (w - bottomWidth) / 2 + wallOffset * 0.5,
                top: tableTop + tableHeight * 0.15,
                bottom: h - (tableTop + tableHeight) - tableHeight * 0.15,
                child: Transform.rotate(
                  angle: 0.15,
                  child: _buildWallCol(18, tileW, tileH),
                ),
              ),
              
              // ===== 头像 (4角) =====
              _buildAvatar('东', Colors.red, w * 0.5, tableTop - 30),
              _buildAvatar('南', Colors.green, w * 0.92, tableTop + tableHeight * 0.5),
              _buildAvatar('西', Colors.blue, w * 0.5, tableTop + tableHeight + 20),
              _buildAvatar('北', Colors.orange, w * 0.08, tableTop + tableHeight * 0.5),
              
              // ===== 骰子区 (跳动动画) =====
              if (_game.phase == GamePhase.waiting || _game.phase == GamePhase.diceRolling)
                Positioned(
                  left: w * 0.42,
                  right: w * 0.42,
                  top: tableTop + tableHeight * 0.4,
                  child: _buildDiceSection(),
                ),
              
              // ===== 手牌 =====
              if (_game.phase == GamePhase.playing)
                Positioned(
                  left: 10, right: 10, bottom: 20,
                  child: _buildMyHand(tileW, tileH),
                ),
              
              // ===== 操作按钮 =====
              if (_game.phase == GamePhase.playing)
                Positioned(
                  right: 10, bottom: 30,
                  child: _buildActionButtons(),
                ),
              
              // ===== 造反按钮 =====
              if (canRebel)
                Positioned(
                  top: 60, left: 0, right: 0,
                  child: Center(child: _buildRebelButton()),
                ),
            ],
          );
        },
      ),
    );
  }

  // 梯形裁剪
  Widget _buildWallRow(int count, double w, double h) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) => Container(
        width: w, height: h,
        margin: const EdgeInsets.symmetric(horizontal: 1),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
          ),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: const Color(0xFFD4AF37), width: 1),
        ),
      )),
    );
  }

  Widget _buildWallCol(int count, double w, double h) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(count, (i) => Container(
        width: w, height: h,
        margin: const EdgeInsets.symmetric(vertical: 1),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
          ),
          borderRadius: BorderRadius.circular(4),
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

  // 跳动的骰子
  Widget _buildDiceSection() {
    return Column(
      children: [
        GestureDetector(
          onTap: _onDiceTap,
          child: AnimatedBuilder(
            animation: _diceAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _diceAnimation.value),
                child: child,
              );
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFD4AF37), width: 2),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDiceImage(_game.diceValues[0]),
                  const SizedBox(width: 16),
                  _buildDiceImage(_game.diceValues[1]),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (_game.phase == GamePhase.diceRolling)
          GestureDetector(
            onTap: _onDealTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFD4AF37), Color(0xFFB8860B)]),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: const Color(0xFFD4AF37).withOpacity(0.5), blurRadius: 8)],
              ),
              child: const Text('发牌', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
      ],
    );
  }

  // 真实骰子图片
  Widget _buildDiceImage(int v) {
    // 骰子点数颜色和点位置
    final Map<int, List<Offset>> diceDots = {
      1: [const Offset(0.5, 0.5)],
      2: [const Offset(0.2, 0.2), const Offset(0.8, 0.8)],
      3: [const Offset(0.2, 0.2), const Offset(0.5, 0.5), const Offset(0.8, 0.8)],
      4: [const Offset(0.2, 0.2), const Offset(0.8, 0.2), const Offset(0.2, 0.8), const Offset(0.8, 0.8)],
      5: [const Offset(0.2, 0.2), const Offset(0.8, 0.2), const Offset(0.5, 0.5), const Offset(0.2, 0.8), const Offset(0.8, 0.8)],
      6: [const Offset(0.2, 0.2), const Offset(0.8, 0.2), const Offset(0.2, 0.5), const Offset(0.8, 0.5), const Offset(0.2, 0.8), const Offset(0.8, 0.8)],
    };
    
    return Container(
      width: 50, height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD4AF37), width: 2),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 2)],
      ),
      child: Stack(
        children: [
          // 骰子背景
          Container(decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Colors.grey[100]!],
            ),
          )),
          // 点数
          ...diceDots[v]!.map((pos) => Positioned(
            left: pos.dx * 40, top: pos.dy * 40,
            child: Container(width: 10, height: 10, decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle)),
          )),
        ],
      ),
    );
  }

  Widget _buildMyHand(double w, double h) {
    final player = _game.players[0];
    return Container(
      height: h + 10,
      decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(8)),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: player.handTiles.length,
        itemBuilder: (ctx, i) => GestureDetector(
          onTap: () => _playTile(i),
          child: Container(
            width: w, height: h,
            margin: const EdgeInsets.symmetric(horizontal: 1, vertical: 2),
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

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFD4AF37))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _btn('摸', Colors.red, _game.pendingTile == null, _drawTile),
          _btn('吃', Colors.orange, canChow, () {}),
          _btn('碰', Colors.cyan, canPong, () {}),
          _btn('杠', Colors.purple, canKong, () {}),
          _btn('胡', Colors.yellow[700]!, canHu, () {}),
        ],
      ),
    );
  }

  Widget _btn(String label, Color c, bool en, VoidCallback on) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: ElevatedButton(
        onPressed: en ? on : null,
        style: ElevatedButton.styleFrom(backgroundColor: en ? c : Colors.grey[700], minimumSize: const Size(50, 32)),
        child: Text(label, style: const TextStyle(fontSize: 12, color: Colors.white)),
      ),
    );
  }

  Widget _buildRebelButton() {
    return GestureDetector(
      onTap: _rebel,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white, width: 2)),
        child: const Text('我要造反', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }

  void _onDiceTap() {
    setState(() { isRolling = true; });
    Future.delayed(const Duration(milliseconds: 800), () {
      setState(() { _game.rollDice(); isRolling = false; });
    });
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

// 梯形裁剪器
class TrapezoidClipper extends CustomClipper<Path> {
  final double topRatio;
  TrapezoidClipper(this.topRatio);
  
  @override
  Path getClip(Size size) {
    final path = Path();
    final topW = size.width * topRatio;
    final left = (size.width - topW) / 2;
    path.moveTo(left, 0);
    path.lineTo(left + topW, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }
  
  @override
  bool shouldReclip(TrapezoidClipper oldClipper) => topRatio != oldClipper.topRatio;
}
