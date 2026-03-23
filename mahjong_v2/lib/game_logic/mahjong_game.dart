import 'dart:math';
// 牌定义
class Tile {
  final int id;
  final TileType type;
  final int number;
  final TileSuit suit;
  final bool isFlower;
  final bool isWild;

  Tile({required this.id, required this.type, required this.number, required this.suit, this.isFlower = false, this.isWild = false});

  // 素材路径
  String get imagePath {
    // 花牌统一用背面（避免缺素材）
    if (isFlower || suit == TileSuit.hua) {
      return 'assets/images/tiles/Regular/Back.png';
    }
    
    // 根据suit和number返回对应素材
    String prefix = '';
    if (suit == TileSuit.wan) prefix = 'Man';
    else if (suit == TileSuit.tong) prefix = 'Pin';
    else if (suit == TileSuit.tiao) prefix = 'Sou';
    else if (suit == TileSuit.feng) {
      if (number == 1) return 'assets/images/tiles/Regular/Ton.png';
      if (number == 2) return 'assets/images/tiles/Regular/Nan.png';
      if (number == 3) return 'assets/images/tiles/Regular/Shaa.png';
      if (number == 4) return 'assets/images/tiles/Regular/Pei.png';
    }
    else if (suit == TileSuit.dragon) {
      if (number == 1) return 'assets/images/tiles/Regular/Haku.png';
      if (number == 2) return 'assets/images/tiles/Regular/Hatsu.png';
      if (number == 3) return 'assets/images/tiles/Regular/Chun.png';
    }
    
    if (prefix.isEmpty) return 'assets/images/tiles/Regular/Blank.png';
    return 'assets/images/tiles/Regular/${prefix}$number.png';
  }

  String get displayName {
    if (suit == TileSuit.hua) return '花';
    final nums = ['一','二','三','四','五','六','七','八','九'];
    final suits = ['万','筒','条','风','中','发','白'];
    if (number >=1 && number <=9 && type.index < 3) {
      return '${nums[number-1]}${suits[type.index]}';
    }
    return suits[3 + (number > 4 ? number - 1 : number - 1)];
  }
}

enum TileType { wan, tong, tiao, wind, dragon, flower, blank }
enum TileSuit { wan, tong, tiao, feng, dragon, hua }

// 玩家
class Player {
  final int index;
  String name;
  List<Tile> handTiles = [];
  List<List<Tile>> melds = []; // 吃/碰/杠牌组
  List<Tile> flowerTiles = [];
  List<Tile> playedTiles = [];
  int score = 0;
  bool isDealer = false;
  int totalScore = 0;

  Player({required this.index, required this.name});

  int get handCount => handTiles.length;
  int get meldCount => melds.length;

  // 是否满足五毒散（造反牌型）
  bool get isWuDuSan {
    final hand = handTiles.where((t) => !t.isFlower && !t.isWild).toList();
    if (hand.length < 13) return false;
    
    bool hasWan = hand.any((t) => t.suit == TileSuit.wan);
    bool hasTong = hand.any((t) => t.suit == TileSuit.tong);
    bool hasTiao = hand.any((t) => t.suit == TileSuit.tiao);
    bool hasWind = hand.any((t) => t.type == TileType.wind);
    bool hasDragon = hand.any((t) => t.type == TileType.dragon);
    bool hasFlower = hand.any((t) => t.suit == TileSuit.hua);
    bool hasWild = hand.any((t) => t.isWild);
    
    if (!hasWan || !hasTong || !hasTiao || !hasWind || !hasDragon || hasFlower || hasWild) return false;
    
    // 检查是否有对子或刻子
    final counts = <TileType, int>{};
    for (final t in hand) {
      counts[t.type] = (counts[t.type] ?? 0) + 1;
    }
    for (final c in counts.values) {
      if (c >= 2) return false;
    }
    return true;
  }

  void sortHand() {
    handTiles.sort((a, b) {
      final suitOrder = a.suit.index.compareTo(b.suit.index);
      if (suitOrder != 0) return suitOrder;
      return a.number.compareTo(b.number);
    });
  }
}

// 牌组类型
enum MeldType { chow, pong, kong }

// 游戏状态
enum GamePhase { waiting, diceRolling, dealing, playing, scoring }

// 结算结果
class SettlementResult {
  final bool isDraw;
  final int? winnerIndex;
  final int basePoints;
  final int roundMultiplier;
  final int extraMultiplier;
  final int totalPoints;
  final Map<int, int> deltas; // 每个玩家的输赢
  final String reason;

  SettlementResult({
    required this.isDraw,
    required this.winnerIndex,
    required this.basePoints,
    required this.roundMultiplier,
    required this.extraMultiplier,
    required this.totalPoints,
    required this.deltas,
    required this.reason,
  });
}

class FixedScore {
  final int points;
  final String reason;
  FixedScore(this.points, this.reason);
}

