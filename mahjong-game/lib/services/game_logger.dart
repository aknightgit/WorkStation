import 'dart:convert';
import 'package:mysql1/mysql1.dart';

/// 游戏日志服务 - 记录所有牌局数据
/// 包含错误处理和重试机制
class GameLogger {
  static GameLogger? _instance;
  MySqlConnection? _conn;
  bool _isConnected = false;
  final List<Map<String, dynamic>> _pendingLogs = []; // 待重试队列
  
  GameLogger._();
  
  static Future<GameLogger> getInstance() async {
    if (_instance == null) {
      _instance = GameLogger._();
      await _instance!._init();
    }
    return _instance!;
  }
  
  bool get isConnected => _isConnected;
  
  Future<void> _init() async {
    try {
      _conn = await MySqlConnection.connect(ConnectionSettings(
        host: '192.168.3.241',
        port: 33061,
        user: 'openclaw',
        password: '0penC1aw',
        db: 'changqingge',
      ));
      _isConnected = true;
    } catch (e) {
      _isConnected = false;
      print('[GameLogger] 数据库连接失败: $e');
    }
  }
  
  /// 重连机制
  Future<bool> reconnect() async {
    try {
      await _conn?.close();
      await _init();
      return _isConnected;
    } catch (e) {
      print('[GameLogger] 重连失败: $e');
      return false;
    }
  }
  
  /// 带重试的日志记录
  Future<void> logWithRetry(Map<String, dynamic> logData) async {
    if (!_isConnected) {
      _pendingLogs.add(logData); // 加入待重试队列
      return;
    }
    
    try {
      // 执行日志记录
      await _executeLog(logData);
    } catch (e) {
      print('[GameLogger] 日志记录失败: $e');
      _pendingLogs.add(logData); // 加入待重试队列
      _isConnected = false;
      // 尝试重连
      await reconnect();
    }
  }
  
  Future<void> _executeLog(Map<String, dynamic> logData) async {
    // 具体执行逻辑
    // ...
  }
  
  /// 处理待重试队列
  Future<void> processPendingLogs() async {
    if (!_isConnected || _pendingLogs.isEmpty) return;
    
    final logs = List<Map<String, dynamic>>.from(_pendingLogs);
    _pendingLogs.clear();
    
    for (final log in logs) {
      await logWithRetry(log);
    }
  }
  
  // ========== 玩家相关 ==========
  
  /// 获取或创建玩家
  Future<int> getOrCreatePlayer(String name, {String? displayName, String? avatarColor}) async {
    final conn = _conn!;
    
    // 查找已存在玩家
    final result = await conn.query(
      'SELECT id FROM players WHERE name = ?',
      [name],
    );
    
    if (result.isNotEmpty) {
      return result.first['id'] as int;
    }
    
    // 创建新玩家
    await conn.query(
      'INSERT INTO players (name, display_name, avatar_color) VALUES (?, ?, ?)',
      [name, displayName ?? name, avatarColor ?? 'blue'],
    );
    
    final lastId = await conn.query('SELECT LAST_INSERT_ID() as id');
    return lastId.first['id'] as int;
  }
  
  /// 获取玩家列表
  Future<List<Map<String, dynamic>>> getPlayers() async {
    final conn = _conn!;
    final result = await conn.query('SELECT * FROM players ORDER BY id');
    return result.map((row) => row.fields).toList();
  }
  
  /// 获取玩家ID映射
  Future<Map<String, int>> getPlayerNameToId() async {
    final conn = _conn!;
    final result = await conn.query('SELECT id, name FROM players');
    return {for (var row in result) row['name'] as String: row['id'] as int};
  }
  
  /// 获取玩家ID
  Future<int?> getPlayerId(String name) async {
    final conn = _conn!;
    final result = await conn.query('SELECT id FROM players WHERE name = ?', [name]);
    return result.isNotEmpty ? result.first['id'] as int : null;
  }
  
  // ========== 游戏局次 ==========
  
  /// 创建新局次
  Future<int> createGameRound({
    required int roundNumber,
    required int? dealerId,
    required String diceValues,
    required int roundMultiplier,
    required int globalMultiplier,
  }) async {
    final conn = _conn!;
    await conn.query(
      '''INSERT INTO game_rounds 
         (round_number, dealer_id, dice_values, round_multiplier, global_multiplier) 
         VALUES (?, ?, ?, ?, ?)''',
      [roundNumber, dealerId, diceValues, roundMultiplier, globalMultiplier],
    );
    final lastId = await conn.query('SELECT LAST_INSERT_ID() as id');
    return lastId.first['id'] as int;
  }
  
