import 'package:flutter/material.dart';

/// 麻将桌背景组件
class MahjongTable extends StatelessWidget {
  final Widget child;
  final Color tableColor;

  const MahjongTable({
    super.key,
    required this.child,
    this.tableColor = const Color(0xFF2E7D32), // 绿色牌桌
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        // 牌桌纹理
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            tableColor.withOpacity(0.9),
            tableColor,
            tableColor.withOpacity(0.85),
          ],
        ),
        border: Border.all(
          color: const Color(0xFF8D6E63), // 木质边框
          width: 20,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: child,
      ),
    );
  }
}

/// 牌池组件
class TilePool extends StatelessWidget {
  final List<String> playedTiles;
  final int maxPerRow;

  const TilePool({
    super.key,
    required this.playedTiles,
    this.maxPerRow = 10,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 2,
      runSpacing: 2,
      children: playedTiles.map((tile) {
        return Container(
          width: 25,
          height: 35,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(2),
            border: Border.all(color: Colors.grey),
          ),
          child: Center(
            child: Text(
              tile,
              style: const TextStyle(fontSize: 10),
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// 胡牌动画效果
class HuAnimation extends StatefulWidget {
  final bool show;
  final VoidCallback? onComplete;

  const HuAnimation({
    super.key,
    required this.show,
    this.onComplete,
  });

  @override
  State<HuAnimation> createState() => _HuAnimationState();
}

class _HuAnimationState extends State<HuAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    if (widget.show) {
      _controller.forward().then((_) {
        widget.onComplete?.call();
      });
    }
  }

  @override
  void didUpdateWidget(HuAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.show && !oldWidget.show) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.show && !_controller.isAnimating) {
      return const SizedBox();
    }

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Center(
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.8),
                    blurRadius: 30,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: const Text(
                '胡!',
                style: TextStyle(
                  fontSize: 60,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