// 游戏逻辑核心
class MahjongGame {
  List<Tile> wall = []; // 牌墙
  List<Tile> deadWall = [];
  List<Player> players = [];
  int currentPlayerIndex = 0;
  int dealerIndex = 0;
  int roundMultiplier = 1;
  int globalMultiplier = 1;
  int get finalMultiplier => (roundMultiplier * globalMultiplier).clamp(1, 8);
  Tile? wildTile;
  bool diceRolled = false;
  List<int> diceValues = [1, 1];
  GamePhase phase = GamePhase.waiting;
  Tile? lastPlayedTile;
  Tile? pendingTile; // 等待响应的牌
  bool gameEnded = false;
  bool mustDiscard = false; // 当前玩家是否必须打牌
  bool awaitingPlayerResponse = false; // 等待玩家响应（吃碰杠胡/过）
  int? lastDiscarderIndex;
  SettlementResult? lastSettlement;
  
  // 包关系: baoRelations[fromPlayer][toPlayer] = count
  // 表示 fromPlayer 吃了/碰了 toPlayer 多少口
  Map<int, Map<int, int>> baoRelations = {};
  
  // 血战到底：记录已胡牌的玩家
  List<int> eliminatedPlayers = [];
  // 当前剩余玩家数
  int get activePlayerCount => 4 - eliminatedPlayers.length;

  MahjongGame() {
    players = [
      Player(index: 0, name: '东家'),
      Player(index: 1, name: '南家'),
      Player(index: 2, name: '西家'),
      Player(index: 3, name: '北家'),
    ];
    initWall();
  }

  // 初始化牌墙
  void initWall() {
    wall.clear();
    int id = 0;
    // 万子 1-9 x4
    for (int n = 1; n <= 9; n++) {
      for (int i = 0; i < 4; i++) {
        wall.add(Tile(id: id++, type: TileType.wan, number: n, suit: TileSuit.wan));
      }
    }
    // 筒子 1-9 x4
    for (int n = 1; n <= 9; n++) {
      for (int i = 0; i < 4; i++) {
        wall.add(Tile(id: id++, type: TileType.tong, number: n, suit: TileSuit.tong));
      }
    }
    // 条子 1-9 x4
    for (int n = 1; n <= 9; n++) {
      for (int i = 0; i < 4; i++) {
        wall.add(Tile(id: id++, type: TileType.tiao, number: n, suit: TileSuit.tiao));
      }
    }
    // 风牌 东南西北 x4
    for (int n = 1; n <= 4; n++) {
      for (int i = 0; i < 4; i++) {
        wall.add(Tile(id: id++, type: TileType.wind, number: n, suit: TileSuit.feng));
      }
    }
    // 箭牌 中发白 x4
    for (int n = 1; n <= 3; n++) {
      for (int i = 0; i < 4; i++) {
        wall.add(Tile(id: id++, type: TileType.dragon, number: n, suit: TileSuit.dragon));
      }
    }
    // 花牌 春夏秋冬梅兰菊竹 x8
    for (int n = 1; n <= 8; n++) {
      wall.add(Tile(id: id++, type: TileType.flower, number: n, suit: TileSuit.hua, isFlower: true));
    }
    // 洗牌
    wall.shuffle(Random());
  }

  int get remainingTiles => wall.length;

  // 掷骰子
  void rollDice() {
    diceValues[0] = Random().nextInt(6) + 1;
    diceValues[1] = Random().nextInt(6) + 1;
    diceRolled = true;
    
    // 计算回合倍数（按最新规则）
    final d1 = diceValues[0];
    final d2 = diceValues[1];
    if (d1 == d2) {
      // 对子：11/44 为4倍，其他对子2倍
      roundMultiplier = (d1 == 1 || d1 == 4) ? 4 : 2;
    } else if ((d1 == 1 && d2 == 4) || (d1 == 4 && d2 == 1)) {
      // 1-4 组合两倍
      roundMultiplier = 2;
    } else {
      roundMultiplier = 1;
    }
  }

  // 发牌 - 庄家14张，闲家13张
  void deal() {
    // 清空上一局
    for (final p in players) {
      p.handTiles.clear();
      p.melds.clear();
      p.playedTiles.clear();
      p.flowerTiles.clear();
    }
    // 本局百搭（从144张中随机选一张，不移除）
    if (wall.isNotEmpty) {
      wildTile = wall[Random().nextInt(wall.length)];
    }
    for (int i = 0; i < 3; i++) {
      for (int p = 0; p < 4; p++) {
        final idx = (dealerIndex + p) % 4;
        for (int j = 0; j < 4; j++) {
          if (wall.isNotEmpty) {
            players[idx].handTiles.add(wall.removeLast());
          }
        }
      }
    }
    // 每人再摸1张（13张）
    for (int p = 0; p < 4; p++) {
      final idx = (dealerIndex + p) % 4;
      if (wall.isNotEmpty) {
        players[idx].handTiles.add(wall.removeLast());
      }
    }
    // 庄家额外1张（14张）
    if (wall.isNotEmpty) {
      players[dealerIndex].handTiles.add(wall.removeLast());
    }
    // 整理手牌
    for (final p in players) {
      p.sortHand();
    }
    // 庄家先出牌
    currentPlayerIndex = dealerIndex;
    mustDiscard = currentPlayerIndex == 0;
    phase = GamePhase.playing;
  }

