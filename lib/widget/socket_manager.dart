import 'package:socket_io_client/socket_io_client.dart' as io;

class SocketManager {
  static final SocketManager _instance = SocketManager._internal();

  factory SocketManager() {
    return _instance;
  }

  SocketManager._internal() {
    connect('http://localhost:9090');
    // connect('http://147.83.7.157:9090'); /*Production */
  }

  late io.Socket _socket;

  void Function(dynamic)? _messageHandler;

  io.Socket get socket => _socket;

  void connect(String serverUrl) {
    _socket = io.io(serverUrl, <String, dynamic>{
      'transports': ['websocket'],
    });

    _socket.on('chat message', (data) {
      if (_messageHandler != null) {
        _messageHandler!(data);
      }
    });

    // Lógica de conexión, eventos, etc.
    // ...

    _socket.connect();
  }

  void setMessageHandler(void Function(dynamic) handler) {
    _messageHandler = handler;
  }

  void joinRoom(String userId, String roomId) {
    _socket.emit('join room', {'userId': userId, 'roomId': roomId});
  }

  void leaveRoom(String userId, String roomId) {
    _socket.emit('leave room', {'userId': userId, 'roomId': roomId});
  }
}
