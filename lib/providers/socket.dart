import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';

import '../utils/constants.dart' as k;

class Socket with ChangeNotifier {
  IOWebSocketChannel _channel = IOWebSocketChannel.connect(k.socketUrl);
  StreamSubscription<dynamic> _subscription;

  IOWebSocketChannel get channel => _channel;
  StreamSubscription<dynamic> get subscription => _subscription;

  void sendMessage(dynamic data) {
    _channel.sink.add(json.encode(data));
    print(_subscription);
    if (_subscription == null)
      _subscription = _channel.stream.listen((event) {
        print('ROOT >>>> ' + event.toString());
      });
  }
}