  // 摸牌
  Tile? drawTile(Player player) {
    if (wall.isEmpty) {
      // 流局
      resolveDraw();
      return null;
    }
    // 玩家已摸过牌则不可再次摸牌
    if (player.index == 0 && mustDiscard) return null;

    final tile = wall.removeLast();
    player.handTiles.add(tile);
    if (player.index == 0) {
      mustDiscard = true; // 玩家必须打牌
    }
    return tile;
  }

  // 打牌
  void playTile(Player player, Tile tile) {
    player.handTiles.remove(tile);
    player.playedTiles.add(tile);
    pendingTile = tile;
    lastPlayedTile = tile;
    lastDiscarderIndex = player.index;
    awaitingPlayerResponse = false;
    if (player.index == 0) {
      mustDiscard = false; // 打牌后可进入下一轮
    }
    
    // 检查是否有玩家响应（吃/碰/杠/胡）
    processTurn();
  }

  // 逆时针下一家
  void nextPlayer() {
    currentPlayerIndex = (currentPlayerIndex + 3) % 4;
  }

  // 检查是否可以吃（上家动态）
  bool canChow(Player player) {
    if (pendingTile == null) return false;
    final t = pendingTile!;
    if (_isWildTile(t)) return false; // 百搭牌不可吃碰杠
    // 只能吃上家（逆时针方向）
    // 当前是 playerIndex，上家是 (playerIndex + 1) % 4
    final fromPlayer = (currentPlayerIndex + 1) % 4;
    // 只有当前玩家是下家时才能吃上家的牌
    if (player.index != fromPlayer) return false;
    
    // 只能吃顺子，不能吃字牌
    if (t.suit == TileSuit.hua) return false;
    
    // 找能组成顺子的三张牌
    for (int n = 1; n <= 9; n++) {
      final need1 = Tile(id: -1, type: t.type, number: n, suit: t.suit);
      final need2 = Tile(id: -1, type: t.type, number: n + 1, suit: t.suit);
      final need3 = Tile(id: -1, type: t.type, number: n + 2, suit: t.suit);
      
      if (n + 2 > 9) continue; // 超出范围
      
      if (_playerHasTiles(player, [need1, need2, need3])) {
        return true;
      }
    }
    return false;
  }

  // 获取可以吃的组合
  List<List<Tile>> getChowCombos(Player player) {
    if (pendingTile == null || currentPlayerIndex == 0) return [];
    
    final fromPlayer = (currentPlayerIndex + 1) % 4;
    if (player.index != fromPlayer) return [];
    
    final t = pendingTile!;
    if (t.suit == TileSuit.hua) return [];
    
    final combos = <List<Tile>>[];
    for (int n = 1; n <= 9; n++) {
      if (n + 2 > 9) continue;
      final need1 = Tile(id: -1, type: t.type, number: n, suit: t.suit);
      final need2 = Tile(id: -1, type: t.type, number: n + 1, suit: t.suit);
      final need3 = Tile(id: -1, type: t.type, number: n + 2, suit: t.suit);
      
      if (_playerHasTiles(player, [need1, need2, need3])) {
        // 返回的组合包含 pendingTile 在中间位置
        // 例如吃 5万，手里有 34万/46万 两种组合
        combos.add([need1, need2, need3]);
      }
    }
    return combos;
  }
  
  // 执行吃牌（单组合自动吃）
  bool doChow(Player player, List<Tile>? selectedTiles) {
    if (pendingTile == null) return false;
    final combos = getChowCombos(player);
    if (combos.isEmpty) return false;
    
    List<Tile> combo;
    
    if (combos.length == 1) {
      // 只有一种组合，自动吃
      combo = combos.first;
    } else if (selectedTiles != null && selectedTiles.length == 2) {
      // 多种组合，玩家已选择2张
      // 找到匹配的组合
      combo = combos.firstWhere(
        (c) => _containsTiles(c.sublist(0, 2), selectedTiles),
        orElse: () => combos.first,
      );
    } else {
      // 多种组合但玩家未选择
      return false;
    }
    
    // 移除手牌中的两张牌
    final toRemove = combo.sublist(0, 2);
    for (final t in toRemove) {
      final idx = player.handTiles.indexWhere(
        (x) => x.type == t.type && x.number == t.number,
      );
      if (idx >= 0) {
        player.handTiles.removeAt(idx);
      }
    }
    
    // 添加吃牌组合到 melds（pendingTile 放中间）
    player.melds.add(combo);
    
    // 记录包关系（上家是被吃的一方）
    final fromPlayer = player.index; // 吃牌者
    final toPlayer = (currentPlayerIndex + 1) % 4; // 上家
    recordBao(fromPlayer, toPlayer);
    
    // 吃牌后轮到该玩家出牌
    pendingTile = null;
    currentPlayerIndex = player.index;
    if (player.index == 0) {
      mustDiscard = true;
    }
    return true;
  }
  
