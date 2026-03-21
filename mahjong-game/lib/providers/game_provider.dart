import 'package:flutter/foundation.dart';
import '../models/tile_model.dart';
import '../models/player_model.dart';
import '../game_logic/mahjong_game.dart';
import '../services/game_logger.dart';

/// 游戏状态Provider - 管理所有游戏状态
class GameProvider extends ChangeNotifier {
  final MahjongGame _game = MahjongGame();
  GameLogger? _logger;
  
  // UI状态
  bool _isRollingDice = false;
  bool _isDealing = false;
  bool _hasDealt = false;
  int _diceClickCount = 0;
  int _currentPlayerIndex = 0;
  Tile? _lastDrawnTile;
  Tile? _pendingTile;
  Player? _pendingNextPlayerIndex;
  
  // 回合数
  int _turnNumber = 0;
  
  // 局次数
  int _roundNumber = 0;
  
  // ========== Getter ==========
  
  MahjongGame get game => _game;
  bool get isRollingDice => _isRollingDice;
  bool get isDealing => _isDealing;
  bool get hasDealt => _hasDealt;
  int get diceClickCount => _diceClickCount;
  int get currentPlayerIndex => _currentPlayerIndex;
  Tile? get lastDrawnTile => _lastDrawnTile;
  Tile? get pendingTile => _pendingTile;
  int get turnNumber => _turnNumber;
  int get roundNumber => _roundNumber;
  Player get currentPlayer => _game.players[_currentPlayerIndex];
  
  // 获取所有玩家
  List<Player> get players => _game.players;
  
  // 获取庄家
  int get dealerIndex => _game.dealerIndex;
  
  // 获取骰子值
  List<int> get diceValues => _game.diceValues;
  
  // 获取倍数
  int get roundMultiplier => _game.roundMultiplier;
  int get globalMultiplier => _game.multiplier;
  
  // 获取游戏状态
  GameState get gameState => _game.gameState;
  
  // 获取当前玩家手牌
  List<Tile> get myHandTiles => _game.players[0].handTiles;
  
  // 获取当前玩家门口牌
  List<List<Tile>> get myExposedMelds => _game.players[0].exposedMelds;
  
  // ========== 初始化 ==========
  
  /// 设置日志服务
  Future<void> setLogger(GameLogger logger) async {
    _logger = logger;
    _game.setLogger(logger);
    await _game.initLogger();
    notifyListeners();
  }
  
  /// 初始化游戏
  void initGame() {
    _game.initGame();
    _roundNumber = 0;
    _turnNumber = 0;
    _currentPlayerIndex = 0;
    _isRollingDice = false;
    _isDealing = false;
    _hasDealt = false;
    _diceClickCount = 0;
    notifyListeners();
  }
  
  /// 开始新局
  void startNewRound() {
    _roundNumber++;
    _turnNumber = 0;
    _currentPlayerIndex = _game.dealerIndex;
    _isRollingDice = true;
    _isDealing = false;
    _hasDealt = false;
    _diceClickCount = 0;
    
    // 创建局次记录
    _game.createRoundRecord(_roundNumber);
    
    notifyListeners();
  }
  
  // ========== 掷骰子 ==========
  
  void setRollingDice(bool value) {
    _isRollingDice = value;
    notifyListeners();
  }
  
  void incrementDiceClick() {
    _diceClickCount++;
    notifyListeners();
  }
  
  void resetDiceClick() {
    _diceClickCount = 0;
    notifyListeners();
  }
  
  void rollDice() {
    _game.rollDice();
    notifyListeners();
  }
  
  // ========== 发牌 ==========
  
  void setDealing(bool value) {
    _isDealing = value;
    notifyListeners();
  }
  
  void startRound() {
    _game.startRound();
    _hasDealt = true;
    _currentPlayerIndex = _game.dealerIndex;
    notifyListeners();
  }
  
  // ========== 回合操作 ==========
  
  /// 摸牌
  Tile? drawTile() {
    final player = _game.players[_currentPlayerIndex];
    final tile = _game.drawTile(player);
    if (tile != null) {
      _lastDrawnTile = tile;
      _game.incrementTurn();
      _turnNumber = _game._turnNumber;
    }
    notifyListeners();
    return tile;
  }
  