  /// 更新局次结果
  Future<void> updateGameRound({
    required int roundId,
    int? winnerId,
    String? winType,
    bool? isSelfDrawn,
    bool? isFlow,
    bool? isRebellion,
    int? basePoints,
    int? totalPot,
  }) async {
    final conn = _conn!;
    final updates = <String>[];
    final args = <dynamic>[];
    
    if (winnerId != null) { updates.add('winner_id = ?'); args.add(winnerId); }
    if (winType != null) { updates.add('win_type = ?'); args.add(winType); }
    if (isSelfDrawn != null) { updates.add('is_self_drawn = ?'); args.add(isSelfDrawn ? 1 : 0); }
    if (isFlow != null) { updates.add('is_flow = ?'); args.add(isFlow ? 1 : 0); }
    if (isRebellion != null) { updates.add('is_rebellion = ?'); args.add(isRebellion ? 1 : 0); }
    if (basePoints != null) { updates.add('base_points = ?'); args.add(basePoints); }
    if (totalPot != null) { updates.add('total_pot = ?'); args.add(totalPot); }
    
    updates.add('end_time = NOW()');
    args.add(roundId);
    
    await conn.query('UPDATE game_rounds SET ${updates.join(', ')} WHERE id = ?', args);
  }
  
  /// 获取局次详情
  Future<Map<String, dynamic>?> getGameRound(int roundId) async {
    final conn = _conn!;
    final result = await conn.query('SELECT * FROM game_rounds WHERE id = ?', [roundId]);
    return result.isNotEmpty ? result.first.fields : null;
  }
  
  // ========== 回合动作 ==========
  
  /// 记录回合动作
  Future<int> logAction({
    required int roundId,
    required int turnNumber,
    required int playerId,
    required String actionType,
    String? tileType,
    String? tileSuit,
    int? tileNumber,
    bool isConcealed = false,
    int? targetPlayerId,
    int? fromPlayerId,
    int pointsChange = 0,
  }) async {
    final conn = _conn!;
    await conn.query(
      '''INSERT INTO round_actions 
         (round_id, turn_number, player_id, action_type, tile_type, tile_suit, tile_number, is_concealed, target_player_id, from_player_id, points_change) 
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)''',
      [roundId, turnNumber, playerId, actionType, tileType, tileSuit, tileNumber, isConcealed ? 1 : 0, targetPlayerId, fromPlayerId, pointsChange],
    );
    final lastId = await conn.query('SELECT LAST_INSERT_ID() as id');
    return lastId.first['id'] as int;
  }
  
  /// 记录摸牌
  Future<int> logDraw({
    required int roundId,
    required int turnNumber,
    required int playerId,
    required String tileType,
  }) async {
    final parts = tileType.replaceAll('TileType.', '').split('_');
    String? suit;
    int? num;
    if (parts.length > 1) {
      suit = parts[0];
      num = int.tryParse(parts[1]);
    }
    return logAction(
      roundId: roundId,
      turnNumber: turnNumber,
      playerId: playerId,
      actionType: 'draw',
      tileType: tileType,
      tileSuit: suit,
      tileNumber: num,
    );
  }
  
  /// 记录打牌
  Future<int> logDiscard({
    required int roundId,
    required int turnNumber,
    required int playerId,
    required String tileType,
  }) async {
    final parts = tileType.replaceAll('TileType.', '').split('_');
    String? suit;
    int? num;
    if (parts.length > 1) {
      suit = parts[0];
      num = int.tryParse(parts[1]);
    }
    return logAction(
      roundId: roundId,
      turnNumber: turnNumber,
      playerId: playerId,
      actionType: 'discard',
      tileType: tileType,
      tileSuit: suit,
      tileNumber: num,
    );
  }
  
  /// 记录吃牌
  Future<int> logChow({
    required int roundId,
    required int turnNumber,
    required int playerId,
    required String tileType,
    required int fromPlayerId,
  }) async {
    final parts = tileType.replaceAll('TileType.', '').split('_');
    String? suit;
    int? num;
    if (parts.length > 1) {
      suit = parts[0];
      num = int.tryParse(parts[1]);
    }
    return logAction(
      roundId: roundId,
      turnNumber: turnNumber,
      playerId: playerId,
      actionType: 'chow',
      tileType: tileType,
      tileSuit: suit,
      tileNumber: num,
      fromPlayerId: fromPlayerId,
    );
  }
  
  /// 记录碰牌
  Future<int> logPong({
    required int roundId,
    required int turnNumber,
    required int playerId,
    required String tileType,
    required int fromPlayerId,
  }) async {
    final parts = tileType.replaceAll('TileType.', '').split('_');
    String? suit;
    int? num;
    if (parts.length > 1) {
      suit = parts[0];
      num = int.tryParse(parts[1]);
    }
    return logAction(
      roundId: roundId,
      turnNumber: turnNumber,
      playerId: playerId,
      actionType: 'pong',
      tileType: tileType,
      tileSuit: suit,
      tileNumber: num,
      fromPlayerId: fromPlayerId,
    );
  }
  
