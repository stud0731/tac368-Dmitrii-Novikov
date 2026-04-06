import 'dart:async';
import 'dart:convert';
import 'dart:io';

class GameConnection {
  Socket? _socket;
  ServerSocket? _server;

  final StreamController<Map<String, dynamic>> _messageController =
      StreamController<Map<String, dynamic>>.broadcast();

  // message stream
  Stream<Map<String, dynamic>> get messages => _messageController.stream;

  // start host
  Future<void> host(int port) async {
    _server = await ServerSocket.bind(InternetAddress.anyIPv4, port);
    _socket = await _server!.first;
    _listen();
  }

  // join host
  Future<void> join(String host, int port) async {
    _socket = await Socket.connect(host, port);
    _listen();
  }

  // read messages
  void _listen() {
    _socket!
        .cast<List<int>>()
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen((line) {
      final data = jsonDecode(line);
      _messageController.add(Map<String, dynamic>.from(data));
    });
  }

  // send message
  void send(Map<String, dynamic> message) {
    _socket?.write('${jsonEncode(message)}\n');
  }

  // close sockets
  Future<void> close() async {
    await _socket?.close();
    await _server?.close();
    await _messageController.close();
  }
}