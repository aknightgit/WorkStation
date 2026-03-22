import 'mahjong_game.dart';

// 胡牌检测与点数计算
class HuJudge {
  // 检测是否胡牌
  static bool checkHu(List<Tile> tiles, {Tile? lastTile}) {
    var hand = List<Tile>.from(tiles);
    if (lastTile != null) {
      hand.add(lastTile);
    }
    
    // 必须是2,5,8,11,14张
    if (hand.length % 3 != 2) return false;
    if (hand.length < 2 || hand.length > 14) return false;
    
    // 排序
    hand.sort((a, b) {
      final suitComp = a.suit.index.compareTo(b.suit.index);
      if (suitComp != 0) return suitComp;
      return a.number.compareTo(b.number);
    });
    
    // 检测有对子
    final pairs = _findPairs(hand);
    for (final pair in pairs) {
      final remain = _removeTiles(hand, [pair]);
      if (_checkMelds(remain)) return true;
    }
    
    // 七对子
    if (_checkSevenPairs(hand)) return true;
    
    // 十三幺
    if (_checkThirteenOrphans(hand)) return true;
    
    return false;
  }
  
  // 找所有可能的對子
  static List<Tile> _findPairs(List<Tile> hand) {
    final counts = <int, int>{};
    for (final t in hand) {
      counts[t.id] = (counts[t.id] ?? 0) + 1;
    }
    return hand.where((t) => counts[t.id]! >= 2).toList();
  }
  
  // 移除指定牌
  static List<Tile> _removeTiles(List<Tile> hand, List<Tile> toRemove) {
    final result = List<Tile>.from(hand);
    for (final t in toRemove) {
      final idx = result.indexWhere((x) => x.id == t.id);
      if (idx >= 0) result.removeAt(idx);
    }
    return result;
  }
  
  // 检测是否能组成顺子或刻子
  static bool _checkMelds(List<Tile> tiles) {
    if (tiles.isEmpty) return true;
    
    final first = tiles.first;
    
    // 尝试组成刻子 (AAA)
    final trips = tiles.where((t) => t.type == first.type && t.number == first.number).toList();
    if (trips.length >= 3) {
      final remain = _removeTiles(tiles, trips.sublist(0, 3));
      if (_checkMelds(remain)) return true;
    }
    
    // 尝试组成顺子 (ABC)
    if (first.suit != TileSuit.hua) {
      for (int n = 1; n <= 7; n++) {
        final a = Tile(id: -1, type: first.type, number: n, suit: first.suit);
        final b = Tile(id: -1, type: first.type, number: n + 1, suit: first.suit);
        final c = Tile(id: -1, type: first.type, number: n + 2, suit: first.suit);
        
        if (_hasTiles(tiles, [b, c])) {
          final remain = _removeTiles(tiles, [a, b, c]);
          if (_checkMelds(remain)) return true;
        }
      }
    }
    
    return false;
  }
  
  static bool _hasTiles(List<Tile> tiles, List<Tile> need) {
    final remaining = List<Tile>.from(tiles);
    for (final n in need) {
      final idx = remaining.indexWhere((t) => t.type == n.type && t.number == n.number);
      if (idx < 0) return false;
      remaining.removeAt(idx);
    }
    return true;
  }
  
  // 七对子检测
  static bool _checkSevenPairs(List<Tile> hand) {
    if (hand.length != 14) return false;
    
    final counts = <int, int>{};
    for (final t in hand) {
      counts[t.id] = (counts[t.id] ?? 0) + 1;
    }
    return counts.values.every((c) => c == 2);
  }
  
  // 十三幺检测
  static bool _checkThirteenOrphans(List<Tile> hand) {
    if (hand.length != 14) return false;
    return false; // TODO: 完善十三幺检测
  }
}

// 点数计算器
class ScoreCalculator {
  // 计算胡牌点数
  static int calculateScore({
    required List<Tile> hand,
    required List<Tile> melds,
    required List<Tile> flowerTiles,
    required bool isZimo,
    required bool isGangKai,
    required bool isMenQing,
    required bool hasWild,
  }) {
    // 1. 固定点数牌型（优先级最高）
    if (isQingYiSe(hand, melds)) return 10;
    if (isFengYiSe(hand, melds)) return 20;
    if (isFengPeng(hand, melds)) return 40;
    if (isNoFlowerZiMo(hand, melds, flowerTiles, isZimo)) return 10;
    if (isGangKai) return 10;
    
    // 2. 公式计算
    int base = 2;
    base += flowerTiles.length; // 花牌数
    base += _calculateMeldPoints(melds); // 组合牌点数
    
    // 3. 额外翻倍
    double multiplier = 1.0;
    if (!hasWild) multiplier *= 2; // 无百搭 ×2
    if (isMenQing) multiplier *= 2; // 门清 ×2
    
    return (base * multiplier).round();
  }
  
  // 计算组合牌点数
  static int _calculateMeldPoints(List<Tile> melds) {
    int points = 0;
    for (final meld in melds) {
      if (meld.type == TileType.wind) {
        points += 1; // 风牌刻子
      } else if (meld.type == TileType.dragon) {
        points += 2; // 箭牌刻子
      }
    }
    return points;
  }
  
  // 清一色检测
  static bool isQingYiSe(List<Tile> hand, List<Tile> melds) {
    final suits = <TileSuit>{};
    for (final t in hand) {
      if (t.suit != TileSuit.hua) suits.add(t.suit);
    }
    for (final t in melds) {
      if (t.suit != TileSuit.hua) suits.add(t.suit);
    }
    return suits.length == 1 && suits.contains(TileSuit.wan);
  }
  
  // 风一色检测
  static bool isFengYiSe(List<Tile> hand, List<Tile> melds) {
    for (final t in hand) {
      if (t.type != TileType.wind && t.suit != TileSuit.hua) return false;
    }
    for (final t in melds) {
      if (t.type != TileType.wind) return false;
    }
    return hand.any((t) => t.type == TileType.wind);
  }
  
  // 风碰检测
  static bool isFengPeng(List<Tile> hand, List<Tile> melds) {
    // 全部是风牌，且有刻子/杠
    for (final t in hand) {
      if (t.type != TileType.wind && t.suit != TileSuit.hua) return false;
    }
    // 有刻子或杠
    return melds.length >= 1;
  }
  
  // 无花自摸检测
  static bool isNoFlowerZiMo(List<Tile> hand, List<Tile> melds, List<Tile> flowerTiles, bool isZimo) {
    if (!isZimo) return false;
    if (flowerTiles.isNotEmpty) return false;
    
    // 无风向刻/杠
    for (final t in melds) {
      if (t.type == TileType.wind) return false;
    }
    return true;
  }
}
