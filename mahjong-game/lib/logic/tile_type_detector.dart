import '../models/tile_model.dart';

class TileTypeDetector {
  // 清一色：所有牌都是同一数牌花色（万/筒/条）
  static bool isQingYiSe(List<Tile> hand, List<List<Tile>> melds) {
    final allTiles = [...hand, ...melds.expand((m) => m)];
    if (allTiles.isEmpty) return false;

    // 只允许数牌
    if (allTiles.any((t) => !t.isXuPai)) return false;

    final suit = allTiles.first.suit;
    return allTiles.every((t) => t.suit == suit);
  }

  // 风一色：全部为风牌
  static bool isFengYiSe(List<Tile> hand, List<List<Tile>> melds) {
    final allTiles = [...hand, ...melds.expand((m) => m)];
    if (allTiles.isEmpty) return false;
    return allTiles.every((t) => t.suit == TileSuit.feng);
  }

  // 五毒散：五门都有（万/筒/条/风/箭），且无对子
  static bool isWuDuSan(List<Tile> hand) {
    if (hand.length < 5) return false;
    final suitSet = <TileSuit>{};
    final typeSet = <TileType>{};
    for (final t in hand) {
      suitSet.add(t.suit);
      if (typeSet.contains(t.type)) return false; // 有对子
      typeSet.add(t.type);
    }
    return suitSet.containsAll({TileSuit.wan, TileSuit.tong, TileSuit.tiao, TileSuit.feng, TileSuit.jian});
  }

  // 十三幺
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
    for (final t in tiles) {
      counts[t.type] = (counts[t.type] ?? 0) + 1;
    }

    // 必须包含全部13种
    for (final r in required) {
      if (!counts.containsKey(r)) return false;
    }

    // 恰好有一对
    final pairCount = counts.values.where((c) => c == 2).length;
    return pairCount == 1;
  }

  // 对对胡（可选）
  static bool isPongPongHu(List<Tile> tiles) {
    final counts = <TileType, int>{};
    for (final t in tiles) {
      counts[t.type] = (counts[t.type] ?? 0) + 1;
    }
    int pairCount = 0;
    for (final c in counts.values) {
      if (c == 2) pairCount++;
      else if (c != 3 && c != 4) return false;
    }
    return pairCount == 1;
  }
}
