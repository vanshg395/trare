import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';

import '../utils/constants.dart' as k;

class Socket with ChangeNotifier {
  IOWebSocketChannel _channel;
  StreamSubscription<dynamic> _subscription;

  IOWebSocketChannel get channel => _channel;
  StreamSubscription<dynamic> get subscription => _subscription;

  void connectToSocket() {
    print('SOCKET CONNECTED');

    _channel = IOWebSocketChannel.connect(k.socketUrl);
    _subscription = _channel.stream.listen((event) {});
  }

  void sendMessage(dynamic data) {
    _channel.sink.add(json.encode(data));
  }

  void disconnect() {
    print('SOCKET DISCONNECTED');
    _channel.sink.close();
  }
}
