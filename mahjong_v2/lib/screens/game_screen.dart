import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import 'package:mahjong_v2/game_logic/mahjong_game.dart';

class GameScreen extends StatefulWidget {
  final int maxDiceRolls;
  const GameScreen({super.key, this.maxDiceRolls = 2});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late final MahjongGame _game;
  bool isRolling = false;
  bool canPong = false, canKong = false, canHu = false, canChow = false;
  int? selectedTileIndex;
  final List<Color> _playerColors = [Colors.red, Colors.green, Colors.blue, Colors.orange];
  bool _freezeActive = false;
  int _freezeCountdown = 0;
  Timer? _freezeTimer;

  late AnimationController _diceAnimController;
  late Animation<double> _diceRotateAnimation;
  List<int> _displayDice = [1, 1];

  late AnimationController _rebelAnimController;
  late Animation<double> _rebelPulse;

  @override
  void initState() {
    super.initState();
    _game = MahjongGame(maxDiceRolls: widget.maxDiceRolls);
    _game.onStateChanged = () {
      if (mounted) setState(() {});
    };
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

    _rebelAnimController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );
    _rebelPulse = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _rebelAnimController, curve: Curves.easeInOut),
    );
    _rebelAnimController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _freezeTimer?.cancel();
    _game.onStateChanged = null;
    _diceAnimController.dispose();
    _rebelAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final player = _game.players[0];
    final isMyTurn = _game.currentPlayerIndex == 0;
    final canRespond = _game.awaitingPlayerResponse;
    final canActAfterDelay = _game.allowNextPlayerAction && _game.nextPlayerIndex == 0;
    final hasFlowerInHand = player.handTiles.any((t) => t.isFlower);
    final canSelfAction = isMyTurn && _game.mustDiscard;
    canPong = canRespond && _game.pendingTile != null && _game.canPong(player);
    canKong = (canRespond && (_game.canKong(player) || hasFlowerInHand)) || (canSelfAction && (_game.canKong(player) || hasFlowerInHand));
    canHu = (canRespond && _game.canHu(player)) || (canSelfAction && _game.canHu(player));
    canChow = canActAfterDelay && _game.pendingTile != null && _game.canChow(player);
    final canRebelNow = _game.canRebel(0);
    if (canRebelNow && !_rebelAnimController.isAnimating) {
      _rebelAnimController.repeat(reverse: true);
    } else if (!canRebelNow && _rebelAnimController.isAnimating) {
      _rebelAnimController.stop();
    }

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final sw = constraints.maxWidth;
          final sh = constraints.maxHeight;

          // Table dimensions: ~85% width, ~75% height
          final tableW = sw * 0.85;
          final tableH = sh * 0.75;
          final tableLeft = (sw - tableW) / 2;
          final tableTop = (sh - tableH) / 2;

          // Wall tile size: ~3% of screen width
          final wallTileW = sw * 0.03;
          final wallTileH = wallTileW * 1.3;

          // River/discard tile: 60% of wall tile
          final riverTileW = wallTileW * 0.6;
          final riverTileH = wallTileH * 0.6;

          // Hand tile: ~5% of screen width
          final handTileW = sw * 0.05;
          final handTileH = handTileW * 1.3;

          return Stack(
            children: [
              // ===== Wood background =====
              Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/backgrounds/light_wood.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              // ===== Rectangular green felt table =====
              Positioned(
                left: tableLeft,
                top: tableTop,
                width: tableW,
                height: tableH,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFD4AF37), width: 3),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.6), blurRadius: 20, spreadRadius: 4),
                    ],
                  ),
                ),
              ),

              // ===== Wall tiles: Top =====
              Positioned(
                left: tableLeft + wallTileW * 0.5,
                top: tableTop + wallTileH * 0.3,
                child: _buildWallRow(18, wallTileW * 0.7, wallTileH * 0.7),
              ),
              // ===== Wall tiles: Bottom =====
              Positioned(
                left: tableLeft + wallTileW * 0.5,
                top: tableTop + tableH - wallTileH * 0.7 - wallTileH * 0.3,
                child: _buildWallRow(18, wallTileW * 0.7, wallTileH * 0.7),
              ),
              // ===== Wall tiles: Left (vertical) =====
              Positioned(
                left: tableLeft + wallTileW * 0.3,
                top: tableTop + wallTileH * 0.5,
                child: _buildWallCol(18, wallTileW * 0.7, wallTileH * 0.7),
              ),
              // ===== Wall tiles: Right (vertical) =====
              Positioned(
                left: tableLeft + tableW - wallTileW * 0.7 - wallTileW * 0.3,
                top: tableTop + wallTileH * 0.5,
                child: _buildWallCol(18, wallTileW * 0.7, wallTileH * 0.7),
              ),

              // ===== Avatars =====
              _buildAvatar('东', Colors.red, sw * 0.5, tableTop - 20, _playerColors[0], _game.players[0].totalScore),
              _buildAvatar('南', Colors.green, tableLeft + tableW + 28, sh * 0.5, _playerColors[1], _game.players[1].totalScore),
              _buildAvatar('西', Colors.blue, sw * 0.5, tableTop + tableH + 20, _playerColors[2], _game.players[2].totalScore),
              _buildAvatar('北', Colors.orange, tableLeft - 28, sh * 0.5, _playerColors[3], _game.players[3].totalScore),

              // ===== Dice + Deal button =====
              if (_game.phase == GamePhase.waiting || _game.phase == GamePhase.diceRolling)
                Positioned(
                  left: sw * 0.35,
                  right: sw * 0.35,
                  top: sh * 0.4,
                  child: Column(
                    children: [
                      _buildDiceWithAnimation(),
                      const SizedBox(height: 10),
                      Text('掷骰次数：${_game.diceRollCount}/${_game.maxDiceRolls}',
                          style: const TextStyle(color: Colors.white70, fontSize: 12)),
                      const SizedBox(height: 12),
                      if (_game.diceRolled || _game.phase == GamePhase.diceRolling) _buildDealButton(),
                    ],
                  ),
                ),

              // ===== Multiplier display (top of table) =====
              if (_game.phase == GamePhase.playing)
                Positioned(
                  left: 0, right: 0,
                  top: tableTop + tableH * 0.05,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('×${_game.finalMultiplier}',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,
                                  color: _multiplierColor(_game.finalMultiplier))),
                          const SizedBox(width: 10),
                          if (_game.wildTile != null)
                            Row(
                              children: [
                                const Text('百搭', style: TextStyle(fontSize: 13, color: Colors.white70)),
                                const SizedBox(width: 4),
                                Container(
                                  width: 28, height: 36,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(3),
                                    border: Border.all(color: const Color(0xFFD4AF37)),
                                  ),
                                  child: Image.asset(_game.wildTile!.imagePath, fit: BoxFit.contain,
                                      errorBuilder: (_, __, ___) =>
                                          Center(child: Text(_game.wildTile!.displayName, style: const TextStyle(fontSize: 7)))),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ),

              if (_freezeActive)
                Positioned.fill(
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Text('等待 $_freezeCountdown',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                ),

              // ===== Discard area (River/河) =====
              if (_game.phase == GamePhase.playing) ...[
                _buildRiverArea(tableLeft, tableTop, tableW, tableH, riverTileW, riverTileH),
              ],

              // ===== Hand tiles (bottom) =====
              if (_game.phase == GamePhase.playing)
                Positioned(
                  left: sw * 0.12, right: sw * 0.12,
                  bottom: sh * 0.02,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (player.flowerTiles.isNotEmpty || player.melds.isNotEmpty)
                        SizedBox(width: handTileW * 4, child: _buildMeldsArea(handTileW, handTileH)),
                      if (player.flowerTiles.isNotEmpty || player.melds.isNotEmpty)
                        const SizedBox(width: 6),
                      Expanded(child: _buildMyHand(handTileW, handTileH)),
                    ],
                  ),
                ),

              // ===== Turn hint (center of table, above river) =====
              if (_game.phase == GamePhase.playing)
                Positioned(
                  left: 0, right: 0,
                  top: tableTop + tableH * 0.32,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(_turnHintText(),
                          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),

              // ===== Rebel button =====
              if (canRebelNow)
                Positioned(
                  top: 50, left: 0, right: 0,
                  child: Center(child: _buildRebelButtons()),
                ),

              // ===== Action buttons (right side) =====
              if (_game.phase == GamePhase.playing) _buildActionButtons(),

              // ===== Settlement overlay =====
              if (_game.phase == GamePhase.scoring && _game.lastSettlement != null)
                _buildSettlementOverlay(sw, sh),
            ],
          );
        },
      ),
    );
  }

  // ===== Wall row: horizontal tiles using Back.png =====
  Widget _buildWallRow(int count, double w, double h) {
    return Row(
      children: List.generate(count, (i) => Container(
        width: w, height: h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(2),
          border: Border.all(color: const Color(0xFFD4AF37), width: 0.8),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: Image.asset('assets/images/tiles/Regular/Back.png', fit: BoxFit.cover),
        ),
      )),
    );
  }

  // ===== Wall column: vertical tiles using Back.png =====
  Widget _buildWallCol(int count, double w, double h) {
    return Column(
      children: List.generate(count, (i) => Container(
        width: w, height: h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(2),
          border: Border.all(color: const Color(0xFFD4AF37), width: 0.8),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: Image.asset('assets/images/tiles/Regular/Back.png', fit: BoxFit.cover),
        ),
      )),
    );
  }

  // ===== River (discard area) - 4 quadrants =====
  Widget _buildRiverArea(double tableLeft, double tableTop, double tableW, double tableH, double tw, double th) {
    final riverW = tableW * 0.50;
    final riverH = tableH * 0.40;
    final riverLeft = tableLeft + (tableW - riverW) / 2;
    final riverTop = tableTop + (tableH - riverH) / 2;

    return Stack(
      children: [
        // Player 0 (South) - bottom half of river
        _buildDiscardGrid(
          left: riverLeft, top: riverTop + riverH * 0.52,
          tiles: _game.players[0].playedTiles,
          tileW: tw, tileH: th, cols: 6, reversed: false,
        ),
        // Player 2 (North) - top half of river (reversed: newest on top)
        _buildDiscardGrid(
          left: riverLeft, top: riverTop,
          tiles: _game.players[2].playedTiles,
          tileW: tw, tileH: th, cols: 6, reversed: true,
        ),
        // Player 1 (West) - right half of river
        _buildDiscardGridVertical(
          left: riverLeft + riverW * 0.52, top: riverTop,
          tiles: _game.players[1].playedTiles,
          tileW: tw, tileH: th, rows: 5,
        ),
        // Player 3 (East) - left half of river
        _buildDiscardGridVertical(
          left: riverLeft, top: riverTop,
          tiles: _game.players[3].playedTiles,
          tileW: tw, tileH: th, rows: 5,
        ),
      ],
    );
  }

  Widget _buildDiscardGrid({
    required double left, required double top,
    required List<Tile> tiles,
    required double tileW, required double tileH,
    required int cols, required bool reversed,
  }) {
    if (tiles.isEmpty) return const SizedBox.shrink();
    final displayTiles = reversed ? tiles.reversed.toList() : tiles;
    return Positioned(
      left: left, top: top,
      child: SizedBox(
        width: cols * (tileW + 1),
        child: Wrap(
          spacing: 1, runSpacing: 1,
          children: displayTiles.map((t) => Container(
            width: tileW, height: tileH,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(2),
              border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.5), width: 0.5),
            ),
            child: Image.asset(t.imagePath, fit: BoxFit.contain,
                errorBuilder: (_, __, ___) =>
                    Center(child: Text(t.displayName, style: TextStyle(fontSize: tileW * 0.3)))),
          )).toList(),
        ),
      ),
    );
  }

  Widget _buildDiscardGridVertical({
    required double left, required double top,
    required List<Tile> tiles,
    required double tileW, required double tileH,
    required int rows,
  }) {
    if (tiles.isEmpty) return const SizedBox.shrink();
    return Positioned(
      left: left, top: top,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(
          (tiles.length / rows).ceil(),
          (col) {
            final start = col * rows;
            final end = (start + rows).clamp(0, tiles.length);
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: tiles.sublist(start, end).map((t) => Container(
                width: tileW, height: tileH,
                margin: const EdgeInsets.only(right: 1, bottom: 1),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(2),
                  border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.5), width: 0.5),
                ),
                child: Image.asset(t.imagePath, fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) =>
                        Center(child: Text(t.displayName, style: TextStyle(fontSize: tileW * 0.3)))),
              )).toList(),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAvatar(String name, Color c, double x, double y, Color dotColor, int score) {
    return Positioned(
      left: x - 28, top: y - 28,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: c, shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2.5),
                  boxShadow: [BoxShadow(color: c.withValues(alpha: 0.5), blurRadius: 8)],
                ),
                child: Center(
                    child: Text(name,
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))),
              ),
              Positioned(
                right: -2, top: -2,
                child: Container(
                  width: 12, height: 12,
                  decoration: BoxDecoration(
                      color: dotColor, shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(8)),
            child: Text('${score > 0 ? "+" : ""}$score',
                style: TextStyle(color: score >= 0 ? Colors.green : Colors.red,
                    fontSize: 11, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildDiceWithAnimation() {
    return GestureDetector(
      onTap: isRolling ? null : _onDiceTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFD4AF37), width: 3),
          boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 20, offset: const Offset(0, 10))],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _build3DDice(_displayDice[0]),
            const SizedBox(width: 24),
            _build3DDice(_displayDice[1]),
          ],
        ),
      ),
    );
  }

  Widget _build3DDice(int value) {
    return AnimatedBuilder(
      animation: _diceRotateAnimation,
      builder: (context, child) {
        final progress = isRolling ? _diceRotateAnimation.value : 0.0;
        final bounce = isRolling ? (1 - (progress * 2 - 1).abs()) * 1.5 : 0.0;
        final rotation = isRolling ? progress * 6.28 : 0.0;

        return Transform(
          transform: Matrix4.identity()
            ..translateByDouble(0.0, -bounce, 0.0, 1.0)
            ..rotateZ(rotation),
          alignment: Alignment.center,
          child: Container(
            width: 60, height: 60,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft, end: Alignment.bottomRight,
                colors: [Colors.white, Color(0xFFEEEEEE)],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black87, width: 2),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 8, offset: const Offset(2, 4))],
            ),
            child: Center(child: _buildDiceDots(value)),
          ),
        );
      },
    );
  }

  Widget _buildDiceDots(int value) {
    final positions = {
      1: [(0.5, 0.5)],
      2: [(0.2, 0.2), (0.8, 0.8)],
      3: [(0.2, 0.2), (0.5, 0.5), (0.8, 0.8)],
      4: [(0.2, 0.2), (0.2, 0.8), (0.8, 0.2), (0.8, 0.8)],
      5: [(0.2, 0.2), (0.2, 0.8), (0.5, 0.5), (0.8, 0.2), (0.8, 0.8)],
      6: [(0.2, 0.2), (0.2, 0.5), (0.2, 0.8), (0.8, 0.2), (0.8, 0.5), (0.8, 0.8)],
    };
    final dotSize = 12.0;
    return SizedBox(
      width: 50, height: 50,
      child: Stack(
        children: (positions[value] ?? []).map((pos) => Positioned(
          left: pos.$1 * 50 - dotSize / 2,
          top: pos.$2 * 50 - dotSize / 2,
          child: Container(
            width: dotSize, height: dotSize,
            decoration: BoxDecoration(
              color: Colors.red, shape: BoxShape.circle,
              boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 2)],
            ),
          ),
        )).toList(),
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
          boxShadow: [BoxShadow(color: Colors.green.withValues(alpha: 0.5), blurRadius: 10)],
        ),
        child: const Text('发牌', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }

  // ===== Hand tiles with selected pop-up =====
  Widget _buildMyHand(double w, double h) {
    final player = _game.players[0];
    return Container(
      height: h + 20,
      padding: const EdgeInsets.symmetric(vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (int i = 0; i < player.handTiles.length; i++)
            GestureDetector(
              onTap: () => _playTile(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: w,
                height: h,
                margin: const EdgeInsets.symmetric(horizontal: 1),
                transform: Matrix4.translationValues(
                    0, selectedTileIndex == i ? -h * 0.3 : 0, 0),
                decoration: BoxDecoration(
                  color: selectedTileIndex == i ? Colors.yellow[200] : Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: selectedTileIndex == i
                        ? Colors.yellow
                        : const Color(0xFFD4AF37).withValues(alpha: 0.6),
                    width: selectedTileIndex == i ? 2 : 1,
                  ),
                  boxShadow: selectedTileIndex == i
                      ? [const BoxShadow(color: Colors.yellowAccent, blurRadius: 6)]
                      : null,
                ),
                child: Image.asset(player.handTiles[i].imagePath, fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) =>
                        Center(child: Text(player.handTiles[i].displayName, style: const TextStyle(fontSize: 9)))),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMeldsArea(double w, double h) {
    final player = _game.players[0];
    if (player.melds.isEmpty && player.flowerTiles.isEmpty) return const SizedBox.shrink();

    final sourceWidgets = <Widget>[];
    player.meldSourceCounts.forEach((idx, count) {
      final name = _game.players[idx].name;
      final color = _playerColors[idx % _playerColors.length];
      sourceWidgets.add(Text('$name×$count',
          style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.bold)));
      sourceWidgets.add(const SizedBox(width: 5));
    });
    if (sourceWidgets.isNotEmpty) sourceWidgets.removeLast();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (sourceWidgets.isNotEmpty)
          SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: sourceWidgets)),
        if (sourceWidgets.isNotEmpty) const SizedBox(height: 3),
        SizedBox(
          height: h * 0.65,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                if (player.flowerTiles.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    child: Row(
                      children: player.flowerTiles.map((t) => Container(
                        width: w * 0.55, height: h * 0.55,
                        margin: const EdgeInsets.symmetric(horizontal: 1),
                        child: Image.asset(t.imagePath, fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) =>
                                Center(child: Text(t.displayName, style: const TextStyle(fontSize: 7)))),
                      )).toList(),
                    ),
                  ),
                ...List.generate(player.melds.length, (mi) {
                  final meld = player.melds[mi];
                  final hidden = (mi < player.meldHidden.length) ? player.meldHidden[mi] : false;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    child: Row(
                      children: meld.map((t) {
                        final img = hidden ? 'assets/images/tiles/Regular/Back.png' : t.imagePath;
                        return Container(
                          width: w * 0.55, height: h * 0.55,
                          margin: const EdgeInsets.symmetric(horizontal: 1),
                          child: Image.asset(img, fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) =>
                                  Center(child: Text(t.displayName, style: const TextStyle(fontSize: 7)))),
                        );
                      }).toList(),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ===== Action buttons - right side, vertically stacked =====
  Widget _buildActionButtons() {
    final btnSize = 65.0;
    final subBtnSize = btnSize * 0.52;
    final showDraw = _game.allowNextPlayerAction && _game.nextPlayerIndex == 0 && _game.pendingTile != null;
    final showWait = _game.canUseFreeze(0);
    final canFreeze = showWait && !_freezeActive;
    final isRobbingKong = _game.robbingKong && _game.awaitingPlayerResponse;
    final canRobKong = isRobbingKong && canHu;

    return Positioned(
      right: 8,
      top: 0, bottom: 0,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showDraw)
              _buildCircleBtn('摸', Colors.red, showDraw, btnSize, _drawTile),
            if (showDraw) const SizedBox(height: 8),
            _buildCircleBtn('吃', Colors.orange, canChow, subBtnSize, _onChow),
            const SizedBox(height: 6),
            _buildCircleBtn('碰', Colors.cyan, canPong, subBtnSize, _onPong),
            const SizedBox(height: 6),
            _buildCircleBtn('杠', Colors.purple, canKong, subBtnSize, _onKong),
            const SizedBox(height: 6),
            if (canRobKong)
              _buildCircleBtn('抢杠', Colors.red, true, subBtnSize, _onHu)
            else
              _buildCircleBtn('胡', Colors.yellow[700]!, canHu, subBtnSize, _onHu),
            if (showWait) ...[
              const SizedBox(height: 6),
              _buildCircleBtn('等', Colors.indigo, canFreeze, subBtnSize * 0.9, _startFreeze),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCircleBtn(String label, Color baseColor, bool enabled, double size, VoidCallback onTap) {
    final color = enabled ? baseColor : Colors.grey[600]!;
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: size, height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          border: Border.all(color: enabled ? Colors.white : Colors.grey[400]!, width: 2),
          boxShadow: enabled ? [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 10)] : null,
        ),
        child: Center(
          child: Text(label,
              style: TextStyle(fontSize: size * 0.32, fontWeight: FontWeight.bold,
                  color: enabled ? Colors.white : Colors.grey[400])),
        ),
      ),
    );
  }

  Widget _buildRebelButtons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _rebelPulse,
          builder: (context, child) {
            return Transform.scale(
              scale: _rebelPulse.value,
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [BoxShadow(color: Colors.red.withValues(alpha: 0.6), blurRadius: 18, spreadRadius: 2)],
                  borderRadius: BorderRadius.circular(28),
                ),
                child: child,
              ),
            );
          },
          child: GestureDetector(
            onTap: _rebelAccept,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
              decoration: BoxDecoration(
                  color: Colors.red, borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: Colors.white, width: 2)),
              child: const Text('我要造反',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: _rebelDecline,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
            decoration: BoxDecoration(
                color: Colors.grey[700], borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white70, width: 1.5)),
            child: const Text('不造反',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ),
      ],
    );
  }

  String _turnHintText() {
    if (_freezeActive) return '等待中…';
    if (_game.robbingKong && _game.awaitingPlayerResponse) return '可抢杠胡';
    if (_game.awaitingPlayerResponse) return '可碰/杠/胡';
    if (_game.allowNextPlayerAction && _game.nextPlayerIndex == 0) return '可摸牌/可吃牌';
    if (_game.currentPlayerIndex == 0) {
      return _game.mustDiscard ? '轮到你出牌' : '轮到你摸牌';
    }
    return '等待其他玩家...';
  }

  Color _multiplierColor(int m) {
    if (m >= 8) return Colors.red;
    if (m >= 4) return Colors.orange;
    if (m >= 2) return Colors.yellow;
    return Colors.green;
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
                Text(s.isDraw ? '流局结算' : '本局结算',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                if (!s.isDraw && s.winnerIndex != null)
                  Text('胜者：${_game.players[s.winnerIndex!].name}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text('原因：${s.reason}', style: const TextStyle(fontSize: 14)),
                const SizedBox(height: 4),
                Text('底分 ${s.basePoints} × 回合${s.roundMultiplier} × 额外${s.extraMultiplier} = ${s.totalPoints}',
                    style: const TextStyle(fontSize: 14)),
                if (s.details.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: s.details
                        .map((d) => Text(d, style: const TextStyle(fontSize: 12, color: Colors.black87)))
                        .toList(),
                  ),
                ],
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
                          Text(delta >= 0 ? '+$delta' : '$delta',
                              style: TextStyle(color: color, fontWeight: FontWeight.bold)),
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

  // ========== Game logic methods (unchanged) ==========

  void _onNextRound() {
    _cancelFreeze();
    setState(() {
      _game.resetForNextRound();
    });
  }

  void _onDiceTap() {
    _cancelFreeze();
    if (!_game.canRollDice) return;
    setState(() {
      isRolling = true;
      _displayDice = [Random().nextInt(6) + 1, Random().nextInt(6) + 1];
    });
    _diceAnimController.forward(from: 0);
    _game.rollDice();
  }

  void _onDealTap() {
    _cancelFreeze();
    setState(() {
      _game.deal();
    });
    if (_game.currentPlayerIndex != 0) {
      Future.delayed(const Duration(milliseconds: 500), () {
        _game.aiDiscard(_game.currentPlayerIndex);
        setState(() {});
      });
    }
  }

  void _cancelFreeze({bool resume = false}) {
    if (!_freezeActive) return;
    _freezeTimer?.cancel();
    _freezeActive = false;
    _freezeCountdown = 0;
    _game.freezeActive = false;
    if (resume) {
      _game.processTurn();
    }
  }

  void _startFreeze() {
    if (_freezeActive || !_game.canUseFreeze(0)) return;
    _game.useFreeze(0);
    _freezeTimer?.cancel();
    _freezeActive = true;
    _freezeCountdown = 3;
    _game.freezeActive = true;
    setState(() {});
    _freezeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_freezeCountdown <= 1) {
        timer.cancel();
        _freezeActive = false;
        _freezeCountdown = 0;
        _game.freezeActive = false;
        _game.processTurn();
        setState(() {});
      } else {
        _freezeCountdown -= 1;
        setState(() {});
      }
    });
  }

  void _drawTile() {
    if (!(_game.allowNextPlayerAction && _game.nextPlayerIndex == 0)) return;
    _cancelFreeze();
    _game.playerDrawAfterDelay(0);
    setState(() {});
  }

  void _onKong() {
    _cancelFreeze();
    final p = _game.players[0];
    if (_game.currentPlayerIndex != 0 && !_game.awaitingPlayerResponse) return;

    if (p.handTiles.any((t) => t.isFlower)) {
      while (_game.wall.isNotEmpty) {
        final flowerIndex = p.handTiles.indexWhere((t) => t.isFlower);
        if (flowerIndex == -1) break;
        final flower = p.handTiles.removeAt(flowerIndex);
        p.flowerTiles.add(flower);
        final newTile = _game.drawTile(p, isKongDraw: true);
        if (newTile == null) break;
        if (newTile.isFlower) {
          p.handTiles.remove(newTile);
          p.flowerTiles.add(newTile);
          continue;
        }
      }
      setState(() {});
      return;
    }

    if (_game.canKong(p)) {
      final kongTiles = _game.getKongableTiles(p);
      if (kongTiles.isNotEmpty) {
        final isHidden = _game.pendingTile == null;
        final ok = _game.doKong(p, kongTiles.first, isHidden: isHidden);
        if (!ok) {
          setState(() {});
          return;
        }
        _game.awaitingPlayerResponse = false;
        if (p.index == 0) {
          _game.mustDiscard = false;
        }
        while (_game.wall.isNotEmpty) {
          final newTile = _game.drawTile(p, isKongDraw: true);
          if (newTile == null) break;
          if (newTile.isFlower) {
            p.handTiles.remove(newTile);
            p.flowerTiles.add(newTile);
            continue;
          }
          break;
        }
      }
    }
    setState(() {});
  }

  void _onChow() {
    _cancelFreeze();
    final p = _game.players[0];
    if (!_game.doChow(p, null)) return;
    _game.awaitingPlayerResponse = false;
    setState(() {});
  }

  void _onPong() {
    _cancelFreeze();
    final p = _game.players[0];
    if (!_game.doPong(p)) return;
    _game.awaitingPlayerResponse = false;
    setState(() {});
  }

  void _onHu() {
    _cancelFreeze();
    _game.awaitingPlayerResponse = false;
    if (_game.robbingKong) {
      _game.playerRobKongHu();
    } else if (_game.pendingTile != null) {
      _game.claimHu(0);
      _game.resolveMultiHuFromPlayer();
    } else {
      _game.playerWins(0);
    }
    setState(() {});
  }

  // ignore: unused_element
  void _onPass() {
    _cancelFreeze();
    _game.playerPass();
    setState(() {});
  }

  void _playTile(int i) {
    if (_game.currentPlayerIndex != 0) return;
    if (!_game.mustDiscard) return;
    _cancelFreeze();
    final p = _game.players[0];
    final t = p.handTiles[i];
    _game.playTile(p, t);
    selectedTileIndex = null;
    setState(() {});

    _triggerAIAfterPlayer();
  }

  void _triggerAIAfterPlayer() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_game.gameEnded) return;
      if (_game.pendingTile != null) return;

      _game.nextPlayer();
      while (_game.currentPlayerIndex != 0 && !_game.gameEnded) {
        final idx = _game.currentPlayerIndex;
        _game.drawTile(_game.players[idx]);

        if (_game.canHu(_game.players[idx])) {
          _game.playerWins(idx);
          break;
        }

        _game.aiDiscard(idx);

        if (_game.pendingTile != null) break;
        _game.nextPlayer();
      }
      setState(() {});
    });
  }

  void _rebelAccept() {
    _game.decideRebel(0, true);
    setState(() {});
  }

  void _rebelDecline() {
    _game.decideRebel(0, false);
    setState(() {});
  }
}
