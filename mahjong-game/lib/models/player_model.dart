import 'dart:math';
import '../models/tile_model.dart';

/// 玩家位置
enum PlayerPosition {
  self,     // 0: 自己/东家
  right,    // 1: 下家/南家
  opposite, // 2: 对家/西家
  left,     // 3: 上家/北家
}

/// 玩家动作类型
enum PlayerAction {
  draw,      // 摸牌
  play,      // 打牌
  chow,      // 吃
  pong,      // 碰
  kong,      // 杠
  hu,        // 胡
  skip,      // 不动作
}

/// 杠牌类型
enum KongType {
  exposedKong,  // 明杠/加杠 (碰牌后补杠)
  hiddenKong,  // 暗杠
  flowerKong,  // 杠花
}

/// 胡牌牌型
enum HuType {
  /// 垃圾胡 - 基础胡牌
  basic,
  /// 碰碰胡 - 全部是刻子/杠（无顺子）
  pongPongHu,
  /// 清混碰 - 一种花色 + 混子
  qingHanPon,
  /// 清一色 - 同一种花色（万/筒/条之一）
  qingYiSe,
  /// 混一色 - 一种花色 + 风牌（对子或刻子）
  hunYiSe,
  /// 清碰 - 清一色 + 碰碰胡
  qingPon,
  /// 风一色 - 全部是风牌（东南西北）
  fengYiSe,
  /// 风碰 - 碰碰胡 + 全部风牌（对子或刻子）
  fengPon,
  /// 十三幺
  shiSanYao,
  /// 对对胡 - 只有刻子、对子、杠牌，以及花牌
  duiDuiHu,
}

/// 游戏状态
enum GameState {
  waiting,    // 等待开始
  dealing,    // 发牌中
  playing,    // 游戏中
  huing,      // 胡牌结算
  ended,      // 游戏结束
}

/// 玩家
class Player {
  final int id;
  final String name;
  final PlayerPosition position;

  List<Tile> handTiles = [];        // 手牌
  List<Tile> playedTiles = [];      // 打出的牌（牌池）
  List<List<Tile>> exposedMelds = []; // 吃/碰/明杠的牌组
  List<List<Tile>> concealedMelds = []; // 暗杠的牌组
  List<Tile> flowerTiles = [];       // 花牌

  int totalScore = 0;  // 累计分数

  Player({
    required this.id,
    required this.name,
    required this.position,
  });

  /// 手牌数量
  int get handCount => handTiles.length;

  /// 门口牌数量（吃碰杠 + 花牌）
  int get meldCount => exposedMelds.length + concealedMelds.length + flowerTiles.length;

  /// 是否有花牌
  bool get hasFlowers => flowerTiles.isNotEmpty;

  /// 获取所有门口牌
  List<List<Tile>> get allMelds => [...exposedMelds, ...concealedMelds];

  /// 检查是否有风向刻子或风向杠
  bool get hasFengKeOrGang {
    for (var meld in exposedMelds) {
      if (meld.length == 3 && meld.first.isFeng) return true;
    }
    for (var meld in concealedMelds) {
      if (meld.first.isFeng) return true;
    }
    return false;
  }

  /// 是否无花（门口牌和手牌均无花牌）
  bool get isNoFlower => flowerTiles.isEmpty && !handTiles.any((t) => t.isHua);

  /// 是否门清（满足听牌条件时，没有吃或碰，门口无牌）
  /// 可以有暗杠和杠花
  bool get isMenQing {
    // 门口无牌 = 没有吃/碰/明杠的牌组
    // 暗杠(concealedMelds)和花牌(flowerTiles)不影响门清
    return exposedMelds.isEmpty;
  }

  /// 是否听牌（只差一张即可胡牌）
  bool get isTenpai {
    // 手牌必须符合胡牌的基本结构（14张或13张+1张）
    final tileCount = handTiles.where((t) => !t.isHua).length;
    if (tileCount < 13) return false;
    
    // 简单判断：去除一张牌后能否胡牌
    // 这里需要调用游戏逻辑来判断，暂时返回false
    return false;
  }

  /// 是否有五毒散牌型（造反牌型）
  /// 条件：筒子、万子、条子、风牌、箭牌五门都有，无花牌，无百搭，无对子
  bool isWuDuSan({Tile? wildTile}) {
    final hand = handTiles.where((t) => !t.isHua).toList();
    
    // 去掉百搭
    final filtered = wildTile != null 
        ? hand.where((t) => t.type != wildTile.type).toList()
        : hand;
    
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
    
    // 无花牌（已在前面过滤）
    // 无百搭（已在前面过滤）
    
    // 无对子或刻子（全是搭子/散牌）
    // 检查是否有对子
    final counts = <TileType, int>{};
    for (final tile in filtered) {
      counts[tile.type] = (counts[tile.type] ?? 0) + 1;
    }
    
    // 如果有2张相同的牌（对子或刻子），则不是五毒散
    for (final count in counts.values) {
      if (count >= 2) return false;
    }
    
    return true;
  }

  /// 整理手牌（排序）
  void sortHand() {
    handTiles.sort((a, b) {
      // 先按花色排序，再按数字排序
      final suitOrder = a.suit.index.compareTo(b.suit.index);
      if (suitOrder != 0) return suitOrder;
      return a.number.compareTo(b.number);
    });
  }

  /// 添加手牌
  void addTile(Tile tile) {
    handTiles.add(tile);
    sortHand();
  }

  /// 移除手牌
  void removeTile(Tile tile) {
    handTiles.remove(tile);
  }

  /// 摸花后补牌
  void drawFlowerTile(Tile tile) {
    flowerTiles.add(tile);
  }

  @override
  String toString() => name;
}