  /// 打牌
  void playTile(Tile tile) {
    final player = _game.players[_currentPlayerIndex];
    _game.playTile(player, tile);
    _pendingTile = tile;
    _currentPlayerIndex = (_currentPlayerIndex + 1) % 4;
    notifyListeners();
  }
  
  /// 吃牌
  List<Tile>? chow(Tile target) {
    final player = _game.players[_currentPlayerIndex];
    final result = _game.chow(player, target);
    if (result != null) {
      _pendingTile = null;
      notifyListeners();
    }
    return result;
  }
  
  /// 碰牌
  List<Tile>? pong(Tile target) {
    final player = _game.players[_currentPlayerIndex];
    final result = _game.pong(player, target);
    if (result != null) {
      _pendingTile = null;
      notifyListeners();
    }
    return result;
  }
  
  /// 明杠
  List<Tile>? exposedKong(Tile target) {
    final player = _game.players[_currentPlayerIndex];
    final result = _game.exposedKong(player, target);
    if (result != null) {
      _pendingTile = null;
      notifyListeners();
    }
    return result;
  }
  
  /// 暗杠
  List<Tile>? hiddenKong() {
    final player = _game.players[_currentPlayerIndex];
    final result = _game.hiddenKong(player);
    if (result != null) {
      notifyListeners();
    }
    return result;
  }
  
  /// 胡牌
  bool hu({Tile? huTile}) {
    final player = _game.players[_currentPlayerIndex];
    if (_game.canHu(player, newTile: huTile)) {
      _game.playerHu(player);
      
      // 记录结算
      final isSelfDrawn = _currentPlayerIndex == 0; // TODO: 改为实际判断
      final result = _game.calculateSettlement(player, huTile: huTile, isSelfDrawn: isSelfDrawn);
      if (result != null) {
        _game.recordSettlement(result, isSelfDrawn: isSelfDrawn);
      }
      
      notifyListeners();
      return true;
    }
    return false;
  }
  
  /// 跳过动作
  void skipAction() {
    _pendingTile = null;
    notifyListeners();
  }
  
  /// 吃碰杠后进入打牌阶段
  void proceedToDiscard() {
    _currentPlayerIndex = (_currentPlayerIndex + 1) % 4;
    notifyListeners();
  }
  
  // ========== 动作检测 ==========
  
  bool canChow(Tile target) => _game.canChow(_game.players[_currentPlayerIndex], target);
  bool canPong(Tile target) => _game.canPong(_game.players[_currentPlayerIndex], target);
  bool canExposedKong(Tile target) => _game.canExposedKong(_game.players[_currentPlayerIndex], target);
  bool canHiddenKong() => _game.canHiddenKong(_game.players[_currentPlayerIndex]);
  bool canHu({Tile? newTile}) => _game.canHu(_game.players[_currentPlayerIndex], newTile: newTile);
  
  // ========== 其他玩家动作检测 ==========
  
  bool canChowFromTarget(int playerIndex, Tile target) {
    final player = _game.players[playerIndex];
    return _game.canChow(player, target);
  }
  
  bool canPongFromTarget(int playerIndex, Tile target) {
    final player = _game.players[playerIndex];
    return _game.canPong(player, target);
  }
  
  bool canHuFromTarget(int playerIndex, {Tile? newTile}) {
    final player = _game.players[playerIndex];
    return _game.canHu(player, newTile: newTile);
  }
  
  // ========== 游戏结束检测 ==========
  
  bool shouldEndRound() => _game.shouldEndRound();
  bool get isDraw => _game.isDraw;
  List<Player> get huPlayers => _game.huPlayers;
  
  // ========== 结算 ==========
  
  SettlementResult? calculateSettlement(Player winner, {Tile? huTile, bool isSelfDrawn = false}) {
    return _game.calculateSettlement(winner, huTile: huTile, isSelfDrawn: isSelfDrawn);
  }
  
  // ========== 状态更新 ==========
  
  void updatePendingTile(Tile? tile) {
    _pendingTile = tile;
    notifyListeners();
  }
  
  void setCurrentPlayer(int index) {
    _currentPlayerIndex = index;
    notifyListeners();
  }
  
  /// 清除待处理牌
  void clearPendingTile() {
    _pendingTile = null;
    notifyListeners();
  }
  
  /// 重置摸牌
  void clearLastDrawnTile() {
    _lastDrawnTile = null;
    notifyListeners();
  }
}
