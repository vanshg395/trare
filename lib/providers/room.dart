import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../utils/constants.dart' as k;
import '../utils/http_exception.dart';

class Room with ChangeNotifier {
  List<dynamic> _connectedMembers = [];
  String _roomCode;

  String get roomCode => _roomCode;

  Future<void> initiateRoom(String token, String connectionId) async {
    try {
      final url = k.baseUrl + '/core/room/intitate/';
      final response = await http.post(
        url,
        headers: {
          HttpHeaders.authorizationHeader: token,
          HttpHeaders.contentTypeHeader: 'application/json',
        },
        body: json.encode({
          'connectionId': connectionId,
        }),
      );
      print(response.statusCode);
      print(response.body);
      if (response.statusCode == 200) {
        final resBody = json.decode(response.body);
        _roomCode = resBody['roomId'];
      } else {
        throw HttpException('Internal Server Error');
      }
    } catch (e) {
      throw e;
    }
  }

  Future<void> joinRoom(
      String token, String connectionId, String roomId) async {
    try {
      final url = k.baseUrl + '/core/room/join/';
      final response = await http.post(
        url,
        headers: {
          HttpHeaders.authorizationHeader: token,
          HttpHeaders.contentTypeHeader: 'application/json',
        },
        body: json.encode({
          'connectionId': connectionId,
          'room': roomId,
        }),
      );
      print(response.statusCode);
      if (response.statusCode == 200) {
      } else if (response.statusCode == 404) {
        throw HttpException('No Room Found');
      } else {
        throw HttpException('Internal Server Error');
      }
    } catch (e) {
      throw e;
    }
  }
}
