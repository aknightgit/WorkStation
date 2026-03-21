import 'package:flutter/foundation.dart';
import '../models/player_model.dart';

/// 多人联机状态管理
class MultiplayerProvider extends ChangeNotifier {
  /// 玩家连接状态
  enum PlayerConnectionState {
    disconnected,
    connecting,
    connected,
    reconnecting,
  }
  
  /// 当前房间信息
  String? _roomId;
  String? _roomName;
  int _maxPlayers = 4;
  int _currentPlayers = 0;
  String? _hostPlayerId;
  
  /// 玩家列表及连接状态
  final Map<int, PlayerConnectionState> _playerStates = {
    0: PlayerConnectionState.connected, // 本地玩家默认连接
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
  
  /// WebSocket连接
  WebSocket? _ws;
  bool _isConnected = false;
  
  // ========== Getter ==========
  
  String? get roomId => _roomId;
  String? get roomName => _roomName;
  int get maxPlayers => _maxPlayers;
  int get currentPlayers => _currentPlayers;
  String? get hostPlayerId => _hostPlayerId;
  bool get isConnected => _isConnected;
  
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
    
    // TODO: 连接到服务器并创建房间
    // _ws = await WebSocket.connect('ws://server:port/room');
    // _ws?.add('{"action":"create_room","room_name":"$roomName","max_players":$maxPlayers}');
  }
  
  /// 加入房间
  Future<bool> joinRoom(String roomId) async {
    _playerStates[0] = PlayerConnectionState.connecting;
    notifyListeners();
    
    // TODO: 连接到服务器并加入房间
    // _ws = await WebSocket.connect('ws://server:port/room/$roomId');
    // _ws?.add('{"action":"join_room","room_id":"$roomId"}');
    
    // 模拟加入成功
    _roomId = roomId;
    _playerStates[0] = PlayerConnectionState.connected;
    _currentPlayers++;
    notifyListeners();
    return true;
  }
  
  /// 离开房间
  Future<void> leaveRoom() async {
    // TODO: 通知服务器离开
    _ws?.close();
    _ws = null;
    _isConnected = false;
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
  
  // ========== 消息收发 ==========
  
  /// 发送游戏动作
  void sendGameAction(Map<String, dynamic> action) {
    if (_ws == null || !_isConnected) return;
    
    final message = {
      'type': 'game_action',
      'action': action,
      'player_id': _playerIds[0],
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    _ws?.add(message.toString());
  }
  
  /// 发送摸牌
  void sendDrawTile(int playerIndex, String tileType) {
    sendGameAction({
      'action_type': 'draw',
      'player_index': playerIndex,
      'tile_type': tileType,
    });
  }
  
  /// 发送打牌
  void sendDiscardTile(int playerIndex, String tileType) {
    sendGameAction({
      'action_type': 'discard',
      'player_index': playerIndex,
      'tile_type': tileType,
    });
  }
  
  /// 发送吃牌
  void sendChow(int playerIndex, String tileType, List<String> usedTiles) {
    sendGameAction({
      'action_type': 'chow',
      'player_index': playerIndex,
      'target_tile': tileType,
      'used_tiles': usedTiles,
    });
  }
  
  /// 发送碰牌
  void sendPong(int playerIndex, String tileType) {
    sendGameAction({
      'action_type': 'pong',
      'player_index': playerIndex,
      'tile_type': tileType,
    });
  }
  
  /// 发送杠牌
  void sendKong(int playerIndex, String tileType, {bool isHidden = false}) {
    sendGameAction({
      'action_type': isHidden ? 'hidden_kong' : 'exposed_kong',
      'player_index': playerIndex,
      'tile_type': tileType,
    });
  }
  
  /// 发送胡牌
  void sendHu(int playerIndex, String winType) {
    sendGameAction({
      'action_type': 'hu',
      'player_index': playerIndex,
      'win_type': winType,
    });
  }
  
  /// 处理接收到的消息
  void handleMessage(String message) {
    // TODO: 解析JSON并处理
    // final data = jsonDecode(message);
    // switch (data['type']) { ... }
    notifyListeners();
  }
  
  // ========== 同步 ==========
  
  /// 请求同步游戏状态
  void requestSync() {
    sendGameAction({'action_type': 'sync_request'});
  }
  
  /// 处理游戏状态同步
  void handleSync(Map<String, dynamic> gameState) {
    // TODO: 更新本地游戏状态
    notifyListeners();
  }
  
  /// 广播玩家动作
  void broadcastAction(Map<String, dynamic> action) {
    sendGameAction({
      'action_type': 'broadcast',
      'payload': action,
    });
  }
}

/// WebSocket类型占位符（实际使用时导入web_socket_channel）
typedef WebSocket = dynamic;
