import '../models/tile_model.dart';
import 'tile_type_detector.dart';

class HuJudge {
  static bool canHu(List<Tile> tiles) {
    if (tiles.length % 3 != 2 || tiles.isEmpty) return false;
    if (TileTypeDetector.isShiSanYao(tiles)) return true;

    // 七对
    if (_isQiDui(tiles)) return true;

    return _isStandardWinningHand(tiles);
  }

  static bool _isQiDui(List<Tile> tiles) {
    if (tiles.length != 14) return false;
    final counts = <TileType, int>{};
    for (final t in tiles) {
      counts[t.type] = (counts[t.type] ?? 0) + 1;
    }
    return counts.values.every((c) => c == 2);
  }

  static bool _isStandardWinningHand(List<Tile> tiles) {
    final counts = <TileType, int>{};
    for (final t in tiles) {
      counts[t.type] = (counts[t.type] ?? 0) + 1;
    }

    // 尝试每个对子作为将
    for (final entry in counts.entries) {
      if (entry.value >= 2) {
        final newCounts = Map<TileType, int>.from(counts);
        newCounts[entry.key] = entry.value - 2;
        if (_canFormMelds(newCounts)) return true;
      }
    }
    return false;
  }

  static bool _canFormMelds(Map<TileType, int> counts) {
    // 找到还有牌的最小type
    TileType? first;
    for (final t in TileType.values) {
      if ((counts[t] ?? 0) > 0) {
        first = t;
        break;
      }
    }
    if (first == null) return true;

    // 优先刻子
    if ((counts[first] ?? 0) >= 3) {
      counts[first] = (counts[first] ?? 0) - 3;
      if (_canFormMelds(counts)) return true;
      counts[first] = (counts[first] ?? 0) + 3;
    }

    // 顺子（只对万/筒/条）
    final suit = _getSuit(first);
    final number = _getNumber(first);
    if (suit != null && number != null && number <= 7) {
      final t2 = _getType(suit, number + 1);
      final t3 = _getType(suit, number + 2);
      if (t2 != null && t3 != null && (counts[t2] ?? 0) > 0 && (counts[t3] ?? 0) > 0) {
        counts[first] = (counts[first] ?? 0) - 1;
        counts[t2] = (counts[t2] ?? 0) - 1;
        counts[t3] = (counts[t3] ?? 0) - 1;
        if (_canFormMelds(counts)) return true;
        counts[first] = (counts[first] ?? 0) + 1;
        counts[t2] = (counts[t2] ?? 0) + 1;
        counts[t3] = (counts[t3] ?? 0) + 1;
      }
    }

    return false;
  }

  static TileSuit? _getSuit(TileType type) {
    final idx = type.index;
    if (idx >= 0 && idx <= 8) return TileSuit.wan;
    if (idx >= 9 && idx <= 17) return TileSuit.tong;
    if (idx >= 18 && idx <= 26) return TileSuit.tiao;
    return null;
  }

  static int? _getNumber(TileType type) {
    final idx = type.index;
    if (idx >= 0 && idx <= 8) return idx - 0 + 1;
    if (idx >= 9 && idx <= 17) return idx - 9 + 1;
    if (idx >= 18 && idx <= 26) return idx - 18 + 1;
    return null;
  }

  static TileType? _getType(TileSuit suit, int number) {
    if (number < 1 || number > 9) return null;
    switch (suit) {
      case TileSuit.wan:
        return TileType.values[number - 1];
      case TileSuit.tong:
        return TileType.values[9 + number - 1];
      case TileSuit.tiao:
        return TileType.values[18 + number - 1];
      default:
        return null;
    }
  }
}
