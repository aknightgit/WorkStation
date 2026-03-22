import 'mahjong_game.dart';
// 完整胡牌检测算法
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
    // 返回所有有2张以上的牌
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
    
    // 取第一张牌
    final first = tiles.first;
    
    // 尝试组成刻子 (AAA)
    final trips = tiles.where((t) => t.type == first.type && t.number == first.number).toList();
    if (trips.length >= 3) {
      final remain = _removeTiles(tiles, trips.sublist(0, 3));
      if (_checkMelds(remain)) return true;
    }
    
    // 尝试组成顺子 (ABC)
    if (first.suit != TileSuit.hua) {
      final a = Tile(id: -1, type: first.type, number: first.number, suit: first.suit);
      final b = Tile(id: -1, type: first.type, number: first.number + 1, suit: first.suit);
      final c = Tile(id: -1, type: first.type, number: first.number + 2, suit: first.suit);
      
      if (_hasTiles(tiles, [b, c])) {
        final remain = _removeTiles(tiles, [a, b, c]);
        if (_checkMelds(remain)) return true;
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
    
    // 必须是 1,9 万/筒/条 + 东南西北中发白
    final orphans = {1, 9};
    final honors = {1, 2, 3}; // 东南西北
    
    int pairCount = 0;
    final seen = <int>{};
    
    for (final t in hand) {
      if (t.suit == TileSuit.hua) {
        if (t.type == TileType.wind && honors.contains(t.number)) {
          seen.add(t.number);
        } else if (t.type == TileType.dragon) {
          seen.add(10 + t.number);
        }
      } else {
        if (orphans.contains(t.number)) {
          seen.add(t.suit.index * 10 + t.number);
        }
      }
    }
    
    // 必须有13种不同牌 + 1张重复
    return seen.length == 13 && hand.length == 14;
  }
}

// 点数计算
class ScoreCalculator {
  // 计算胡牌番数
  static int calculateFan(List<Tile> hand, Map<String, bool> info) {
    int fan = 0;
    
    // 基础番
    if (info['menqing'] == true) fan += 1; // 门清
    if (info['zimo'] == true) fan += 1; // 自摸
    if (info['qianggang'] == true) fan += 1; // 抢杠
    if (info['haidi'] == true) fan += 1; // 海底
    
    // 牌型番
    if (info['qidui'] == true) fan += 8; // 七对
    if (info['qys'] == true) fan += 12; // 十三幺
    if (info['ssg'] == true) fan += 8; // 三同刻
    if (info['xxg'] == true) fan += 4; // 小四喜
    if (info['dsg'] == true) fan += 16; // 大四喜
    
    // 混一色 / 清一色
    if (info['qys'] == true) fan += 24;
    else if (info['hys'] == true) fan += 6;
    
    return fan.clamp(1, 256);
  }
  
  // 计算最终点数
  static int calculateScore(int base, int fan, int multiplier) {
    // 基础分 * 2^(番数-1) * 全局倍数
    int score = base;
    for (int i = 1; i < fan; i++) {
      score *= 2;
    }
    return score * multiplier;
  }
}
