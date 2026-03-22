class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  // TODO: 连接到 Python REST API 或直接连接 MariaDB
  // 示例连接信息:
  // host: 192.168.3.241
  // port: 33061
  // user: openclaw
  // password: 0penC1aw
  // database: changqingge

  // 保存游戏结果
  Future<void> saveGameResult({
    required String gameId,
    required List<Map<String, dynamic>> players,
    required int winnerIndex,
    required int fan,
    required int baseScore,
    required int multiplier,
  }) async {
    // TODO: 实现数据库保存
    // 可用方案:
    // 1. Python Flask/FastAPI 后端 + REST API
    // 2. Dart mysql2 (需要 native 库)
    // 3. HTTP + JSON 存储服务
    print('Saving game result: $gameId');
    for (var p in players) {
      print('  ${p['name']}: ${p['score']}');
    }
  }

  // 获取排行榜
  Future<List<Map<String, dynamic>>> getLeaderboard({int limit = 10}) async {
    // TODO: 实现数据库查询
    return [
      {'player_id': 0, 'player_name': '东家', 'total_games': 0, 'total_wins': 0, 'total_score': 0},
      {'player_id': 1, 'player_name': '南家', 'total_games': 0, 'total_wins': 0, 'total_score': 0},
      {'player_id': 2, 'player_name': '西家', 'total_games': 0, 'total_wins': 0, 'total_score': 0},
      {'player_id': 3, 'player_name': '北家', 'total_games': 0, 'total_wins': 0, 'total_score': 0},
    ];
  }
}
