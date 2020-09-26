import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../utils/constants.dart' as k;
import '../utils/http_exception.dart';

class Room with ChangeNotifier {
  List<dynamic> _connectedMembers = [];
  Map<String, dynamic> _myDetails;
  String _roomCode;
  List<dynamic> _chat = [];
  bool _isNewMsgReceived = false;

  List<dynamic> get connectedMembers => [..._connectedMembers];
  Map<String, dynamic> get myDetails => _myDetails;
  String get roomCode => _roomCode;
  List<dynamic> get chat => [..._chat];
  bool get isNewMsgReceived => _isNewMsgReceived;

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
        _myDetails = {
          'userId': resBody['details']['userId'],
          'name': resBody['details']['name'],
          'image': resBody['details']['photo_url'],
          'isHost': resBody['details']['isHost'],
        };
        _connectedMembers.add(_myDetails);
        print(_connectedMembers);
        notifyListeners();
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
      print(response.body);
      if (response.statusCode == 200) {
        final resBody = json.decode(response.body);
        _roomCode = resBody['roomId'];
        final _existingMembers = resBody['userList'];
        _myDetails = {
          'userId': resBody['details']['userId'],
          'name': resBody['details']['name'],
          'image': resBody['details']['photoUrl'],
          'isHost': resBody['details']['isHost'],
        };
        _connectedMembers = _existingMembers;
        _connectedMembers.add(_myDetails);
        notifyListeners();
      } else if (response.statusCode == 404) {
        throw HttpException('No Room Found');
      } else {
        throw HttpException('Internal Server Error');
      }
    } catch (e) {
      throw e;
    }
  }

  Future<void> kickMember(String token, Map<String, dynamic> data) async {
    try {
      final url = k.baseUrl + '/core/room/kick/';
      print(data);
      final response = await http.post(
        url,
        headers: {
          HttpHeaders.authorizationHeader: token,
          HttpHeaders.contentTypeHeader: 'application/json',
        },
        body: json.encode(data),
      );
      print(response.statusCode);
      if (response.statusCode == 204) {
      } else {
        throw HttpException('');
      }
    } catch (e) {
      throw e;
    }
  }

  Future<void> leaveRoom(String token, Map<String, dynamic> data) async {
    try {
      final url = k.baseUrl + '/core/room/leave/';
      final response = await http.post(
        url,
        headers: {
          HttpHeaders.authorizationHeader: token,
          HttpHeaders.contentTypeHeader: 'application/json',
        },
        body: json.encode(data),
      );
      print(response.statusCode);
      if (response.statusCode == 204) {
      } else {
        throw HttpException('Something Went Wrong');
      }
    } catch (e) {
      throw e;
    }
  }

  void updateHost(int userId) {
    final tempHost = _connectedMembers
        .where((element) => element['userId'] == userId)
        .toList()[0];
    _connectedMembers.removeWhere((element) => element['userId'] == userId);
    _connectedMembers.insert(0, tempHost);
    _connectedMembers[0]['isHost'] = true;
    notifyListeners();
  }

  void discoverMember(Map<String, dynamic> memberDetails) {
    _connectedMembers.add(memberDetails);
    notifyListeners();
  }

  void unDiscoverMember(int id) {
    print(id);
    _connectedMembers.removeWhere((element) => element['userId'] == id);
    print(_connectedMembers);
    notifyListeners();
  }

  void leave() {
    _connectedMembers = [];
    _myDetails = null;
    _roomCode = null;
    _chat = [];
  }

  void sendChat(String message, int id, String name) {
    _isNewMsgReceived = true;
    _chat.add({
      'senderID': id,
      'message': message,
      'name': name,
    });
    notifyListeners();
  }

  void seeMsg() {
    _isNewMsgReceived = false;
  }
}
