import 'package:flutter/foundation.dart';

/// 玩家连接状态
enum PlayerConnectionState {
  disconnected,
  connecting,
  connected,
  reconnecting,
}

/// 多人联机状态管理
class MultiplayerProvider extends ChangeNotifier {
  /// 当前房间信息
  String? _roomId;
  String? _roomName;
  int _maxPlayers = 4;
  int _currentPlayers = 0;
  String? _hostPlayerId;
  
  /// 玩家列表及连接状态
  final Map<int, PlayerConnectionState> _playerStates = {
    0: PlayerConnectionState.connected,
    1: PlayerConnectionState.disconnected,
    2: PlayerConnectionState.disconnected,
    3: PlayerConnectionState.disconnected,
  };
  
  /// 玩家ID映射（服务器分配的UUID）
  final Map<int, String?> _playerIds = {
    0: null,
    1: null,
    2: null,
    3: null,
  };

  // ========== Getter ==========
  
  String? get roomId => _roomId;
  String? get roomName => _roomName;
  int get maxPlayers => _maxPlayers;
  int get currentPlayers => _currentPlayers;
  String? get hostPlayerId => _hostPlayerId;
  
  PlayerConnectionState getPlayerState(int index) => _playerStates[index] ?? PlayerConnectionState.disconnected;
  String? getPlayerId(int index) => _playerIds[index];
  
  bool get isRoomFull => _currentPlayers >= _maxPlayers;
  bool get isHost => _hostPlayerId == _playerIds[0];
  
  // ========== 房间操作 ==========
  
  /// 创建房间
  Future<void> createRoom({required String roomName, int maxPlayers = 4}) async {
    _roomName = roomName;
    _maxPlayers = maxPlayers;
    _currentPlayers = 1;
    _hostPlayerId = _playerIds[0];
    _playerStates[0] = PlayerConnectionState.connected;
    notifyListeners();
  }
  
  /// 加入房间
  Future<bool> joinRoom(String roomId) async {
    _playerStates[0] = PlayerConnectionState.connecting;
    notifyListeners();
    
    // TODO: 连接到服务器并加入房间
    _roomId = roomId;
    _playerStates[0] = PlayerConnectionState.connected;
    _currentPlayers++;
    notifyListeners();
    return true;
  }
  
  /// 离开房间
  Future<void> leaveRoom() async {
    _roomId = null;
    _roomName = null;
    _currentPlayers = 0;
    
    for (int i = 0; i < 4; i++) {
      _playerStates[i] = PlayerConnectionState.disconnected;
      _playerIds[i] = null;
    }
    
    notifyListeners();
  }
  
  /// 玩家加入通知
  void onPlayerJoined(int playerIndex, String playerId) {
    _playerIds[playerIndex] = playerId;
    _playerStates[playerIndex] = PlayerConnectionState.connected;
    _currentPlayers++;
    notifyListeners();
  }
  
  /// 玩家离开通知
  void onPlayerLeft(int playerIndex) {
    _playerIds[playerIndex] = null;
    _playerStates[playerIndex] = PlayerConnectionState.disconnected;
    _currentPlayers--;
    notifyListeners();
  }
  
  /// 玩家断开连接
  void onPlayerDisconnected(int playerIndex) {
    _playerStates[playerIndex] = PlayerConnectionState.reconnecting;
    notifyListeners();
  }
  
  /// 玩家重连
  void onPlayerReconnected(int playerIndex) {
    _playerStates[playerIndex] = PlayerConnectionState.connected;
    notifyListeners();
  }
}