  /// 记录明杠
  Future<int> logExposedKong({
    required int roundId,
    required int turnNumber,
    required int playerId,
    required String tileType,
    int? fromPlayerId,
  }) async {
    final parts = tileType.replaceAll('TileType.', '').split('_');
    String? suit;
    int? num;
    if (parts.length > 1) {
      suit = parts[0];
      num = int.tryParse(parts[1]);
    }
    return logAction(
      roundId: roundId,
      turnNumber: turnNumber,
      playerId: playerId,
      actionType: 'exposed_kong',
      tileType: tileType,
      tileSuit: suit,
      tileNumber: num,
      fromPlayerId: fromPlayerId,
    );
  }
  
  /// 记录暗杠
  Future<int> logHiddenKong({
    required int roundId,
    required int turnNumber,
    required int playerId,
    required String tileType,
  }) async {
    final parts = tileType.replaceAll('TileType.', '').split('_');
    String? suit;
    int? num;
    if (parts.length > 1) {
      suit = parts[0];
      num = int.tryParse(parts[1]);
    }
    return logAction(
      roundId: roundId,
      turnNumber: turnNumber,
      playerId: playerId,
      actionType: 'hidden_kong',
      tileType: tileType,
      tileSuit: suit,
      tileNumber: num,
      isConcealed: true,
    );
  }
  
  /// 记录胡牌
  Future<int> logHu({
    required int roundId,
    required int turnNumber,
    required int playerId,
    required String winType,
    bool isSelfDrawn = false,
  }) async {
    return logAction(
      roundId: roundId,
      turnNumber: turnNumber,
      playerId: playerId,
      actionType: 'hu',
      tileType: winType,
      pointsChange: 1,
    );
  }
  
  // ========== 结算记录 ==========
  
  /// 记录结算
  Future<void> logSettlement({
    required int roundId,
    required int playerId,
    required int basePoints,
    required int multiplier,
    required int baoMultiplier,
    required int finalPoints,
    bool isWinner = false,
    bool isPayer = false,
    int? paymentToPlayerId,
  }) async {
    final conn = _conn!;
    await conn.query(
      '''INSERT INTO round_settlements 
         (round_id, player_id, base_points, multiplier, bao_multiplier, final_points, is_winner, is_payer, payment_to_player_id) 
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)''',
      [roundId, playerId, basePoints, multiplier, baoMultiplier, finalPoints, isWinner ? 1 : 0, isPayer ? 1 : 0, paymentToPlayerId],
    );
  }
  
  // ========== 手牌快照 ==========
  
  /// 记录手牌快照
  Future<void> logHandSnapshot({
    required int roundId,
    int? turnNumber,
    required int playerId,
    required List<String> handTileTypes,
    List<List<String>>? exposedMelds,
    List<String>? concealedMelds,
    List<String>? flowerTiles,
    bool isTenpai = false,
  }) async {
    final conn = _conn!;
    await conn.query(
      '''INSERT INTO hand_snapshots 
         (round_id, turn_number, player_id, hand_tiles, exposed_melds, concealed_melds, flower_tiles, is_tenpai) 
         VALUES (?, ?, ?, ?, ?, ?, ?, ?)''',
      [
        roundId, 
        turnNumber, 
        playerId, 
        jsonEncode(handTileTypes), 
        exposedMelds != null ? jsonEncode(exposedMelds) : null,
        concealedMelds != null ? jsonEncode(concealedMelds) : null,
        flowerTiles != null ? jsonEncode(flowerTiles) : null,
        isTenpai ? 1 : 0,
      ],
    );
  }
  
  // ========== 玩家分数 ==========
  
