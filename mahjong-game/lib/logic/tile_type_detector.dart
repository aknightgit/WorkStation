import '../models/tile_model.dart';
import '../models/player_model.dart';

/// 牌型检测器 - 负责所有胡牌牌型的检测
class TileTypeDetector {
  /// 检测是否为清一色
  /// 手牌和门口牌只有一种数牌花色（万/筒/条之一）
  static bool isQingYiSe(List<Tile> hand, List<List<Tile>> exposedMelds) {
    TileSuit? suit;
    
    // 检查手牌
    for (final tile in hand) {
      if (tile.isHua) continue; // 忽略花牌
      if (!tile.isXuPai) continue; // 忽略字牌
      if (suit == null) {
        suit = tile.suit;
      } else if (tile.suit != suit) {
        return false; // 有多种数牌花色
      }
    }
    
    // 检查门口牌
    for (final meld in exposedMelds) {
      for (final tile in meld) {
        if (tile.isHua) continue;
        if (!tile.isXuPai) continue;
        if (suit == null) {
          suit = tile.suit;
        } else if (tile.suit != suit) {
          return false;
        }
      }
    }
    
    return suit != null;
  }
  
  /// 检测是否为混一色
  /// 一种数牌 + 风牌（对子或刻子）
  static bool isHunYiSe(List<Tile> hand, List<List<Tile>> exposedMelds) {
    TileSuit? suit;
    bool hasFeng = false;
    
    // 检查手牌
    for (final tile in hand) {
      if (tile.isHua) continue;
      if (tile.isFeng) {
        hasFeng = true;
      } else if (tile.isXuPai) {
        if (suit == null) {
          suit = tile.suit;
        } else if (tile.suit != suit) {
          return false;
        }
      }
    }
    
    // 检查门口牌
    for (final meld in exposedMelds) {
      if (meld.length == 3 && meld.first.isFeng) {
        hasFeng = true;
      }
      for (final tile in meld) {
        if (tile.isHua) continue;
        if (!tile.isFeng && tile.isXuPai) {
          if (suit == null) {
            suit = tile.suit;
          } else if (tile.suit != suit) {
            return false;
          }
        }
      }
    }
    
    return suit != null && hasFeng;
  }
  
  /// 检测是否为风一色（全是风向牌）
  static bool isFengYiSe(List<Tile> hand, List<List<Tile>> exposedMelds) {
    // 检查手牌
    for (final tile in hand) {
      if (tile.isHua) continue;
      if (!tile.isFeng) return false;
    }
    
    // 检查门口牌
    for (final meld in exposedMelds) {
      for (final tile in meld) {
        if (tile.isHua) continue;
        if (!tile.isFeng) return false;
      }
    }
    
    return true;
  }
  
  /// 检测是否为风碰（风一色 + 全部是对子或刻子）
  static bool isFengPon(List<Tile> hand, List<List<Tile>> exposedMelds) {
    if (!isFengYiSe(hand, exposedMelds)) return false;
    
    // 门口牌必须全是对子或刻子
    for (final meld in exposedMelds) {
      if (meld.length == 3) {
        if (!meld.first.isFeng) return false;
      }
    }
    
    // 手牌必须全是对子或刻子（无顺子）
    return isPongPongHu(hand);
  }
  
  /// 检测是否为对对胡（只有刻子、对子、杠牌）
  static bool isDuiDuiHu(List<Tile> hand, List<List<Tile>> exposedMelds) {
    // 手牌必须符合碰碰胡结构
    if (!isPongPongHu(hand)) return false;
    
    // 门口牌必须全是对子或刻子或杠
    for (final meld in exposedMelds) {
      if (meld.length != 3 && meld.length != 4) {
        return false;
      }
    }
    
    return true;
  }
  
  /// 检测是否为碰碰胡（全部是刻子/对子，无顺子）
  static bool isPongPongHu(List<Tile> hand) {
    if (hand.isEmpty) return false;
    
    final tiles = List<Tile>.from(hand.where((t) => !t.isHua));
    if (tiles.isEmpty) return true;
    
    // 检查是否有顺子
    return !_hasShunzi(tiles);
  }
  
