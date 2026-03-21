/// 游戏配置
class GameConfig {
  /// 服务器地址（多人联机用）
  static const String serverUrl = 'ws://localhost:8080';
  
  /// 数据库配置
  static const DbConfig db = DbConfig(
    host: '192.168.3.241',
    port: 33061,
    user: 'openclaw',
    password: '0penC1aw',
    database: 'changqingge',
  );
  
  /// 游戏规则配置
  static const GameRules rules = GameRules(
    playerCount: 4,
    tileCount: 144,
    dealerTiles: 14,
    playerTiles: 13,
    maxHuPlayers: 3, // 血战到底
  );
  
  /// 动画配置
  static const AnimationConfig animation = AnimationConfig(
    diceDuration: 400, // 毫秒
    dealDuration: 800,
    discardDelay: 500,
  );
  
  /// UI配置
  static const UIConfig ui = UIConfig(
    tileWidth: 30.0,
    tileHeight: 40.0,
    playerAvatarSize: 50.0,
  );
}

/// 数据库配置
class DbConfig {
  final String host;
  final int port;
  final String user;
  final String password;
  final String database;
  
  const DbConfig({
    required this.host,
    required this.port,
    required this.user,
    required this.password,
    required this.database,
  });
}

/// 游戏规则配置
class GameRules {
  final int playerCount;
  final int tileCount;
  final int dealerTiles;
  final int playerTiles;
  final int maxHuPlayers;
  
  const GameRules({
    required this.playerCount,
    required this.tileCount,
    required this.dealerTiles,
    required this.playerTiles,
    required this.maxHuPlayers,
  });
}

/// 动画配置
class AnimationConfig {
  final int diceDuration;
  final int dealDuration;
  final int discardDelay;
  
  const AnimationConfig({
    required this.diceDuration,
    required this.dealDuration,
    required this.discardDelay,
  });
}

/// UI配置
class UIConfig {
  final double tileWidth;
  final double tileHeight;
  final double playerAvatarSize;
  
  const UIConfig({
    required this.tileWidth,
    required this.tileHeight,
    required this.playerAvatarSize,
  });
}