  bool _containsTiles(List<Tile> a, List<Tile> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i].type != b[i].type || a[i].number != b[i].number) {
        return false;
      }
    }
    return true;
  }
  
  // 执行碰牌
  bool doPong(Player player) {
    if (pendingTile == null) return false;
    final t = pendingTile!;
    
    // 找到手里的两张相同牌
    final indices = <int>[];
    for (int i = 0; i < player.handTiles.length; i++) {
      if (player.handTiles[i].type == t.type && player.handTiles[i].number == t.number) {
        indices.add(i);
        if (indices.length == 2) break;
      }
    }
    
    if (indices.length < 2) return false;
    
    // 移除两张牌
    for (int i = indices.length - 1; i >= 0; i--) {
      player.handTiles.removeAt(indices[i]);
    }
    
    // 添加刻子到 melds
    player.melds.add([t, t, t]);
    
    // 记录包关系（打牌者是被碰的一方）
    final fromPlayer = player.index; // 碰牌者
    final toPlayer = currentPlayerIndex; // 打牌者
    recordBao(fromPlayer, toPlayer);
    
    // 碰牌后轮到该玩家出牌
    pendingTile = null;
    currentPlayerIndex = player.index;
    if (player.index == 0) {
      mustDiscard = true;
    }
    return true;
  }

  bool _playerHasTiles(Player player, List<Tile> need) {
    final hand = List<Tile>.from(player.handTiles);
    for (final n in need) {
      final idx = hand.indexWhere((t) => t.type == n.type && t.number == n.number);
      if (idx < 0) return false;
      hand.removeAt(idx);
    }
    return true;
  }
  
  // 记录包关系（吃牌/碰牌/杠牌后调用）
  // 三口/四口条件是单向的，但结算时是双向的
  void recordBao(int fromPlayer, int toPlayer) {
    // 记录单向关系
    baoRelations[fromPlayer] ??= {};
    baoRelations[fromPlayer]![toPlayer] = (baoRelations[fromPlayer]![toPlayer] ?? 0) + 1;
    
    // 结算时是双向的，所以也记录反向关系
    baoRelations[toPlayer] ??= {};
    baoRelations[toPlayer]![fromPlayer] = (baoRelations[toPlayer]![fromPlayer] ?? 0) + 1;
  }
  
  // 获取包倍数（0=无, 3=包三家, 5=包四家）
  int getBaoMultiplier(int fromPlayer, int toPlayer) {
    final count = baoRelations[fromPlayer]?[toPlayer] ?? 0;
    if (count >= 4) return 5; // 包四家
    if (count >= 3) return 3; // 包三家
    return 0;
  }
  
  // 检查是否有包关系
  bool hasBaoRelation(int fromPlayer, int toPlayer) {
    return getBaoMultiplier(fromPlayer, toPlayer) > 0;
  }
  
  // 造反成功（算作流局的一种）
  // 下局翻倍 + 换庄
  void resolveRebelAsDraw(int rebelPlayerIndex) {
    // 翻倍（最高8倍）
    globalMultiplier = (globalMultiplier * 2).clamp(1, 8);
    
    // 换庄：造反者成为新庄家
    dealerIndex = rebelPlayerIndex;
    
    // 标记为流局
    _applySettlement(_settleDraw('造反流局'));
  }
  
  // 流局处理：翻倍 + 换庄
  void resolveDraw() {
    // 翻倍（最高8倍）
    globalMultiplier = (globalMultiplier * 2).clamp(1, 8);
    
    // 换庄
    dealerIndex = (dealerIndex + 1) % 4;
    
    // 标记为流局
    _applySettlement(_settleDraw('流局'));
  }

  // ===== 结算模块 =====
  SettlementResult _settleDraw(String reason) {
    final deltas = <int, int>{};
    for (int i = 0; i < 4; i++) {
      deltas[i] = 0;
    }
    return SettlementResult(
      isDraw: true,
      winnerIndex: null,
      basePoints: 0,
      roundMultiplier: finalMultiplier,
      extraMultiplier: 1,
      totalPoints: 0,
      deltas: deltas,
      reason: reason,
    );
  }

  SettlementResult _settleWin(int winnerIndex, {String reason = '胡牌'}) {
    final winner = players[winnerIndex];
    final isSelfDraw = pendingTile == null;
    final fixed = _calcFixedScore(winner, isSelfDraw);
    final basePoints = fixed.points > 0 ? fixed.points : _calcBasePoints(winner);
    final finalReason = fixed.points > 0 ? fixed.reason : reason;
    final extraMultiplier = _calcExtraMultiplier(winner);
    final total = basePoints * finalMultiplier * extraMultiplier;

    final active = <int>[];
    for (int i = 0; i < 4; i++) {
      if (!eliminatedPlayers.contains(i)) active.add(i);
    }
    final payers = active.where((i) => i != winnerIndex).toList();
    final deltas = <int, int>{};
    for (int i = 0; i < 4; i++) {
      deltas[i] = 0;
    }
    deltas[winnerIndex] = total * payers.length;
    for (final p in payers) {
      deltas[p] = -total;
    }

    return SettlementResult(
      isDraw: false,
      winnerIndex: winnerIndex,
      basePoints: basePoints,
      roundMultiplier: finalMultiplier,
      extraMultiplier: extraMultiplier,
      totalPoints: total,
      deltas: deltas,
      reason: finalReason,
    );
  }

  FixedScore _calcFixedScore(Player winner, bool isSelfDraw) {
    if (_isFengPeng(winner)) return FixedScore(40, '风碰');
    if (_isFengYiSe(winner)) return FixedScore(20, '风一色');
    if (_isQingYiSe(winner)) return FixedScore(10, '清一色');
    if (_isWuHuaZiMo(winner, isSelfDraw)) return FixedScore(10, '无花自摸');
    if (_isGangKai(winner, isSelfDraw)) return FixedScore(10, '杠开');
    return FixedScore(0, '');
  }

  int _calcBasePoints(Player winner) {
    final flowerCount = _countFlowers(winner);
    final meldPoints = _calcMeldPoints(winner);
    return 2 + flowerCount + meldPoints;
  }

  int _countFlowers(Player winner) {
    final inHand = winner.handTiles.where((t) => t.isFlower || t.suit == TileSuit.hua).length;
    return winner.flowerTiles.length + inHand;
  }

  int _calcMeldPoints(Player winner) {
    int points = 0;
    final tiles = _allNonFlowerTiles(winner);
    final counts = <String, int>{};
    for (final t in tiles) {
      final key = '${t.type.index}_${t.number}';
      counts[key] = (counts[key] ?? 0) + 1;
    }
    for (final entry in counts.entries) {
      final parts = entry.key.split('_');
      final typeIdx = int.parse(parts[0]);
      final cnt = entry.value;
      if (cnt >= 3) {
        final isKong = cnt == 4;
        if (typeIdx == TileType.wind.index) {
          points += isKong ? 2 : 1;
        } else if (typeIdx == TileType.dragon.index) {
          points += isKong ? 3 : 2;
        } else if (isKong) {
          points += 1;
        }
      }
    }
    return points;
  }

  int _calcExtraMultiplier(Player winner) {
    int extra = 1;
    // 无百搭（目前未实现百搭，视为无百搭）
    if (wildTile == null) extra *= 2;
    // 门清（没有吃/碰）: 简化为没有明刻/顺
    if (winner.melds.isEmpty) extra *= 2;
    return extra;
  }

  List<Tile> _allNonFlowerTiles(Player winner) {
    final tiles = <Tile>[];
    tiles.addAll(winner.handTiles);
    for (final m in winner.melds) {
      tiles.addAll(m);
    }
    return tiles.where((t) => !t.isFlower && t.suit != TileSuit.hua).toList();
  }

  bool _isFengYiSe(Player winner) {
    final tiles = _allNonFlowerTiles(winner);
    if (tiles.isEmpty) return false;
    return tiles.every((t) => t.type == TileType.wind);
  }

  bool _isFengPeng(Player winner) {
    final tiles = _allNonFlowerTiles(winner);
    if (tiles.isEmpty) return false;
    if (!tiles.every((t) => t.type == TileType.wind)) return false;
    final counts = <String, int>{};
    for (final t in tiles) {
      final key = '${t.type.index}_${t.number}';
      counts[key] = (counts[key] ?? 0) + 1;
    }
    // 风碰：所有牌应成刻子/对子
    return counts.values.every((c) => c == 2 || c == 3 || c == 4);
  }

  bool _isQingYiSe(Player winner) {
    final tiles = _allNonFlowerTiles(winner);
    if (tiles.isEmpty) return false;
    // 不能包含风/箭
    if (tiles.any((t) => t.type == TileType.wind || t.type == TileType.dragon)) return false;
    TileSuit? suit;
    for (final t in tiles) {
      if (t.suit == TileSuit.wan || t.suit == TileSuit.tong || t.suit == TileSuit.tiao) {
        suit ??= t.suit;
        if (t.suit != suit) return false;
      }
    }
    return suit != null;
  }

  bool _isWuHuaZiMo(Player winner, bool isSelfDraw) {
    if (!isSelfDraw) return false;
    if (_countFlowers(winner) > 0) return false;
    final tiles = _allNonFlowerTiles(winner);
    final counts = <String, int>{};
    for (final t in tiles) {
      final key = '${t.type.index}_${t.number}';
      counts[key] = (counts[key] ?? 0) + 1;
    }
    for (final entry in counts.entries) {
      final typeIdx = int.parse(entry.key.split('_')[0]);
      final cnt = entry.value;
      if ((typeIdx == TileType.wind.index || typeIdx == TileType.dragon.index) && cnt >= 3) {
        return false;
      }
    }
    return true;
  }

  bool _isGangKai(Player winner, bool isSelfDraw) {
    // TODO: 缺少杠后补牌标记，暂不判定
    return false;
  }

  void _applySettlement(SettlementResult result) {
    lastSettlement = result;
    for (int i = 0; i < 4; i++) {
      players[i].score += result.deltas[i] ?? 0;
      players[i].totalScore += result.deltas[i] ?? 0;
    }
    // 非流局则重置全局倍数
    if (!result.isDraw) {
      globalMultiplier = 1;
    }
    phase = GamePhase.scoring;
    gameEnded = true;
  }

  void resetForNextRound() {
    initWall();
    diceRolled = false;
    diceValues = [1, 1];
    pendingTile = null;
    lastPlayedTile = null;
    lastDiscarderIndex = null;
    wildTile = null;
    awaitingPlayerResponse = false;
    mustDiscard = false;
    phase = GamePhase.waiting;
    gameEnded = false;
    eliminatedPlayers.clear();
    baoRelations.clear();
    lastSettlement = null;
    for (final p in players) {
      p.handTiles.clear();
      p.melds.clear();
      p.playedTiles.clear();
      p.flowerTiles.clear();
    }
  }
  
  // 血战到底：玩家胡牌
  // 返回 true 表示游戏结束，false 表示继续
  bool playerWins(int playerIndex) {
    eliminatedPlayers.add(playerIndex);
    
    // 血战到底：重新计算上家关系
    // 原来上家变成下家，继续游戏
    _recalculatePositionsAfterElimination(playerIndex);
    
    // 检查是否只剩一家
    if (activePlayerCount <= 1) {
      // 游戏结束
      _applySettlement(_settleWin(playerIndex));
      return true;
    }
    
    // 牌墙已摸完
    if (wall.isEmpty) {
      resolveDraw();
      return true;
    }
    
    // 继续游戏（跳过已胡牌的玩家）
    _nextActivePlayer();
    return false;
  }
  
  // 血战到底：移除玩家后重新计算位置
  void _recalculatePositionsAfterElimination(int eliminatedIndex) {
    // 由于是血战到底，剩下三家继续
    // 上家/下家关系需要动态计算：
    // 原来的上家可能变成新的下家
    // 包关系也会重新计算
    
    // 例如：0胡 → 1,2,3继续
    // 1的上家变成2，下家变成0(已胡)
    // 2的上家变成0(已胡)，下家变成1
    // 3的上家变成1，下家变成0(已胡)
    
    // 实际上，逆时针顺序保持不变，只是跳过已胡玩家
    // currentPlayerIndex 不需要改变，会在 _nextActivePlayer 中处理
  }
  
  // 血战到底：移动到下一个活跃玩家
  void _nextActivePlayer() {
    for (int i = 0; i < 4; i++) {
      currentPlayerIndex = (currentPlayerIndex + 3) % 4; // 逆时针
      if (!eliminatedPlayers.contains(currentPlayerIndex)) {
        break;
      }
    }
  }
  
  // 检查指定玩家是否已胡牌
  bool isPlayerEliminated(int playerIndex) {
    return eliminatedPlayers.contains(playerIndex);
  }

  bool _isWildTile(Tile t) {
    if (wildTile == null) return false;
    return t.type == wildTile!.type && t.number == wildTile!.number;
  }

  // 检查是否可以碰
  bool canPong(Player player) {
    if (pendingTile == null) return false;
    final t = pendingTile!;
    if (_isWildTile(t)) return false; // 百搭牌不可吃碰杠
    return player.handTiles.where((tile) => tile.type == t.type && tile.number == t.number).length >= 2;
  }

  // 检查是否可以杠
  bool canKong(Player player) {
    // 明杠：手里有三张，碰哪家打出的牌
    if (pendingTile != null) {
      final t = pendingTile!;
      if (_isWildTile(t)) return false; // 百搭牌不可吃碰杠
      if (player.handTiles.where((tile) => tile.type == t.type && tile.number == t.number).length >= 3) {
        return true;
      }
    }
    
    // 暗杠：手里有四张相同的牌
    return canHiddenKong(player);
  }
  
  // 检查暗杠
  bool canHiddenKong(Player player) {
    final counts = <String, int>{};
    for (final t in player.handTiles) {
      final key = '${t.type}_${t.number}';
      counts[key] = (counts[key] ?? 0) + 1;
    }
    return counts.values.any((c) => c == 4);
  }
  
  // 获取可以杠的牌
  List<Tile> getKongableTiles(Player player) {
    final result = <Tile>[];
    
    // 明杠
    if (pendingTile != null) {
      final t = pendingTile!;
      if (player.handTiles.where((tile) => tile.type == t.type && tile.number == t.number).length >= 3) {
        result.add(t);
      }
    }
    
    // 暗杠
    final counts = <String, List<Tile>>{};
    for (final t in player.handTiles) {
      final key = '${t.type}_${t.number}';
      counts[key] = [...(counts[key] ?? []), t];
    }
    for (final tiles in counts.values) {
      if (tiles.length == 4) {
        result.add(tiles.first);
      }
    }
    
    return result;
  }
  
  // 执行杠牌（明杠记录包关系，暗杠不记录）
  bool doKong(Player player, Tile kongTile, {bool isHidden = false}) {
    // 明杠：记录包关系（杠别人打出的牌）
    if (!isHidden && pendingTile != null) {
      final fromPlayer = player.index; // 杠牌者
      final toPlayer = currentPlayerIndex; // 打牌者
      recordBao(fromPlayer, toPlayer);
    }

    final meld = <Tile>[];
    if (!isHidden && pendingTile != null) {
      // 明杠：手里移除三张 + 吃入一张
      int removed = 0;
      for (int i = player.handTiles.length - 1; i >= 0; i--) {
        final t = player.handTiles[i];
        if (t.type == kongTile.type && t.number == kongTile.number) {
          player.handTiles.removeAt(i);
          meld.add(t);
          removed++;
          if (removed == 3) break;
        }
      }
      meld.add(pendingTile!);
      pendingTile = null;
    } else {
      // 暗杠：手里移除四张
      int removed = 0;
      for (int i = player.handTiles.length - 1; i >= 0; i--) {
        final t = player.handTiles[i];
        if (t.type == kongTile.type && t.number == kongTile.number) {
          player.handTiles.removeAt(i);
          meld.add(t);
          removed++;
          if (removed == 4) break;
        }
      }
      if (removed < 4) return false;
    }

    player.melds.add(meld);
    currentPlayerIndex = player.index;
    if (player.index == 0) {
      mustDiscard = true;
    }
    return true;
  }

  // 检查是否可以胡
  bool canHu(Player player) {
    final tiles = <Tile>[...player.handTiles];
    if (pendingTile != null) {
      tiles.add(pendingTile!); // 点炮胡
    }
    return checkHu(tiles);
  }

  // 核心胡牌检测（支持百搭）
  bool checkHu(List<Tile> tiles) {
    final counts = <String, int>{};
    int wildCount = 0;

    for (final t in tiles) {
      if (_isWildTile(t)) {
        wildCount++;
        continue;
      }
      if (t.isFlower || t.suit == TileSuit.hua) continue;
      final key = '${t.type.index}_${t.number}';
      counts[key] = (counts[key] ?? 0) + 1;
    }

    int totalTiles = wildCount;
    for (final v in counts.values) {
      totalTiles += v;
    }
    if (totalTiles % 3 != 2) return false;

    bool canMelds(Map<String, int> c, int wild) {
      String? firstKey;
      for (final k in c.keys) {
        if ((c[k] ?? 0) > 0) { firstKey = k; break; }
      }
      if (firstKey == null) {
        return wild % 3 == 0;
      }

      final parts = firstKey.split('_');
      final typeIdx = int.parse(parts[0]);
      final number = int.parse(parts[1]);
      final countFirst = c[firstKey] ?? 0;

      // 刻子（用百搭补）
      if (countFirst >= 3) {
        c[firstKey] = countFirst - 3;
        if (canMelds(c, wild)) return true;
        c[firstKey] = countFirst;
      }
      if (countFirst == 2 && wild >= 1) {
        c[firstKey] = 0;
        if (canMelds(c, wild - 1)) return true;
        c[firstKey] = 2;
      }
      if (countFirst == 1 && wild >= 2) {
        c[firstKey] = 0;
        if (canMelds(c, wild - 2)) return true;
        c[firstKey] = 1;
      }

      // 顺子（仅万/筒/条，百搭可补）
      if (typeIdx <= TileType.tiao.index && number <= 7) {
        final k1 = '${typeIdx}_${number + 1}';
        final k2 = '${typeIdx}_${number + 2}';
        final c1 = c[k1] ?? 0;
        final c2 = c[k2] ?? 0;
        int needWild = 0;
        if (c1 == 0) needWild++;
        if (c2 == 0) needWild++;
        if (wild >= needWild) {
          c[firstKey] = countFirst - 1;
          if (c1 > 0) c[k1] = c1 - 1;
          if (c2 > 0) c[k2] = c2 - 1;
          if (canMelds(c, wild - needWild)) return true;
          c[firstKey] = countFirst;
          if (c1 > 0) c[k1] = c1;
          if (c2 > 0) c[k2] = c2;
        }
      }

      return false;
    }

    bool canWinWithPair(Map<String, int> c, int wild) {
      // 1) 真实对子
      for (final k in c.keys) {
        if ((c[k] ?? 0) >= 2) {
          c[k] = (c[k] ?? 0) - 2;
          if (canMelds(c, wild)) return true;
          c[k] = (c[k] ?? 0) + 2;
        }
      }
      // 2) 1张+百搭
      if (wild >= 1) {
        for (final k in c.keys) {
          if ((c[k] ?? 0) >= 1) {
            c[k] = (c[k] ?? 0) - 1;
            if (canMelds(c, wild - 1)) return true;
            c[k] = (c[k] ?? 0) + 1;
          }
        }
      }
      // 3) 百搭对
      if (wild >= 2) {
        if (canMelds(c, wild - 2)) return true;
      }
      return false;
    }

    return canWinWithPair(counts, wildCount);
  }

  // 检查是否满足五毒散
  bool checkWuDuSan() {
    // 首轮检查庄家
    final player = players[dealerIndex];
    return player.isWuDuSan;
  }


  // AI执行一步（吃/碰/摸/打）
  void aiPlay(int playerIndex) {
    if (playerIndex == 0) return; // 玩家自己控制
    
    final player = players[playerIndex];
    
    // 1. 检查能否胡
    if (canHu(player)) {
      playerWins(playerIndex);
      return;
    }
    
    // 2. 检查能否杠
    if (canKong(player)) {
      final kongTiles = getKongableTiles(player);
      if (kongTiles.isNotEmpty) {
        doKong(player, kongTiles.first, isHidden: false);
        drawTile(player);
        aiDiscard(playerIndex);
        return;
      }
    }
    
    // 3. 检查能否碰
    if (canPong(player) && pendingTile != null) {
      doPong(player);
      drawTile(player);
      aiDiscard(playerIndex);
      return;
    }
    
    // 4. 检查能否吃
    if (canChow(player)) {
      doChow(player, null);
      drawTile(player);
      aiDiscard(playerIndex);
      return;
    }
    
    // 5. 正常摸牌
    if (pendingTile == null) {
      drawTile(player);
      aiDiscard(playerIndex);
    }
  }
  
  // AI打牌
  void aiDiscard(int playerIndex) {
    final player = players[playerIndex];
    if (player.handTiles.isEmpty) return;
    
    // 简单策略：打第一张
    final discard = player.handTiles.removeAt(0);
    player.playedTiles.add(discard);
    pendingTile = discard;
    lastPlayedTile = discard;
    lastDiscarderIndex = playerIndex;
    awaitingPlayerResponse = false;
    
    // AI打牌后，检查响应
    processTurn();
  }

  // ===== 游戏状态机 =====
  
  // 检查所有玩家是否可响应（吃/碰/杠/胡）
  int? checkPlayerResponses() {
    if (pendingTile == null) return null;
    
    // 按逆时针顺序检查：下家→对家→上家
    for (int offset = 1; offset <= 3; offset++) {
      final playerIdx = (currentPlayerIndex + offset) % 4;
      if (playerIdx == 0) continue;
      
      final player = players[playerIdx];
      if (canHu(player)) return playerIdx;
      if (canKong(player)) return playerIdx;
      if (canPong(player)) return playerIdx;
      if (playerIdx == (currentPlayerIndex + 1) % 4 && canChow(player)) return playerIdx;
    }
    return null;
  }
  
  // 强制回合流转
  void processTurn({bool skipPlayerResponse = false}) {
    if (pendingTile == null) return;

    // 玩家有响应权（只在AI打牌后）
    if (!skipPlayerResponse && currentPlayerIndex != 0) {
      final player = players[0];
      final canRespond = canHu(player) || canKong(player) || canPong(player) || canChow(player);
      if (canRespond) {
        awaitingPlayerResponse = true;
        return;
      }
    }

    awaitingPlayerResponse = false;
    final responder = checkPlayerResponses();
    if (responder != null) {
      Future.delayed(const Duration(milliseconds: 300), () {
        aiPlay(responder);
      });
    } else {
      // 无人响应，下家摸牌
      pendingTile = null;
      nextPlayer();
      drawTile(players[currentPlayerIndex]);
      if (currentPlayerIndex != 0) {
        Future.delayed(const Duration(milliseconds: 500), () {
          aiDiscard(currentPlayerIndex);
        });
      }
    }
  }

  // 玩家选择“过”
  void playerPass() {
    awaitingPlayerResponse = false;
    processTurn(skipPlayerResponse: true);
  }

}