  /// 检查牌组中是否有顺子
  static bool _hasShunzi(List<Tile> tiles) {
    // 排序
    tiles.sort((a, b) => a.type.index.compareTo(b.type.index));
    
    // 统计每种牌的数量
    final counts = <TileType, int>{};
    for (final tile in tiles) {
      counts[tile.type] = (counts[tile.type] ?? 0) + 1;
    }
    
    // 检查是否能组成顺子
    // 按花色分组检查
    final suits = <TileSuit>{};
    for (final tile in tiles) {
      suits.add(tile.suit);
    }
    
    for (final suit in suits) {
      final suitTiles = tiles.where((t) => t.suit == suit).toList();
      suitTiles.sort((a, b) => a.number.compareTo(b.number));
      
      // 检查是否有连续的牌可以组成顺子
      for (int i = 0; i < suitTiles.length - 2; i++) {
        final n = suitTiles[i].number;
        if (suitTiles[i + 1].number == n + 1 && suitTiles[i + 2].number == n + 2) {
          return true; // 存在顺子
        }
      }
    }
    
    return false;
  }
  
  /// 检测是否为十三幺
  static bool isShiSanYao(List<Tile> tiles) {
    if (tiles.length != 14) return false;
    
    final required = <TileType>{
      TileType.wan1,
      TileType.wan9,
      TileType.tong1,
      TileType.tong9,
      TileType.tiao1,
      TileType.tiao9,
      TileType.dong,
      TileType.nan,
      TileType.xi,
      TileType.bei,
      TileType.zhong,
      TileType.fa,
      TileType.bai,
    };
    
    final counts = <TileType, int>{};
    for (final tile in tiles) {
      counts[tile.type] = (counts[tile.type] ?? 0) + 1;
    }
    
    for (final type in required) {
      if ((counts[type] ?? 0) == 0) return false;
    }
    
    return counts.entries.any((entry) => required.contains(entry.key) && entry.value >= 2);
  }
  
  /// 检测是否为五毒散（造反牌型）
  /// 筒子、万子、条子、风牌、箭牌五门都有，无花牌，无百搭，无对子
  static bool isWuDuSan(List<Tile> hand, {Tile? wildTile}) {
    final filtered = hand.where((t) => !t.isHua).toList();
    if (wildTile != null) {
      filtered.removeWhere((t) => t.type == wildTile.type);
    }
    
    if (filtered.isEmpty) return false;
    
    bool hasWan = false;
    bool hasTong = false;
    bool hasTiao = false;
    bool hasFeng = false;
    bool hasJian = false;
    
    for (final tile in filtered) {
      if (tile.suit == TileSuit.wan) hasWan = true;
      if (tile.suit == TileSuit.tong) hasTong = true;
      if (tile.suit == TileSuit.tiao) hasTiao = true;
      if (tile.isFeng) hasFeng = true;
      if (tile.isJian) hasJian = true;
    }
    
    // 五门都有
    if (!hasWan || !hasTong || !hasTiao || !hasFeng || !hasJian) return false;
    
    // 无对子
    final counts = <TileType, int>{};
    for (final tile in filtered) {
      counts[tile.type] = (counts[tile.type] ?? 0) + 1;
    }
    
    for (final count in counts.values) {
      if (count >= 2) return false;
    }
    
    return true;
  }
  
  /// 获取最佳牌型
  static HuType getBestHuType(List<Tile> hand, List<List<Tile>> exposedMelds, {Tile? newTile}) {
    final tiles = newTile != null ? [...hand, newTile] : hand;
    
    if (isShiSanYao(tiles)) return HuType.shiSanYao;
    if (isFengPon(tiles, exposedMelds)) return HuType.fengPon;
    if (isFengYiSe(tiles, exposedMelds)) return HuType.fengYiSe;
    if (isQingYiSe(tiles, exposedMelds) && isPongPongHu(tiles)) return HuType.qingPon;
    if (isQingYiSe(tiles, exposedMelds)) return HuType.qingYiSe;
    if (isHunYiSe(tiles, exposedMelds)) return HuType.hunYiSe;
    if (isDuiDuiHu(tiles, exposedMelds)) return HuType.duiDuiHu;
    if (isPongPongHu(tiles)) return HuType.pongPongHu;
    
    return HuType.basic;
  }
}
