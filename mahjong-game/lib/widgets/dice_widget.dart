import 'dart:math';
import 'package:flutter/material.dart';

/// 骰子组件
class Dice extends StatefulWidget {
  final int value;
  final double size;

  const Dice({
    super.key,
    required this.value,
    this.size = 40,
  });

  @override
  State<Dice> createState() => _DiceState();
}

class _DiceState extends State<Dice> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.black, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(2, 2),
              ),
            ],
          ),
          child: Center(
            child: _buildDots(),
          ),
        );
      },
    );
  }

  Widget _buildDots() {
    // 骰子点数样式
    final dotSize = widget.size * 0.25;
    
    return Stack(
      children: _getDotPositions(widget.value).map((pos) {
        return Positioned(
          left: widget.size * pos.dx,
          top: widget.size * pos.dy,
          child: Container(
            width: dotSize,
            height: dotSize,
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
          ),
        );
      }).toList(),
    );
  }

  List<Offset> _getDotPositions(int value) {
    switch (value) {
      case 1: return [const Offset(0.35, 0.35)];
      case 2: return [const Offset(0.15, 0.15), const Offset(0.55, 0.55)];
      case 3: return [const Offset(0.15, 0.15), const Offset(0.35, 0.35), const Offset(0.55, 0.55)];
      case 4: return [const Offset(0.15, 0.15), const Offset(0.55, 0.15), const Offset(0.15, 0.55), const Offset(0.55, 0.55)];
      case 5: return [const Offset(0.15, 0.15), const Offset(0.55, 0.15), const Offset(0.35, 0.35), const Offset(0.15, 0.55), const Offset(0.55, 0.55)];
      case 6: return [const Offset(0.15, 0.15), const Offset(0.55, 0.15), const Offset(0.15, 0.35), const Offset(0.55, 0.35), const Offset(0.15, 0.55), const Offset(0.55, 0.55)];
      default: return [const Offset(0.35, 0.35)];
    }
  }

  /// 掷骰子 - 使用外部传入的Random实例确保真随机
  static int roll(Random? random) {
    return (random ?? Random()).nextInt(6) + 1;
  }
}
