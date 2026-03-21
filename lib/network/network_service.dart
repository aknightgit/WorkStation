import 'dart:convert';

/// 网络消息类型
enum MessageType {
  createRoom,
  joinRoom,
  leaveRoom,
  roomInfo,
  playerJoined,
  playerLeft,
  startGame,
  gameStateSync,
  gameAction,
  error,
  ping,
  pong,
}

/// 游戏动作类型
enum GameActionType {
  draw,
  discard,
  chow,
  pong,
  exposedKong,
  hiddenKong,
  hu,
  skip,
  dice,
}

/// 网络消息
class NetworkMessage {
  final MessageType type;
  final Map<String, dynamic> data;
  final String? playerId;
  final DateTime timestamp;

  NetworkMessage({
    required this.type,
    required this.data,
    this.playerId,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory NetworkMessage.fromJson(Map<String, dynamic> json) {
    return NetworkMessage(
      type: MessageType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => MessageType.error,
      ),
      data: json['data'] ?? {},
      playerId: json['player_id'],
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'data': data,
      'player_id': playerId,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  String toJsonString() => jsonEncode(toJson());
}

/// 网络服务 - 处理WebSocket通信（简化版）
/// 实际使用时在客户端实现具体连接
class NetworkService {
  bool _isConnected = false;
  String? _roomId;
  String? _playerId;

  // 回调函数
  Function(NetworkMessage)? onMessage;
  Function(bool)? onConnectionChanged;

  bool get isConnected => _isConnected;
  String? get roomId => _roomId;
  String? get playerId => _playerId;

  /// 连接到服务器（由客户端实现）
  Future<bool> connect(String serverUrl) async {
    // TODO: 使用 web_socket_channel 实现
    return false;
  }

  /// 断开连接
  Future<void> disconnect() async {
    _isConnected = false;
    onConnectionChanged?.call(false);
  }

  /// 发送消息
  void send(NetworkMessage message) {
    if (!_isConnected) return;
    // TODO: 实现发送
  }

  /// 创建房间
  void createRoom(String roomName, int maxPlayers) {
    send(NetworkMessage(
      type: MessageType.createRoom,
      data: {'room_name': roomName, 'max_players': maxPlayers},
    ));
  }

  /// 加入房间
  void joinRoom(String roomId) {
    _roomId = roomId;
    send(NetworkMessage(
      type: MessageType.joinRoom,
      data: {'room_id': roomId},
    ));
  }

  /// 离开房间
  void leaveRoom() {
    send(NetworkMessage(
      type: MessageType.leaveRoom,
      data: {'room_id': _roomId},
    ));
    _roomId = null;
  }

  /// 发送游戏动作
  void sendGameAction({
    required GameActionType actionType,
    required int playerIndex,
    Map<String, dynamic>? actionData,
  }) {
    send(NetworkMessage(
      type: MessageType.gameAction,
      data: {
        'action_type': actionType.name,
        'player_index': playerIndex,
        ...?actionData,
      },
      playerId: _playerId,
    ));
  }

  /// 请求游戏状态同步
  void requestSync() {
    send(NetworkMessage(
      type: MessageType.gameStateSync,
      data: {'action': 'sync_request'},
    ));
  }

  /// 发送心跳
  void sendPing() {
    send(NetworkMessage(type: MessageType.ping, data: {}));
  }

  /// 处理接收到的消息（由客户端调用）
  void handleReceivedMessage(String message) {
    try {
      final json = jsonDecode(message);
      final networkMessage = NetworkMessage.fromJson(json);
      onMessage?.call(networkMessage);
    } catch (e) {
      // 忽略解析错误
    }
  }
}
