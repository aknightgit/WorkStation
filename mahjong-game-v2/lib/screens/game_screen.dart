import 'package:flutter/material.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  int currentPlayerIndex = 0;
  int dealerIndex = 0;
  int roundMultiplier = 1;
  int globalMultiplier = 1;
  int remainingTiles = 144;
  List<int> diceValues = [1, 1];
  bool diceRolled = false;
  bool hasDealt = false;

  static const int stacksPerSide = 18;
  static const double tileWidth = 24.0;
  static const double tileHeight = 32.0;

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
              
              final tableHeight = h * 0.55;
              final tableTop = h * 0.40;
              final bottomWidth = w * 0.95;
              final topWidth = w * 0.75;
              
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
                  
                  // 顶部牌墙
                  Positioned(
                    left: w * 0.12, right: w * 0.12,
                    top: tableTop + 10,
                    child: _buildWallRow(stacksPerSide),
                  ),
                  // 底部牌墙
                  Positioned(
                    left: w * 0.12, right: w * 0.12,
                    bottom: h - (tableTop + tableHeight) + 10,
                    child: _buildWallRow(stacksPerSide),
                  ),
                  // 左侧牌墙
                  Positioned(
                    left: w * 0.08,
                    top: tableTop + tableHeight * 0.15,
                    bottom: h - (tableTop + tableHeight) + tableHeight * 0.15,
                    child: _buildWallColumn(stacksPerSide),
                  ),
                  // 右侧牌墙
                  Positioned(
                    right: w * 0.08,
                    top: tableTop + tableHeight * 0.15,
                    bottom: h - (tableTop + tableHeight) + tableHeight * 0.15,
                    child: _buildWallColumn(stacksPerSide),
                  ),
                  
                  // 弃牌区 6x6
                  Positioned(
                    left: w * 0.20, right: w * 0.20,
                    top: tableTop + tableHeight * 0.25,
                    bottom: tableTop + tableHeight * 0.75,
                    child: _buildDiscardArea(),
                  ),
                  
                  // 玩家头像
                  Positioned(top: 20, left: 0, right: 0, child: Center(child: _buildAvatar(2))),
                  Positioned(left: 10, top: h * 0.35, child: _buildAvatar(3)),
                  Positioned(right: 10, top: h * 0.35, child: _buildAvatar(1)),
                  Positioned(bottom: 30, left: 0, right: 0, child: Center(child: _buildAvatar(0))),
                  
                  // 顶部信息
                  Positioned(top: 80, left: 20, child: _buildDealerInfo()),
                  Positioned(top: 80, right: 20, child: _buildMultiplier()),
                  
                  // 掷骰子
                  if (!diceRolled || !hasDealt)
                    Positioned(
                      left: w * 0.40, right: w * 0.40,
                      top: tableTop + tableHeight * 0.45,
                      child: _buildDiceSection(),
                    ),
                  
                  // 手牌
                  Positioned(left: 20, right: 20, bottom: 40, child: _buildMyHand()),
                  
                  // 操作按钮
                  Positioned(right: 20, bottom: 40, child: _buildActionButtons()),
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
        width: tileWidth, height: tileHeight,
        margin: const EdgeInsets.symmetric(horizontal: 1),
        decoration: BoxDecoration(
          color: const Color(0xFF2E7D32),
          borderRadius: BorderRadius.circular(3),
          border: Border.all(color: Colors.white24, width: 1),
        ),
      )),
    );
  }

  Widget _buildWallColumn(int count) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(count, (i) => Container(
        width: tileWidth, height: tileHeight,
        margin: const EdgeInsets.symmetric(vertical: 1),
        decoration: BoxDecoration(
          color: const Color(0xFF2E7D32),
          borderRadius: BorderRadius.circular(3),
          border: Border.all(color: Colors.white24, width: 1),
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
        itemCount: 36,
        itemBuilder: (context, index) => Container(
          decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(2)),
        ),
      ),
    );
  }

  Widget _buildAvatar(int index) {
    final names = ['东', '南', '西', '北'];
    final colors = [Colors.red, Colors.blue, Colors.green, Colors.orange];
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(8),
        border: currentPlayerIndex == index ? Border.all(color: Colors.yellow, width: 2) : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(radius: 20, backgroundColor: colors[index], child: Text(names[index])),
          const SizedBox(height: 4),
          const Text('积分 0', style: TextStyle(color: Colors.white70, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildDealerInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(8)),
      child: Text('庄家: ${['东', '南', '西', '北'][dealerIndex]}', style: const TextStyle(color: Colors.white, fontSize: 12)),
    );
  }

  Widget _buildMultiplier() {
    final mult = roundMultiplier * globalMultiplier;
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

  Widget _buildDiceSection() {
    return GestureDetector(
      onTap: () => setState(() {
        diceValues[0] = DateTime.now().millisecond % 6 + 1;
        diceValues[1] = DateTime.now().microsecond % 6 + 1;
        diceRolled = true;
      }),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(16)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${diceValues[0]}', style: const TextStyle(fontSize: 48, color: Colors.white)),
            const SizedBox(width: 16),
            Text('${diceValues[1]}', style: const TextStyle(fontSize: 48, color: Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget _buildMyHand() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(13, (i) => Container(
          width: 28, height: 38,
          margin: const EdgeInsets.symmetric(horizontal: 1),
          decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(3),
            border: Border.all(color: Colors.black26),
          ),
        )),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: Colors.grey.shade800, borderRadius: BorderRadius.circular(12)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: ['摸','打','吃','碰','杠','胡'].asMap().entries.map((e) {
          final colors = [Colors.red, Colors.blue, Colors.orange, Colors.cyan, Colors.purple, Colors.yellow];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: colors[e.key],
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                minimumSize: const Size(40, 28),
              ),
              child: Text(e.value, style: const TextStyle(fontSize: 12, color: Colors.white)),
            ),
          );
        }).toList(),
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
