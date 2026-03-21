import 'package:flutter/material.dart';
import '../models/tile_model.dart';

/// 麻将牌面组件
class MahjongTileWidget extends StatelessWidget {
  final Tile tile;
  final double size;
  final bool isSelected;
  final bool isGray;
  final bool selectable;
  final bool showBack;
  final bool useModernFace;
  final VoidCallback? onTap;

  const MahjongTileWidget({
    super.key,
    required this.tile,
    this.size = 50,
    this.isSelected = false,
    this.isGray = false,
    this.selectable = false,
    this.showBack = false,
    this.useModernFace = false,
    this.onTap,
  });

  String _getTileImageName() {
    if (showBack) return 'Regular-Back';
    String name = '';
    switch (tile.suit) {
      case TileSuit.wan:
        name = 'Regular-Man${tile.number}';
        break;
      case TileSuit.tong:
        name = 'Regular-Pin${tile.number}';
        break;
      case TileSuit.tiao:
        name = 'Regular-Sou${tile.number}';
        break;
      case TileSuit.feng:
        if (tile.number == 1) name = 'Regular-Ton';
        else if (tile.number == 2) name = 'Regular-Nan';
        else if (tile.number == 3) name = 'Regular-Shaa';
        else if (tile.number == 4) name = 'Regular-Pei';
        break;
      case TileSuit.jian:
        if (tile.number == 1) name = 'Regular-Haku';
        else if (tile.number == 2) name = 'Regular-Hatsu';
        else if (tile.number == 3) name = 'Regular-Chun';
        break;
      case TileSuit.hua:
        name = 'Regular-Front';
        break;
      default:
        name = 'Regular-Back';
    }
    return name;
  }

  @override
  Widget build(BuildContext context) {
    final imageName = _getTileImageName();

    Widget faceChild;
    if (showBack) {
      faceChild = Image.asset(
        'assets/images/tiles/Regular/$imageName.png',
        width: size,
        height: size * 1.5,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stack) => _buildFallback(),
      );
    } else if (useModernFace) {
      faceChild = _buildModernFace();
    } else {
      faceChild = Image.asset(
        'assets/images/tiles/Regular/$imageName.png',
        width: size,
        height: size * 1.5,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stack) => _buildFallback(),
      );
    }

    return GestureDetector(
      onTap: selectable ? onTap : null,
      child: Container(
        width: size,
        height: size * 1.5,
        decoration: BoxDecoration(
          color: isGray ? Colors.grey.shade700 : const Color(0xFFF8F8F8),
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color: isSelected ? Colors.red : Colors.grey.shade600,
            width: isSelected ? 2.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.6),
              blurRadius: 2,
              offset: const Offset(-1, -1),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 4,
              offset: const Offset(2, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: ColorFiltered(
            colorFilter: isGray
                ? const ColorFilter.mode(Colors.grey, BlendMode.saturation)
                : const ColorFilter.mode(Colors.transparent, BlendMode.multiply),
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white,
                    Color(0xFFEFEFEF),
                  ],
                ),
              ),
              child: faceChild,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFallback() {
    return Center(
      child: Text(
        tile.displayName,
        style: TextStyle(
          fontSize: size * 0.4,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildModernFace() {
    final color = _modernTextColor();
    if (tile.suit == TileSuit.wan ||
        tile.suit == TileSuit.tong ||
        tile.suit == TileSuit.tiao) {
      final suitChar = tile.suit == TileSuit.wan
          ? '万'
          : (tile.suit == TileSuit.tong ? '筒' : '条');
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${tile.number}',
              style: TextStyle(
                fontSize: size * 0.7,
                fontWeight: FontWeight.w800,
                color: color,
                height: 1,
              ),
            ),
            Text(
              suitChar,
              style: TextStyle(
                fontSize: size * 0.32,
                fontWeight: FontWeight.w700,
                color: color,
                height: 1,
              ),
            ),
          ],
        ),
      );
    }

    return Center(
      child: Text(
        tile.displayName,
        style: TextStyle(
          fontSize: size * 0.6,
          fontWeight: FontWeight.w800,
          color: color,
          height: 1,
        ),
      ),
    );
  }

  Color _modernTextColor() {
    switch (tile.suit) {
      case TileSuit.wan:
        return const Color(0xFFD32F2F);
      case TileSuit.tong:
        return const Color(0xFF1565C0);
      case TileSuit.tiao:
        return const Color(0xFF2E7D32);
      case TileSuit.feng:
        return const Color(0xFF5D4037);
      case TileSuit.jian:
        if (tile.number == 1) return const Color(0xFFD32F2F); // 中
        if (tile.number == 2) return const Color(0xFF2E7D32); // 发
        return const Color(0xFF1565C0); // 白
      case TileSuit.hua:
        return const Color(0xFF6A1B9A);
      default:
        return Colors.black87;
    }
  }
}


/// 牌池组件
class TilePoolWidget extends StatelessWidget {
  final List<Tile> tiles;
  final double tileSize;

  const TilePoolWidget({
    super.key,
    required this.tiles,
    this.tileSize = 30,
  });

  @override
  Widget build(BuildContext context) {
    if (tiles.isEmpty) {
      return const Text(
        '🀄',
        style: TextStyle(fontSize: 80, color: Colors.white24),
      );
    }

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      alignment: WrapAlignment.center,
      children: tiles.map((tile) => MahjongTileWidget(
        tile: tile,
        size: tileSize,
        isGray: true,
      )).toList(),
    );
  }
}

/// 玩家手牌组件
class HandTilesWidget extends StatelessWidget {
  final List<Tile> tiles;
  final double tileSize;
  final bool selectable;
  final Function(Tile)? onTileTap;
  final Tile? lastDrawnTile;

  const HandTilesWidget({
    super.key,
    required this.tiles,
    this.tileSize = 45,
    this.selectable = false,
    this.onTileTap,
    this.lastDrawnTile,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final count = tiles.length;
        const spacing = 2.0;
        final maxWidth = constraints.maxWidth;
        double size = tileSize;

        if (count > 0) {
          final needed = count * size + (count - 1) * spacing;
          if (needed > maxWidth) {
            size = (maxWidth - (count - 1) * spacing) / count;
            size = size.clamp(24.0, tileSize);
          }
        }

        final tileWidgets = <Widget>[];
        for (var i = 0; i < tiles.length; i++) {
          final tile = tiles[i];
          final isLast = lastDrawnTile != null && tile == lastDrawnTile;
          tileWidgets.add(
            Padding(
              padding: EdgeInsets.only(right: i == tiles.length - 1 ? 0 : spacing),
              child: MahjongTileWidget(
                tile: tile,
                size: size,
                selectable: selectable,
                isSelected: isLast,
                onTap: selectable && onTileTap != null ? () => onTileTap!(tile) : null,
              ),
            ),
          );
        }

        return SizedBox(
          height: size * 1.6,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: tileWidgets,
          ),
        );
      },
    );
  }
}
