// 牌定义
class Tile {
  final int id;
  final TileType type;
  final int number;
  final TileSuit suit;
  final bool isFlower;
  final bool isWild;

  Tile({required this.id, required this.type, required this.number, required this.suit, this.isFlower = false, this.isWild = false});

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
enum TileSuit { wan, tong, tiao, hua }

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

// 游戏逻辑核心
class MahjongGame {
  List<Tile> wall = []; // 牌墙
  List<Tile> deadWall = [];
  List<Player> players = [];
  int currentPlayerIndex = 0;
  int dealerIndex = 0;
  int roundMultiplier = 1;
  int globalMultiplier = 1;
  Tile? wildTile;
  bool diceRolled = false;
  List<int> diceValues = [1, 1];
  GamePhase phase = GamePhase.waiting;
  Tile? lastPlayedTile;
  Tile? pendingTile; // 等待响应的牌
  bool gameEnded = false;

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
        wall.add(Tile(id: id++, type: TileType.wind, number: n, suit: TileSuit.hua));
      }
    }
    // 箭牌 中发白 x4
    for (int n = 1; n <= 3; n++) {
      for (int i = 0; i < 4; i++) {
        wall.add(Tile(id: id++, type: TileType.dragon, number: n, suit: TileSuit.hua));
      }
    }
    // 花牌 春夏秋冬梅兰菊竹 x8
    for (int n = 1; n <= 8; n++) {
      wall.add(Tile(id: id++, type: TileType.flower, number: n, suit: TileSuit.hua, isFlower: true));
    }
  }

  int get remainingTiles => wall.length;

  // 掷骰子
  void rollDice() {
    diceValues[0] = DateTime.now().millisecond % 6 + 1;
    diceValues[1] = DateTime.now().microsecond % 6 + 1;
    diceRolled = true;
    
    // 计算回合倍数
    final sum = diceValues[0] + diceValues[1];
    roundMultiplier = (sum % 2 == 0) ? sum : 1;
    if (roundMultiplier > 4) roundMultiplier = 4;
  }

  // 发牌
  void deal() {
    // 庄家14张，闲家13张
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
    // 庄家再拿1张
    for (int p = 0; p < 4; p++) {
      final idx = (dealerIndex + p) % 4;
      if (wall.isNotEmpty) {
        players[idx].handTiles.add(wall.removeLast());
      }
    }
    // 整理手牌
    for (final p in players) {
      p.sortHand();
    }
    phase = GamePhase.playing;
  }

  // 摸牌
  Tile? drawTile(Player player) {
    if (wall.isEmpty) {
      // 流局
      phase = GamePhase.scoring;
      return null;
    }
    final tile = wall.removeLast();
    player.handTiles.add(tile);
    return tile;
  }

  // 打牌
  void playTile(Player player, Tile tile) {
    player.handTiles.remove(tile);
    player.playedTiles.add(tile);
    lastPlayedTile = tile;
  }

  // 逆时针下一家
  void nextPlayer() {
    currentPlayerIndex = (currentPlayerIndex + 3) % 4;
  }

  // 检查是否可以吃（上家动态）
  bool canChow(Player player) {
    if (pendingTile == null || currentPlayerIndex == 0) return false;
    // 只能吃上家（逆时针方向）
    // 当前是 playerIndex，上家是 (playerIndex + 1) % 4
    final fromPlayer = (currentPlayerIndex + 1) % 4;
    // 只有当前玩家是下家时才能吃上家的牌
    if (player.index != fromPlayer) return false;
    
    final t = pendingTile!;
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
        combos.add([need1, need2, need3]);
      }
    }
    return combos;
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

  // 检查是否可以碰
  bool canPong(Player player) {
    if (pendingTile == null) return false;
    final t = pendingTile!;
    return player.handTiles.where((tile) => tile.type == t.type && tile.number == t.number).length >= 2;
  }

  // 检查是否可以杠
  bool canKong(Player player) {
    // 明杠：手里有三张，碰哪家打出的牌
    if (pendingTile != null) {
      final t = pendingTile!;
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

  // 检查是否可以胡
  bool canHu(Player player) {
    return checkHu(player.handTiles);
  }

  // 核心胡牌检测
  bool checkHu(List<Tile> tiles) {
    if (tiles.length != 13 && tiles.length != 14) return false;
    
    // 简单检测：假设 tiles 已排序
    // 实际需要复杂的搭子/刻子分析
    // 这里简化处理
    return false; // TODO: 实现完整胡牌判断
  }

  // 检查是否满足五毒散
  bool checkWuDuSan() {
    // 首轮检查庄家
    final player = players[dealerIndex];
    return player.isWuDuSan;
  }
}