  /// 更新玩家分数
  Future<void> updatePlayerScore({
    required int playerId,
    required DateTime gameDate,
    required int pointsChange,
    required bool isWin,
    required bool isLoss,
    required bool isDraw,
  }) async {
    final conn = _conn!;
    final dateStr = gameDate.toIso8601String().split('T')[0];
    
    // 检查当日记录是否存在
    final existing = await conn.query(
      'SELECT id FROM player_scores WHERE player_id = ? AND game_date = ?',
      [playerId, dateStr],
    );
    
    if (existing.isEmpty) {
      // 创建新记录
      await conn.query(
        '''INSERT INTO player_scores 
           (player_id, game_date, total_points, total_games, total_wins, total_losses, total_draws) 
           VALUES (?, ?, ?, 1, ?, ?, ?)''',
        [playerId, dateStr, pointsChange, isWin ? 1 : 0, isLoss ? 1 : 0, isDraw ? 1 : 0],
      );
    } else {
      // 更新现有记录
      final setClause = <String>[];
      final args = <dynamic>[];
      
      if (isWin) setClause.add('total_wins = total_wins + 1');
      if (isLoss) setClause.add('total_losses = total_losses + 1');
      if (isDraw) setClause.add('total_draws = total_draws + 1');
      
      setClause.add('total_points = total_points + ?');
      args.add(pointsChange);
      setClause.add('total_games = total_games + 1');
      
      args.add(playerId);
      args.add(dateStr);
      
      await conn.query(
        'UPDATE player_scores SET ${setClause.join(', ')} WHERE player_id = ? AND game_date = ?',
        args,
      );
    }
  }
  
  // ========== 查询接口 ==========
  
  /// 获取玩家历史动作
  Future<List<Map<String, dynamic>>> getPlayerActions(int playerId, {int? limit}) async {
    final conn = _conn!;
    final result = await conn.query(
      '''
      SELECT ra.*, gr.round_number, p.name as player_name
      FROM round_actions ra
      JOIN game_rounds gr ON ra.round_id = gr.id
      JOIN players p ON ra.player_id = p.id
      WHERE ra.player_id = ?
      ORDER BY ra.id DESC
      ${limit != null ? 'LIMIT $limit' : ''}
      ''',
      [playerId],
    );
    return result.map((row) => row.fields).toList();
  }
  
  /// 获取玩家历史胡牌记录
  Future<List<Map<String, dynamic>>> getPlayerHuHistory(int playerId, {int? limit}) async {
    final conn = _conn!;
    final result = await conn.query(
      '''
      SELECT ra.*, gr.round_number, gr.win_type, gr.is_self_drawn
      FROM round_actions ra
      JOIN game_rounds gr ON ra.round_id = gr.id
      WHERE ra.player_id = ? AND ra.action_type = 'hu'
      ORDER BY ra.id DESC
      ${limit != null ? 'LIMIT $limit' : ''}
      ''',
      [playerId],
    );
    return result.map((row) => row.fields).toList();
  }
  
  /// 获取玩家历史出牌记录
  Future<List<Map<String, dynamic>>> getPlayerDiscardHistory(int playerId, {int? limit}) async {
    final conn = _conn!;
    final result = await conn.query(
      '''
      SELECT ra.*, gr.round_number
      FROM round_actions ra
      JOIN game_rounds gr ON ra.round_id = gr.id
      WHERE ra.player_id = ? AND ra.action_type = 'discard'
      ORDER BY ra.id DESC
      ${limit != null ? 'LIMIT $limit' : ''}
      ''',
      [playerId],
    );
    return result.map((row) => row.fields).toList();
  }
  
  /// 获取玩家成绩统计
  Future<Map<String, dynamic>> getPlayerStats(int playerId) async {
    final conn = _conn!;
    final result = await conn.query(
      '''
      SELECT 
        COALESCE(SUM(total_points), 0) as total_points,
        COALESCE(SUM(total_games), 0) as total_games,
        COALESCE(SUM(total_wins), 0) as total_wins,
        COALESCE(SUM(total_losses), 0) as total_losses,
        COALESCE(SUM(total_draws), 0) as total_draws
      FROM player_scores
      WHERE player_id = ?
      ''',
      [playerId],
    );
    return result.first.fields;
  }
  
  /// 获取历史局次列表
  Future<List<Map<String, dynamic>>> getGameHistory({int limit = 20}) async {
    final conn = _conn!;
    final result = await conn.query(
      '''
      SELECT gr.*, 
             w.name as winner_name,
             d.name as dealer_name
      FROM game_rounds gr
      LEFT JOIN players w ON gr.winner_id = w.id
      LEFT JOIN players d ON gr.dealer_id = d.id
      ORDER BY gr.id DESC
      LIMIT ?
      ''',
      [limit],
    );
    return result.map((row) => row.fields).toList();
  }
  
  /// 获取某局所有动作
  Future<List<Map<String, dynamic>>> getRoundActions(int roundId) async {
    final conn = _conn!;
    final result = await conn.query(
      '''
      SELECT ra.*, p.name as player_name
      FROM round_actions ra
      JOIN players p ON ra.player_id = p.id
      WHERE ra.round_id = ?
      ORDER BY ra.turn_number, ra.id
      ''',
      [roundId],
    );
    return result.map((row) => row.fields).toList();
  }
  
  /// 关闭连接
  Future<void> close() async {
    await _conn?.close();
  }
}
