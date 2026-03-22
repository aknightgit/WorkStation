import 'package:flutter/material.dart';
import 'package:mahjong_v2/game_logic/mahjong_game.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final MahjongGame _game = MahjongGame();
  bool isRolling = false;
  bool canRebel = false;
  bool canPong = false, canKong = false, canHu = false, canChow = false;
  int? selectedTileIndex;
  Tile? pendingTile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight;
          
          // 经典绿呢桌面参数
          final tableWidth = w * 0.88;
          final tableHeight = h * 0.72;
          final tileW = w * 0.038;
          final tileH = tileW * 1.4;
          
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
              
              // ===== 绿呢桌面 =====
              Center(
                child: Container(
                  width: tableWidth,
                  height: tableHeight,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF1B5E20), Color(0xFF0D3010)],
                    ),
                    border: Border.all(color: const Color(0xFFD4AF37), width: 4),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFD4AF37).withOpacity(0.4),
                        blurRadius: 30,
                        spreadRadius: 2,
                      ),
                      const BoxShadow(
                        color: Colors.black54,
                        blurRadius: 20,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                ),
              ),
              
              // ===== 牌墙 (经典4边布局) =====
              // 上牌墙
              Positioned(
                left: w * 0.10,
                right: w * 0.10,
                top: h * 0.08,
                child: _buildWallRow(14, tileW, tileH),
              ),
              // 下牌墙
              Positioned(
                left: w * 0.10,
                right: w * 0.10,
                bottom: h * 0.10,
                child: _buildWallRow(14, tileW, tileH),
              ),
              // 左牌墙
              Positioned(
                left: w * 0.06,
                top: h * 0.18,
                bottom: h * 0.22,
                child: _buildWallCol(10, tileW, tileH),
              ),
              // 右牌墙  
              Positioned(
                right: w * 0.06,
                top: h * 0.18,
                bottom: h * 0.22,
                child: _buildWallCol(10, tileW, tileH),
              ),
              
              // ===== 头像 (4角) =====
              _buildAvatar('东', Colors.red, w * 0.5, h * 0.05),
              _buildAvatar('南', Colors.green, w * 0.94, h * 0.42),
              _buildAvatar('西', Colors.blue, w * 0.5, h * 0.93),
              _buildAvatar('北', Colors.orange, w * 0.06, h * 0.42),
              
              // ===== 骰子区 =====
              if (_game.phase == GamePhase.waiting || _game.phase == GamePhase.diceRolling)
                Positioned(
                  left: w * 0.42,
                  right: w * 0.42,
                  top: h * 0.38,
                  child: _buildDiceSection(),
                ),
              
              // ===== 手牌 (底部) =====
              if (_game.phase == GamePhase.playing)
                Positioned(
                  left: w * 0.05,
                  right: w * 0.05,
                  bottom: h * 0.02,
                  child: _buildMyHand(tileW * 0.9, tileH * 0.9),
                ),
              
              // ===== 操作按钮 =====
              if (_game.phase == GamePhase.playing)
                Positioned(
                  right: w * 0.02,
                  bottom: h * 0.15,
                  child: _buildActionButtons(),
                ),
              
              // ===== 造反按钮 =====
              if (canRebel)
                Positioned(
                  top: h * 0.06,
                  left: 0,
                  right: 0,
                  child: Center(child: _buildRebelButton()),
                ),
            ],
          );
        },
      ),
    );
  }

  // 牌墙行
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
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 2, offset: const Offset(1, 1)),
          ],
        ),
      )),
    );
  }

  // 牌墙列
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
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 2, offset: const Offset(1, 1)),
          ],
        ),
      )),
    );
  }

  // 头像
  Widget _buildAvatar(String name, Color color, double x, double y) {
    return Positioned(
      left: x - 18,
      top: y - 18,
      child: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 4)],
        ),
        child: Center(child: Text(name, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))),
      ),
    );
  }

  // 骰子区
  Widget _buildDiceSection() {
    return Column(
      children: [
        GestureDetector(
          onTap: _onDiceTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFD4AF37), width: 2),
              boxShadow: [
                BoxShadow(color: const Color(0xFFD4AF37).withOpacity(0.3), blurRadius: 10),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDice(_game.diceValues[0]),
                const SizedBox(width: 12),
                _buildDice(_game.diceValues[1]),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        if (_game.phase == GamePhase.diceRolling)
          _buildDealBtn(),
      ],
    );
  }

  Widget _buildDice(int v) {
    return Container(
      width: 44, height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD4AF37), width: 2),
      ),
      child: Center(child: Text('$v', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87))),
    );
  }

  Widget _buildDealBtn() {
    return GestureDetector(
      onTap: _onDealTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFFD4AF37), Color(0xFFB8860B)]),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: const Color(0xFFD4AF37).withOpacity(0.5), blurRadius: 8)],
        ),
        child: const Text('发牌', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }

  // 手牌
  Widget _buildMyHand(double w, double h) {
    final player = _game.players[0];
    return Container(
      height: h + 10,
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: player.handTiles.length,
        itemBuilder: (ctx, i) => GestureDetector(
          onTap: () => _playTile(i),
          child: Container(
            width: w,
            height: h,
            margin: const EdgeInsets.symmetric(horizontal: 1, vertical: 2),
            decoration: BoxDecoration(
              color: selectedTileIndex == i ? Colors.yellow[200] : Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: const Color(0xFFD4AF37), width: 1),
            ),
            child: Center(child: Text(player.handTiles[i].displayName, style: const TextStyle(fontSize: 9))),
          ),
        ),
      ),
    );
  }

  // 操作按钮
  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD4AF37)),
      ),
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
        style: ElevatedButton.styleFrom(
          backgroundColor: en ? c : Colors.grey[700],
          minimumSize: const Size(48, 32),
        ),
        child: Text(label, style: const TextStyle(fontSize: 12, color: Colors.white)),
      ),
    );
  }

  Widget _buildRebelButton() {
    return GestureDetector(
      onTap: _rebel,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: const Text('我要造反', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }

  void _onDiceTap() {
    setState(() { isRolling = true; });
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() { _game.rollDice(); isRolling = false; });
    });
  }

  void _onDealTap() {
    setState(() {
      _game.deal();
      canRebel = _game.checkWuDuSan();
    });
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
