import 'dart:math';
import '../models/tile_model.dart';
import '../models/player_model.dart';
import '../services/game_logger.dart';
import '../logic/tile_type_detector.dart';
import '../logic/hu_judge.dart';
import '../logic/settlement_calculator.dart';

/// 结算结果
class SettlementResult {
  final Player winner;
  final HuType huType;
  final int basePoints;
  final int totalPoints;
  final Map<Player, int> payments;

  SettlementResult({
    required this.winner,
    required this.huType,
    required this.basePoints,
    required this.totalPoints,
    required this.payments,
  });
}

class MahjongGame {
  List<Tile> tiles = [];
  int wallIndex = 0;
  int wallTailIndex = 0;
  List<Player> players = [];
  int currentPlayerIndex = 0;
  int dealerIndex = 0;
  GameState gameState = GameState.waiting;
  List<int> diceValues = [0, 0];
  int roundMultiplier = 1;
  bool diceRolled = false;
  Tile? wildTile;
  int wildTilePosition = 0;
  Tile? lastPlayedTile;
  Player? lastPlayedBy;
  int multiplier = 1;
  List<Player> huPlayers = [];
  final Random _random = Random();
  int? nextDealerIndex;
  bool justDrewAfterKong = false;
  Map<String, int> _chowPong = {};
  
  // 日志服务
  GameLogger? _logger;
  int? _currentRoundId;
  int _turnNumber = 0;
  
  // 设置日志服务
  void setLogger(GameLogger logger) {
    _logger = logger;
  }
  
  // 初始化日志（创建玩家）
  Future<void> initLogger() async {
    if (_logger == null) return;
    for (final player in players) {
      await _logger!.getOrCreatePlayer(player.name);
    }
  }

  void initGame() {
    tiles = [];
    players = [];
    huPlayers = [];
    wallIndex = 0;
    wallTailIndex = 0;
    dealerIndex = 0;
    currentPlayerIndex = 0;
    wildTile = null;
    wildTilePosition = 0;
    lastPlayedTile = null;
    lastPlayedBy = null;
    multiplier = 1;
    roundMultiplier = 1;
    gameState = GameState.waiting;
    diceValues = [0, 0];
    diceRolled = false;
    nextDealerIndex = null;
    justDrewAfterKong = false;
    _chowPong = {};
    _turnNumber = 0;

    _createAllTiles();
    shuffleTiles();
    _initPlayers();
  }
  
  /// 创建新局次记录
  Future<int> createRoundRecord(int roundNumber) async {
    if (_logger != null) {
      _currentRoundId = await _logger!.createGameRound(
        roundNumber: roundNumber,
        dealerId: players.isNotEmpty ? players[dealerIndex].id : null,
        diceValues: diceValues.join(','),
        roundMultiplier: roundMultiplier,
        globalMultiplier: multiplier,
      );
      return _currentRoundId!;
    }
    return 0;
  }
  
  /// 回合数递增
  void incrementTurn() {
    _turnNumber++;
  }
  
  /// 记录结算
  Future<void> recordSettlement(SettlementResult result, {bool isSelfDrawn = false}) async {
    if (_logger == null || _currentRoundId == null) return;
    
    // 更新局次结果
    await _logger!.updateGameRound(
      roundId: _currentRoundId!,
      winnerId: result.winner.id,
      winType: result.huType.toString(),
      isSelfDrawn: isSelfDrawn,
      basePoints: result.basePoints,
      totalPot: result.totalPoints,
    );
    
    // 记录每个玩家的结算
    for (final entry in result.payments.entries) {
      final player = entry.key;
      final points = entry.value;
      
      await _logger!.logSettlement(
        roundId: _currentRoundId!,
        playerId: player.id,
        basePoints: result.basePoints,
        multiplier: roundMultiplier * multiplier,
        baoMultiplier: 1, // TODO: 计算包牌倍数
        finalPoints: points,
        isWinner: player == result.winner,
        isPayer: points > 0,
        paymentToPlayerId: result.winner.id,
      );
      
      // 更新玩家总分
      await _logger!.updatePlayerScore(
        playerId: player.id,
        gameDate: DateTime.now(),
        pointsChange: player == result.winner ? points : -points,
        isWin: player == result.winner,
        isLoss: player != result.winner,
        isDraw: false,
      );
    }
  }

