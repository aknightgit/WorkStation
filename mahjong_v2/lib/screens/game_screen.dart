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
          return Stack(
            children: [
              // 背景
              Container(color: const Color(0xFF0D1B2A)),
              
              // 桌面区域
              Center(
                child: Container(
                  width: w * 0.92,
                  height: h * 0.75,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF1B5E20), Color(0xFF0D3D0D)],
                    ),
                    border: Border.all(color: const Color(0xFFD4AF37), width: 3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              
              // 牌墙 - 简化版
              // 上
              Positioned(left: w * 0.15, right: w * 0.15, top: h * 0.12, child: _buildWallRow(12)),
              // 下
              Positioned(left: w * 0.15, right: w * 0.15, bottom: h * 0.18, child: _buildWallRow(12)),
              // 左
              Positioned(left: w * 0.08, top: h * 0.25, bottom: h * 0.25, child: _buildWallColumn(10)),
              // 右
              Positioned(right: w * 0.08, top: h * 0.25, bottom: h * 0.25, child: _buildWallColumn(10)),
              
              // 头像
              _buildAvatarSimple(w, h, 2, w/2, h*0.06), // 上
              _buildAvatarSimple(w, h, 3, w*0.08, h*0.45), // 左
              _buildAvatarSimple(w, h, 1, w*0.92, h*0.45), // 右
              _buildAvatarSimple(w, h, 0, w/2, h*0.89), // 下
              
              // 骰子/发牌
              if (_game.phase == GamePhase.waiting || _game.phase == GamePhase.diceRolling)
                Positioned(left: w * 0.4, right: w * 0.4, top: h * 0.35, child: _buildDiceSection()),
              
              // 手牌
              if (_game.phase == GamePhase.playing)
                Positioned(left: 10, right: 10, bottom: 20, child: _buildMyHand()),
              
              // 操作按钮
              if (_game.phase == GamePhase.playing)
                Positioned(right: 10, bottom: 30, child: _buildActionButtons()),
              
              // 造反按钮
              if (canRebel)
                Positioned(top: 60, left: 0, right: 0, child: Center(child: _buildRebelButton())),
            ],
          );
        },
      ),
    );
  }

  Widget _buildWallRow(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) => Container(
        width: 28, height: 36,
        margin: const EdgeInsets.symmetric(horizontal: 1),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)]),
          borderRadius: BorderRadius.circular(3),
          border: Border.all(color: const Color(0xFFD4AF37), width: 1),
        ),
      )),
    );
  }

  Widget _buildWallColumn(int count) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(count, (i) => Container(
        width: 28, height: 36,
        margin: const EdgeInsets.symmetric(vertical: 1),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)]),
          borderRadius: BorderRadius.circular(3),
          border: Border.all(color: const Color(0xFFD4AF37), width: 1),
        ),
      )),
    );
  }

  Widget _buildAvatarSimple(double w, double h, int index, double left, double top) {
    final names = ['东家', '南家', '西家', '北家'];
    final colors = [Colors.red, Colors.green, Colors.blue, Colors.yellow];
    return Positioned(
      left: left is double ? left - 20 : 20,
      top: top is double ? top - 15 : 20,
      child: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: colors[index],
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: Center(child: Text('${index+1}', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))),
      ),
    );
  }

  Widget _buildDiceSection() {
    return Column(
      children: [
        GestureDetector(
          onTap: _onDiceTap,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFD4AF37), width: 2),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDice(_game.diceValues[0]),
                const SizedBox(width: 16),
                _buildDice(_game.diceValues[1]),
              ],
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
              ),
              child: const Text('发牌', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
      ],
    );
  }

  Widget _buildDice(int v) {
    return Container(
      width: 50, height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD4AF37), width: 2),
      ),
      child: Center(child: Text('$v', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87))),
    );
  }

  Widget _buildMyHand() {
    final player = _game.players[0];
    return Container(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: player.handTiles.length,
        itemBuilder: (context, i) => GestureDetector(
          onTap: () => _playTile(i),
          child: Container(
            width: 36, height: 50,
            margin: const EdgeInsets.symmetric(horizontal: 1),
            decoration: BoxDecoration(
              color: selectedTileIndex == i ? Colors.yellow[200] : Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: const Color(0xFFD4AF37)),
            ),
            child: Center(child: Text(player.handTiles[i].displayName, style: const TextStyle(fontSize: 10))),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _actionBtn('摸', Colors.red, _game.pendingTile == null, _drawTile),
        _actionBtn('吃', Colors.orange, canChow, () {}),
        _actionBtn('碰', Colors.cyan, canPong, () {}),
        _actionBtn('杠', Colors.purple, canKong, () {}),
        _actionBtn('胡', Colors.yellow, canHu, () {}),
      ],
    );
  }

  Widget _actionBtn(String label, Color color, bool enabled, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: ElevatedButton(
        onPressed: enabled ? onPressed : null,
        style: ElevatedButton.styleFrom(backgroundColor: enabled ? color : Colors.grey[700], minimumSize: const Size(50, 32)),
        child: Text(label, style: const TextStyle(fontSize: 14, color: Colors.white)),
      ),
    );
  }

  Widget _buildRebelButton() {
    return GestureDetector(
      onTap: _rebel,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white, width: 2)),
        child: const Text('我要造反', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }

  void _onDiceTap() {
    setState(() { isRolling = true; });
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _game.rollDice();
        isRolling = false;
      });
    });
  }

  void _onDealTap() {
    setState(() {
      _game.deal();
      canRebel = _game.checkWuDuSan();
    });
  }

  void _drawTile() {
    final player = _game.players[_game.currentPlayerIndex];
    _game.drawTile(player);
    setState(() {});
  }

  void _playTile(int i) {
    final player = _game.players[0];
    final tile = player.handTiles[i];
    _game.playTile(player, tile);
    _game.pendingTile = tile;
    selectedTileIndex = null;
    setState(() {});
  }

  void _rebel() {
    _game.resolveRebelAsDraw(_game.dealerIndex);
    setState(() {});
  }
}
