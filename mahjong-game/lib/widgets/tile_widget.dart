import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/tile_model.dart';

/// 麻将牌面组件
class MahjongTileWidget extends StatelessWidget {
  final Tile tile;
  final double size;
  final bool isSelected;
  final bool isGray;
  final bool selectable;
  final bool showBack;
  final VoidCallback? onTap;

  const MahjongTileWidget({
    super.key,
    required this.tile,
    this.size = 50,
    this.isSelected = false,
    this.isGray = false,
    this.selectable = false,
    this.showBack = false,
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
        if (tile.number == 1) name = 'Regular-Front';
        else name = 'Regular-Blank';
        break;
      default:
        name = 'Regular-Back';
    }
    return name;
  }

  @override
  Widget build(BuildContext context) {
    String imageName = _getTileImageName();
    
    return GestureDetector(
      onTap: selectable ? onTap : null,
      child: Container(
        width: size,
        height: size * 1.5,
        decoration: BoxDecoration(
          color: isGray ? Colors.grey.shade700 : Colors.white, // 白色底增加对比度
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? Colors.red : Colors.black,
            width: isSelected ? 3 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5), // 增加阴影对比度
              blurRadius: 6,
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
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white,
                    Colors.grey.shade100,
                  ],
                ),
              ),
              child: (imageName == 'Regular-Blank' && !showBack)
                  ? Center(
                      child: Text(
                        tile.displayName,
                        style: TextStyle(
                          fontSize: size * 0.4,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    )
                  : SvgPicture.asset(
                      'assets/images/tiles/Regular/$imageName.svg',
                      width: size,
                      height: size * 1.5,
                      fit: BoxFit.contain,
                      placeholderBuilder: (context) => Container(
                        color: Colors.white,
                        child: Center(
                          child: Text(
                            tile.displayName,
                            style: TextStyle(
                              fontSize: size * 0.4,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
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
