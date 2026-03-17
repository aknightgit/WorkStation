import 'dart:math';
import '../models/tile_model.dart';
import '../models/player_model.dart';

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

    _createAllTiles();
    shuffleTiles();
    _initPlayers();
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
        return null;
      }

      final tile = tiles[wallIndex++];
      if (tile.isHua) {
        player.drawFlowerTile(tile);
        continue;
      }

      player.addTile(tile);
      return tile;
    }
  }

  void playTile(Player player, Tile tile) {
    player.removeTile(tile);
    player.playedTiles.add(tile);
    lastPlayedTile = tile;
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
        return meld;
      }
    }
    return null;
  }

  bool canHu(Player player, {Tile? newTile, bool isSelfDrawn = false}) {
    final hand = _buildCandidateHand(player, newTile: newTile);
    return _isWinningHand(hand);
  }

  HuType? checkHuType(Player player, {Tile? newTile}) {
    final hand = _buildCandidateHand(player, newTile: newTile);
    if (!_isWinningHand(hand)) return null;
    if (_isShiSanYao(hand)) return HuType.shiSanYao;
    if (_isPongPongHu(hand)) return HuType.pongPongHu;
    return HuType.basic;
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
  }) {
    final huType = checkHuType(winner, newTile: huTile) ?? HuType.basic;
    int basePoints = 2;
    if (huType == HuType.pongPongHu) basePoints = 4;
    if (huType == HuType.shiSanYao) basePoints = 8;
    if (isKaiGang) basePoints += 2;
    if (isSelfDrawn) basePoints += 1;

    final totalPoints = basePoints * roundMultiplier * multiplier;
    final payments = <Player, int>{};

    if (isSelfDrawn) {
      for (final player in players) {
        if (player != winner) {
          payments[player] = totalPoints;
        }
      }
    } else if (lastPlayedBy != null && lastPlayedBy != winner) {
      payments[lastPlayedBy!] = totalPoints;
    }

    return SettlementResult(
      winner: winner,
      huType: huType,
      basePoints: basePoints,
      totalPoints: totalPoints,
      payments: payments,
    );
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
}