  void _createAllTiles() {
    int id = 0;
    for (int n = 1; n <= 9; n++) {
      for (int i = 0; i < 4; i++) {
        tiles.add(Tile(type: TileType.values[n - 1], id: id++));
      }
    }
    for (int n = 1; n <= 9; n++) {
      for (int i = 0; i < 4; i++) {
        tiles.add(Tile(type: TileType.values[8 + n], id: id++));
      }
    }
    for (int n = 1; n <= 9; n++) {
      for (int i = 0; i < 4; i++) {
        tiles.add(Tile(type: TileType.values[17 + n], id: id++));
      }
    }
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        tiles.add(Tile(type: TileType.values[27 + i], id: id++));
      }
    }
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 4; j++) {
        tiles.add(Tile(type: TileType.values[31 + i], id: id++));
      }
    }
    for (int i = 0; i < 8; i++) {
      tiles.add(Tile(type: TileType.values[34 + i], id: id++));
    }
  }

  void shuffleTiles() {
    tiles.shuffle(_random);
    wallIndex = 0;
    wallTailIndex = tiles.length - 1;
  }

  void _initPlayers() {
    players = [
      Player(id: 0, name: '东家', position: PlayerPosition.self),
      Player(id: 1, name: '南家', position: PlayerPosition.right),
      Player(id: 2, name: '西家', position: PlayerPosition.opposite),
      Player(id: 3, name: '北家', position: PlayerPosition.left),
    ];
  }

  void rollDice() {
    diceValues[0] = _random.nextInt(6) + 1;
    diceValues[1] = _random.nextInt(6) + 1;
    if (diceValues[0] == diceValues[1]) {
      roundMultiplier = (diceValues[0] == 1 || diceValues[0] == 4) ? 4 : 2;
    } else {
      roundMultiplier = 1;
    }
    diceRolled = true;
  }

  void startRound() {
    gameState = GameState.dealing;
    if (nextDealerIndex != null) {
      dealerIndex = nextDealerIndex!;
      nextDealerIndex = null;
    }

    final n = diceValues.reduce(max);
    wildTilePosition = 2 * n;
    final wildIndex = wallTailIndex - wildTilePosition + 1;
    final safeWildIndex = min(max(wildIndex, 0), tiles.length - 1);
    wildTile = tiles[safeWildIndex];

    _dealTiles();
    gameState = GameState.playing;
  }

  void _dealTiles() {
    for (int r = 0; r < 3; r++) {
      for (int i = 0; i < 4; i++) {
        for (int j = 0; j < 3; j++) {
          players[i].handTiles.add(tiles[wallIndex++]);
        }
      }
    }
    for (int i = 0; i < 4; i++) {
      players[i].handTiles.add(tiles[wallIndex++]);
    }
    players[dealerIndex].handTiles.add(tiles[wallIndex++]);

    for (final p in players) {
      p.sortHand();
    }
  }

  Tile? drawTile(Player player, {bool afterKong = false}) {
    justDrewAfterKong = afterKong;

    while (true) {
      if (wallIndex >= wallTailIndex - wildTilePosition + 1) {
        // 牌墙已摸完，记录流局
        _logger?.updateGameRound(roundId: _currentRoundId!, isFlow: true);
        return null;
      }

      final tile = tiles[wallIndex++];
      if (tile.isHua) {
        player.drawFlowerTile(tile);
        continue;
      }

      player.addTile(tile);
      
      // 记录摸牌日志
      if (_logger != null && _currentRoundId != null) {
        _logger!.logDraw(
          roundId: _currentRoundId!,
          turnNumber: _turnNumber,
          playerId: player.id,
          tileType: tile.type.toString(),
        );
      }
      
      return tile;
    }
  }

  void playTile(Player player, Tile tile) {
    player.removeTile(tile);
    player.playedTiles.add(tile);
    lastPlayedTile = tile;
    
    // 记录打牌日志
    if (_logger != null && _currentRoundId != null) {
      _logger!.logDiscard(
        roundId: _currentRoundId!,
        turnNumber: _turnNumber,
        playerId: player.id,
        tileType: tile.type.toString(),
      );
    }
    lastPlayedBy = player;
    justDrewAfterKong = false;
  }

  List<Tile> _findChowTiles(Player player, Tile target) {
    if (!target.isXuPai) return [];
    final suit = target.suit;
    final n = target.number;

    List<Tile> getTiles(int num) =>
        player.handTiles.where((t) => t.suit == suit && t.number == num).toList();

    if (n >= 2 && n <= 8) {
      final a = getTiles(n - 1);
      final b = getTiles(n + 1);
      if (a.isNotEmpty && b.isNotEmpty) return [a.first, b.first];
    }
    if (n >= 3) {
      final a = getTiles(n - 2);
      final b = getTiles(n - 1);
      if (a.isNotEmpty && b.isNotEmpty) return [a.first, b.first];
    }
    if (n <= 7) {
      final a = getTiles(n + 1);
      final b = getTiles(n + 2);
      if (a.isNotEmpty && b.isNotEmpty) return [a.first, b.first];
    }
    return [];
  }

  bool canChow(Player player, Tile target) {
    if (lastPlayedBy == null) return false;
    final playerIndex = players.indexOf(player);
    final targetIndex = players.indexOf(lastPlayedBy!);
    if ((playerIndex + 3) % 4 != targetIndex) return false;
    return _findChowTiles(player, target).isNotEmpty;
  }

  List<Tile>? chow(Player player, Tile target) {
    if (!canChow(player, target)) return null;
    final tiles = _findChowTiles(player, target);
    if (tiles.isEmpty) return null;

    player.removeTile(tiles[0]);
    player.removeTile(tiles[1]);
    player.exposedMelds.add([tiles[0], tiles[1], target]);
    
    // 记录吃牌日志
    if (_logger != null && _currentRoundId != null && lastPlayedBy != null) {
      _logger!.logChow(
        roundId: _currentRoundId!,
        turnNumber: _turnNumber,
        playerId: player.id,
        tileType: target.type.toString(),
        fromPlayerId: lastPlayedBy!.id,
      );
    }
    
    return [tiles[0], tiles[1], target];
  }

  bool canPong(Player player, Tile target) {
    final matches = player.handTiles.where((t) => t.type == target.type).length;
    return matches >= 2;
  }

  List<Tile>? pong(Player player, Tile target) {
    if (!canPong(player, target)) return null;
    final matches = player.handTiles.where((t) => t.type == target.type).take(2).toList();
    if (matches.length < 2) return null;

    player.removeTile(matches[0]);
    player.removeTile(matches[1]);
    player.exposedMelds.add([matches[0], matches[1], target]);
    
    // 记录碰牌日志
    if (_logger != null && _currentRoundId != null && lastPlayedBy != null) {
      _logger!.logPong(
        roundId: _currentRoundId!,
        turnNumber: _turnNumber,
        playerId: player.id,
        tileType: target.type.toString(),
        fromPlayerId: lastPlayedBy!.id,
      );
    }
    
    return [matches[0], matches[1], target];
  }

  bool canExposedKong(Player player, Tile target) {
    final matches = player.handTiles.where((t) => t.type == target.type).length;
    return matches >= 3;
  }

  List<Tile>? exposedKong(Player player, Tile target) {
    if (!canExposedKong(player, target)) return null;
    final matches = player.handTiles.where((t) => t.type == target.type).take(3).toList();
    if (matches.length < 3) return null;

    for (final tile in matches) {
      player.removeTile(tile);
    }
    player.exposedMelds.add([...matches, target]);
    
    // 记录明杠日志
    if (_logger != null && _currentRoundId != null && lastPlayedBy != null) {
      _logger!.logExposedKong(
        roundId: _currentRoundId!,
        turnNumber: _turnNumber,
        playerId: player.id,
        tileType: target.type.toString(),
        fromPlayerId: lastPlayedBy!.id,
      );
    }
    
    return [...matches, target];
  }

  bool canHiddenKong(Player player) {
    final counts = <TileType, int>{};
    for (final tile in player.handTiles) {
      counts[tile.type] = (counts[tile.type] ?? 0) + 1;
    }
    return counts.values.any((count) => count >= 4);
  }

  List<Tile>? hiddenKong(Player player) {
    final groups = <TileType, List<Tile>>{};
    for (final tile in player.handTiles) {
      groups.putIfAbsent(tile.type, () => []).add(tile);
    }

    for (final entry in groups.entries) {
      if (entry.value.length >= 4) {
        final meld = entry.value.take(4).toList();
        for (final tile in meld) {
          player.removeTile(tile);
        }
        player.concealedMelds.add(meld);
        
        // 记录暗杠日志
        if (_logger != null && _currentRoundId != null) {
          _logger!.logHiddenKong(
            roundId: _currentRoundId!,
            turnNumber: _turnNumber,
            playerId: player.id,
            tileType: meld.first.type.toString(),
          );
        }
        
        return meld;
      }
    }
    return null;
  }

  bool canHu(Player player, {Tile? newTile, bool isSelfDrawn = false}) {
    final hand = _buildCandidateHand(player, newTile: newTile);
    return HuJudge.canHu(hand);
  }

  bool canRonWithTile(Player player, Tile tile) => canHu(player, newTile: tile);
  
  bool canRonWithHuType(Player player, HuType huType) => checkHuType(player) == huType;
  Player get currentPlayer => players[currentPlayerIndex];

  void nextPlayer() => currentPlayerIndex = (currentPlayerIndex + 1) % 4;

  int get remainingTiles {
    final drawLimit = wallTailIndex - wildTilePosition + 1;
    return max(0, drawLimit - wallIndex);
  }

  bool get isDraw => wallIndex >= wallTailIndex - wildTilePosition + 1;

  int get totalMultiplier => roundMultiplier * multiplier;

  Tile? aiPlayTile(Player player) {
    if (player.handTiles.isEmpty) return null;
    final index = _random.nextInt(player.handTiles.length);
    final tile = player.handTiles[index];
    playTile(player, tile);
    return tile;
  }

  SettlementResult? calculateSettlement(
    Player winner, {
    Tile? huTile,
    bool isSelfDrawn = false,
    bool isKaiGang = false,
    bool isNoFlowerSD = false, // 无花自摸
  }) {
    final huType = checkHuType(winner, newTile: huTile) ?? HuType.basic;
    
    // 先检查固定点数牌型
    final fixedPoints = getFixedPoints(huType, isSelfDrawn: isSelfDrawn, isNoFlowerSelfDraw: isNoFlowerSD);
    int basePoints;
    
    if (fixedPoints > 0) {
      // 固定点数牌型
      basePoints = fixedPoints;
    } else {
      // 公式计算牌型
      basePoints = 2; // 基础分
      // 加上花牌数
      basePoints += winner.flowerTiles.length;
      // 加上组合牌点数（刻子、杠）
      basePoints += _calculateMeldPoints(winner);
    }
    
    // 杠开点数
    if (isKaiGang) {
      basePoints += getKaiGangPoints(true);
    }
    
    // 自摸加1点
    if (isSelfDrawn) {
      basePoints += 1;
    }

    // 计算额外翻倍
    int extraMultiplier = 1;
    if (!hasWildTile(winner)) extraMultiplier *= 2; // 无百搭×2
    if (winner.isMenQing) extraMultiplier *= 2; // 门清×2
    
    final totalPoints = basePoints * roundMultiplier * multiplier * extraMultiplier;
    final payments = <Player, int>{};

    if (isSelfDrawn) {
      // 自摸时：完全由互包关系的玩家支付点数
      // 其他无互包关系的玩家不需要支付
      for (final player in players) {
        if (player == winner) continue;
        
        final baoMultiplier = calculateBaoMultiplier(winner, player);
        if (baoMultiplier > 1) {
          // 有互包关系，应用包牌倍数
          payments[player] = totalPoints * baoMultiplier;
        }
        // 无互包关系则不支付
      }
    } else if (lastPlayedBy != null && lastPlayedBy != winner) {
      // 放冲时：
      // 1. 放冲者正常赔付 totalPoints
      // 2. 互包关系中的其他输家，赔付 = 放冲者输掉的点数
      // 3. 互包玩家互相放冲 → 2倍，和其他人没关系
      
      final uploader = lastPlayedBy!;
      final uploaderBaoMultiplier = calculateBaoMultiplier(winner, uploader);
      
      // 放冲者赔付
      if (uploaderBaoMultiplier > 1) {
        // 互包玩家互相放冲 → 2倍
        payments[uploader] = totalPoints * 2;
      } else {
        // 无互包关系，正常赔付
        payments[uploader] = totalPoints;
      }
      
      // 其他有互包关系的输家，赔付 = 放冲者输掉的点数
      for (final player in players) {
        if (player == winner || player == uploader) continue;
        
        final baoMultiplier = calculateBaoMultiplier(winner, player);
        if (baoMultiplier > 1) {
          // 赔付 = 放冲者输掉的点数
          payments[player] = payments[uploader]!;
        }
      }
    }

    return SettlementResult(
      winner: winner,
      huType: huType,
      basePoints: basePoints,
      totalPoints: totalPoints,
      payments: payments,
    );
  }

  /// 计算门口牌的点数
  int _calculateMeldPoints(Player player) {
    int points = 0;
    
    // 明刻子
    for (final meld in player.exposedMelds) {
      if (meld.length == 3) {
        if (meld.first.isFeng) {
          points += 1; // 风牌刻子
        } else if (meld.first.isJian) {
          points += 2; // 箭牌刻子
        }
      }
      if (meld.length == 4) {
        // 明杠
        if (meld.first.isFeng) {
          points += 2; // 风牌杠
        } else if (meld.first.isJian) {
          points += 3; // 箭牌杠
        } else {
          points += 1; // 其他牌杠
        }
      }
    }
    
    // 暗杠
    for (final meld in player.concealedMelds) {
      if (meld.length == 4) {
        if (meld.first.isFeng) {
          points += 2 + 1; // 风牌杠 + 暗杠
        } else if (meld.first.isJian) {
          points += 3 + 1; // 箭牌杠 + 暗杠
        } else {
          points += 1 + 1; // 其他牌杠 + 暗杠
        }
      }
    }
    
    return points;
  }

  bool hasWildTile(Player player) {
    final target = wildTile;
    if (target == null) return false;
    return player.handTiles.any((tile) => tile.type == target.type);
  }

  void recordChow(Player receiver, Player source) {
    final key = '${receiver.id}_${source.id}_chow';
    _chowPong[key] = (_chowPong[key] ?? 0) + 1;
  }

  void recordPong(Player receiver, Player source) {
    final key = '${receiver.id}_${source.id}_pong';
    _chowPong[key] = (_chowPong[key] ?? 0) + 1;
  }

  int getChowPongCount(Player receiver, Player source) {
    final chow = _chowPong['${receiver.id}_${source.id}_chow'] ?? 0;
    final pong = _chowPong['${receiver.id}_${source.id}_pong'] ?? 0;
    return chow + pong;
  }

  void applyDrawMultiplier() {
    multiplier = min(multiplier * 2, 8);
  }

  bool shouldEndRound() => huPlayers.length >= 3 || isDraw;

  void playerHu(Player player) {
    if (!huPlayers.contains(player)) {
      huPlayers.add(player);
      
      // 记录胡牌日志
      if (_logger != null && _currentRoundId != null) {
        final huType = checkHuType(player);
        _logger!.logHu(
          roundId: _currentRoundId!,
          turnNumber: _turnNumber,
          playerId: player.id,
          winType: huType?.toString() ?? 'basic',
          isSelfDrawn: lastPlayedBy == player,
        );
      }
    }
  }

  Player? get loser => lastPlayedBy;

  List<Tile> _buildCandidateHand(Player player, {Tile? newTile}) {
    final hand = List<Tile>.from(player.handTiles.where((tile) => !tile.isHua));
    if (newTile != null && !_containsTile(hand, newTile)) {
      hand.add(newTile);
    }
    return hand;
  }

  bool _containsTile(List<Tile> tiles, Tile target) {
    return tiles.any((tile) => tile.id == target.id);
  }

  bool _isWinningHand(List<Tile> tiles) {
    if (tiles.length % 3 != 2 || tiles.isEmpty) return false;
    if (_isShiSanYao(tiles)) return true;
    return _isStandardWinningHand(tiles);
  }

  bool _isStandardWinningHand(List<Tile> tiles) {
    final counts = <TileType, int>{};
    for (final tile in tiles) {
      counts[tile.type] = (counts[tile.type] ?? 0) + 1;
    }

    for (final entry in counts.entries) {
      if (entry.value < 2) continue;
      final nextCounts = Map<TileType, int>.from(counts);
      nextCounts[entry.key] = entry.value - 2;
      if (_canFormMelds(nextCounts)) {
        return true;
      }
    }

    return false;
  }

  bool _canFormMelds(Map<TileType, int> counts) {
    TileType? firstType;
    for (final type in TileType.values) {
      if ((counts[type] ?? 0) > 0) {
        firstType = type;
        break;
      }
    }

    if (firstType == null) return true;

    final currentCount = counts[firstType] ?? 0;
    if (currentCount >= 3) {
      final tripletCounts = Map<TileType, int>.from(counts);
      tripletCounts[firstType] = currentCount - 3;
      if (_canFormMelds(tripletCounts)) {
        return true;
      }
    }

    if (_isSuitTile(firstType)) {
      final second = _offsetSuitType(firstType, 1);
      final third = _offsetSuitType(firstType, 2);
      if (second != null && third != null) {
        final secondCount = counts[second] ?? 0;
        final thirdCount = counts[third] ?? 0;
        if (secondCount > 0 && thirdCount > 0) {
          final sequenceCounts = Map<TileType, int>.from(counts);
          sequenceCounts[firstType] = currentCount - 1;
          sequenceCounts[second] = secondCount - 1;
          sequenceCounts[third] = thirdCount - 1;
          if (_canFormMelds(sequenceCounts)) {
            return true;
          }
        }
      }
    }

    return false;
  }

  bool _isSuitTile(TileType type) => type.index >= 0 && type.index <= 26;

  TileType? _offsetSuitType(TileType type, int delta) {
    if (!_isSuitTile(type)) return null;

    final baseIndex = (type.index ~/ 9) * 9;
    final number = (type.index % 9) + 1;
    final nextNumber = number + delta;
    if (nextNumber < 1 || nextNumber > 9) return null;

    return TileType.values[baseIndex + nextNumber - 1];
  }

  bool _isPongPongHu(List<Tile> tiles) {
    final counts = <TileType, int>{};
    for (final tile in tiles) {
      counts[tile.type] = (counts[tile.type] ?? 0) + 1;
    }

    int pairCount = 0;
    for (final count in counts.values) {
      if (count == 2) {
        pairCount += 1;
      } else if (count != 3 && count != 4) {
        return false;
      }
    }

    return pairCount == 1;
  }

  bool _isShiSanYao(List<Tile> tiles) {
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

  // ========== 新增功能 ==========

  /// 检测玩家是否满足五毒散牌型（造反牌型）
  /// 条件：筒子、万子、条子、风牌、箭牌五门都有，无花牌，无百搭，无对子
  bool checkRebellion(Player player) {
    return player.isWuDuSan(wildTile: wildTile);
  }

  /// 执行造反
  void rebel(Player rebel) {
    // 下回合翻倍
    multiplier = min(multiplier * 2, 8);
    // 造反人成为庄家
    nextDealerIndex = players.indexOf(rebel);
    // 结束此局
    gameState = GameState.ended;
  }

  /// 检查玩家是否可以吃上家的牌
  bool canChowFromUploader(Player player) {
    if (lastPlayedBy == null) return false;
    final playerIndex = players.indexOf(player);
    final uploaderIndex = players.indexOf(lastPlayedBy!);
    // 吃牌只能吃上家
    return (playerIndex + 1) % 4 == uploaderIndex;
  }

  /// 计算包牌倍数
  /// 返回值：1=无包牌, 3=包三家, 5=包四家
  int calculateBaoMultiplier(Player winner, Player loser) {
    final count = getChowPongCount(winner, loser);
    if (count >= 4) return 5; // 包四家
    if (count >= 3) return 3; // 包三家
    return 1;
  }

  /// 检查是否是清一色（手牌和门口牌只有一种数牌花色）
  bool isQingYiSe(Player player, {Tile? newTile}) {
    final hand = _buildCandidateHand(player, newTile: newTile);
    final melds = player.allMelds;
    
    // 检查手牌
    TileSuit? suit;
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
    for (final meld in melds) {
      for (final tile in meld) {
        if (tile.isHua) continue; // 忽略花牌
        if (!tile.isXuPai) continue; // 忽略字牌
        if (suit == null) {
          suit = tile.suit;
        } else if (tile.suit != suit) {
          return false;
        }
      }
    }
    
    return suit != null;
  }

  /// 检查是否是混一色（一种数牌 + 风牌对子/刻子）
  bool isHunYiSe(Player player, {Tile? newTile}) {
    final hand = _buildCandidateHand(player, newTile: newTile);
    return TileTypeDetector.isHunYiSe(hand, player.exposedMelds);
  }

  /// 检查是否是风一色
  bool isFengYiSe(Player player, {Tile? newTile}) {
    final hand = _buildCandidateHand(player, newTile: newTile);
    return TileTypeDetector.isFengYiSe(hand, player.exposedMelds);
  }

  /// 检查是否是风碰
  bool isFengPon(Player player, {Tile? newTile}) {
    final hand = _buildCandidateHand(player, newTile: newTile);
    return TileTypeDetector.isFengPon(hand, player.exposedMelds);
  }

  /// 检查是否是对对胡
  bool isDuiDuiHu(Player player, {Tile? newTile}) {
    final hand = _buildCandidateHand(player, newTile: newTile);
    return TileTypeDetector.isDuiDuiHu(hand, player.exposedMelds);
  }

  /// 检查是否为五毒散（造反牌型）
  bool isWuDuSan(Player player) {
    return TileTypeDetector.isWuDuSan(player.handTiles, wildTile: wildTile);
  }

  /// 检查是否为十三幺
  bool isShiSanYao(Player player, {Tile? newTile}) {
    final hand = _buildCandidateHand(player, newTile: newTile);
    return TileTypeDetector.isShiSanYao(hand);
  }

  /// 是否为碰碰胡
  bool isPongPongHu(Player player, {Tile? newTile}) {
    final hand = _buildCandidateHand(player, newTile: newTile);
    return TileTypeDetector.isPongPongHu(hand);
  }

  // ===== 以下为旧的私有方法，已移到TileTypeDetector =====

  bool _isPongPongHu(List<Tile> tiles) {
    return TileTypeDetector.isPongPongHu(tiles);
  }

  bool _isShiSanYao(List<Tile> tiles) {
    return TileTypeDetector.isShiSanYao(tiles);
  }
    final hand = _buildCandidateHand(player, newTile: newTile);
    final melds = player.allMelds;
    
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
          return false; // 有多种数牌花色
        }
      }
    }
    
    // 检查门口牌（必须有风牌的对子或刻子）
    for (final meld in melds) {
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

  /// 检查是否是风一色（全是风向牌）
  bool isFengYiSe(Player player, {Tile? newTile}) {
    final hand = _buildCandidateHand(player, newTile: newTile);
    final melds = player.allMelds;
    
    // 检查手牌
    for (final tile in hand) {
      if (tile.isHua) continue;
      if (!tile.isFeng) return false;
    }
    
    // 检查门口牌
    for (final meld in melds) {
      for (final tile in meld) {
        if (tile.isHua) continue;
        if (!tile.isFeng) return false;
      }
    }
    
    return true;
  }

  /// 检查是否是风碰（风一色 + 全部是对子或刻子）
  bool isFengPon(Player player, {Tile? newTile}) {
    if (!isFengYiSe(player, newTile: newTile)) return false;
    
    final melds = player.allMelds;
    
    // 门口牌必须全是对子或刻子
    for (final meld in melds) {
      if (meld.length == 3) {
        // 刻子
        if (!meld[0].isFeng) return false;
      }
    }
    
    // 检查手牌是否全是对子或刻子（无顺子）
    final hand = _buildCandidateHand(player, newTile: newTile);
    return _isPongPongHu(hand);
  }

  /// 检查是否是对对胡（只有刻子、对子、杠牌，以及花牌）
  bool isDuiDuiHu(Player player, {Tile? newTile}) {
    final hand = _buildCandidateHand(player, newTile: newTile);
    final melds = player.allMelds;
    
    // 手牌必须符合碰碰胡结构（全刻子/对子）
    if (!_isPongPongHu(hand)) return false;
    
    // 门口牌必须全是对子或刻子或杠
    for (final meld in melds) {
      if (meld.length == 3) {
        // 刻子 - OK
      } else if (meld.length == 4) {
        // 杠 - OK
      } else {
        return false;
      }
    }
    
    return true;
  }

  /// 检查是否是无花自摸
  /// 条件：碰碰胡或混一色，自摸胡牌，门口无花牌，手牌无风向刻子/杠
  bool isNoFlowerSelfDraw(Player player) {
    // 门口没有花牌
    if (player.hasFlowers) return false;
    
    // 手牌没有风向刻子或杠
    if (player.hasFengKeOrGang) return false;
    
    // 牌型必须是碰碰胡或混一色
    final huType = checkHuType(player);
    return huType == HuType.pongPongHu || huType == HuType.hunYiSe;
  }

  /// 完善胡牌类型检测（按优先级）
  HuType? checkHuType(Player player, {Tile? newTile}) {
    final hand = _buildCandidateHand(player, newTile: newTile);
    if (!HuJudge.canHu(hand)) return null;
    
    // 使用TileTypeDetector检测最佳牌型
    return TileTypeDetector.getBestHuType(hand, player.exposedMelds, newTile: newTile);
  }

  /// 计算固定点数牌型
  int getFixedPoints(HuType huType, {bool isSelfDrawn = false, bool isNoFlowerSelfDraw = false}) {
    switch (huType) {
      case HuType.qingYiSe:
        return 10;
      case HuType.fengYiSe:
        return 20;
      case HuType.fengPon:
        return 40;
      case HuType.qingPon:
        return 40;
      default:
        if (isNoFlowerSelfDraw && isSelfDrawn) {
          return 10; // 无花自摸
        }
        return 0;
    }
  }

  /// 计算杠开点数
  int getKaiGangPoints(bool isKaiGang) {
    return isKaiGang ? 10 : 0;
  }
}
