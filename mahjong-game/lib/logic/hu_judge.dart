import '../models/tile_model.dart';

/// 胡牌判定器 - 判定是否满足胡牌条件
class HuJudge {
  /// 判定是否能胡牌
  /// 使用标准麻将胡牌算法：4组顺子/刻子 + 1个对子
  static bool canHu(List<Tile> tiles) {
    if (tiles.isEmpty) return false;
    
    // 去除花牌
    final pureTiles = tiles.where((t) => !t.isHua).toList();
    final huaCount = tiles.length - pureTiles.length;
    
    // 手牌数必须是 3n + 2
    if (pureTiles.length % 3 != 2) return false;
    
    // 排序
    pureTiles.sort((a, b) => a.type.index.compareTo(b.type.index));
    
    // 尝试所有可能的雀头（对子）
    final uniqueTypes = <TileType>{};
    for (final tile in pureTiles) {
      uniqueTypes.add(tile.type);
    }
    
    for (final pairType in uniqueTypes) {
      // 复制列表并移除一对
      final remaining = List<Tile>.from(pureTiles);
      int removed = 0;
      for (int i = remaining.length - 1; i >= 0; i--) {
        if (remaining[i].type == pairType && removed < 2) {
          remaining.removeAt(i);
          removed++;
        }
      }
      
      if (removed == 2 && _canFormMeld(remaining)) {
        return true;
      }
    }
    
    return false;
  }
  
  /// 判定剩余牌能否组成4组面子（顺子或刻子）
  static bool _canFormMeld(List<Tile> tiles) {
    if (tiles.isEmpty) return true;
    if (tiles.length % 3 != 0) return false;
    
    final first = tiles.first;
    
    // 尝试作为刻子（3张相同牌）
    if (_countTile(tiles, first.type) >= 3) {
      final remaining = List<Tile>.from(tiles);
      for (int i = 0; i < 3; i++) {
        remaining.removeWhere((t) => t.type == first.type);
      }
      if (_canFormMeld(remaining)) return true;
    }
    
    // 尝试作为顺子
    if (first.isXuPai) {
      final n = first.number;
      // 需要 n, n+1, n+2 都存在
      final hasN1 = tiles.any((t) => t.type == first.type);
      final hasN2 = tiles.any((t) => t.suit == first.suit && t.number == n + 1);
      final hasN3 = tiles.any((t) => t.suit == first.suit && t.number == n + 2);
      
      if (hasN1 && hasN2 && hasN3) {
        final remaining = List<Tile>.from(tiles);
        // 按顺序移除
        remaining.removeWhere((t) => t.type == first.type);
        remaining.removeWhere((t) => t.suit == first.suit && t.number == n + 1);
        remaining.removeWhere((t) => t.suit == first.suit && t.number == n + 2);
        if (_canFormMeld(remaining)) return true;
      }
    }
    
    return false;
  }
  
  /// 统计指定牌型的数量
  static int _countTile(List<Tile> tiles, TileType type) {
    return tiles.where((t) => t.type == type).length;
  }
  
  /// 判定是否听牌（只差一张胡牌）
  static bool isTenpai(List<Tile> tiles) {
    if (tiles.isEmpty) return false;
    
    final pureTiles = tiles.where((t) => !t.isHua).toList();
    if (pureTiles.length % 3 != 1) return false;
    
    // 尝试每张牌作为进张，看是否能胡牌
    // 获取所有可能进张的牌
    final possibleDraws = _getPossibleDraws(pureTiles);
    
    for (final draw in possibleDraws) {
      final testTiles = [...pureTiles, draw];
      if (canHu(testTiles)) {
        return true;
      }
    }
    
    return false;
  }
  
  /// 获取所有可能的进张牌
  static List<Tile> _getPossibleDraws(List<Tile> hand) {
    final possible = <Tile>{};
    
    // 统计现有牌
    final counts = <TileType, int>{};
    for (final tile in hand) {
      counts[tile.type] = (counts[tile.type] ?? 0) + 1;
    }
    
    // 筒子万子条子：每种牌可能进张
    for (final suit in [TileSuit.wan, TileSuit.tong, TileSuit.tiao]) {
      for (int n = 1; n <= 9; n++) {
        final type = _getTileType(suit, n);
        // 如果已有3张，则不能再摸
        if ((counts[type] ?? 0) < 4) {
          possible.add(Tile(type: type, id: 0));
        }
      }
    }
    
    // 字牌
    for (final type in TileType.values) {
      if ((counts[type] ?? 0) < 4) {
        possible.add(Tile(type: type, id: 0));
      }
    }
    
    return possible.toList();
  }
  
  /// 根据花色和数字获取牌型
  static TileType _getTileType(TileSuit suit, int number) {
    switch (suit) {
      case TileSuit.wan:
        return TileType.values[number - 1];
      case TileSuit.tong:
        return TileType.values[9 + number - 1];
      case TileSuit.tiao:
        return TileType.values[18 + number - 1];
      default:
        return TileType.wan1;
    }
  }
}
