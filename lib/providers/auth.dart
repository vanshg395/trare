import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/constants.dart' as k;
import '../utils/google_sign_in.dart' as gs;
import '../utils/http_exception.dart';

class Auth with ChangeNotifier {
  String _token;
  String _name;
  String _username;
  String _imageUrl = '';

  String get token => _token;
  String get name => _name;
  String get username => _username;
  String get imageUrl => _imageUrl;

  Future<void> signin(String key, String value) async {
    try {
      final url = k.baseUrl + '/auth/signup/';
      final response = await http.post(
        url,
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
        },
        body: json.encode({
          key: value,
        }),
      );
      print(response.statusCode);
      print(response.body);
      if (response.statusCode == 200) {
        final resBody = json.decode(response.body);
        _token = 'Token ' + resBody['user']['token'];
        _imageUrl = resBody['user']['photoUrl'];
        _name = resBody['user']['full_name'];
        _username = resBody['user']['username'];

        final _prefs = await SharedPreferences.getInstance();
        print(_imageUrl);
        await _prefs.setString(
          'userData',
          json.encode({
            'token': _token,
            'name': _name,
            'username': _username,
            'imageUrl': _imageUrl,
          }),
        );
        notifyListeners();
      } else if (response.statusCode >= 500) {
        throw HttpException('Internal Server Error');
      } else {
        throw HttpException('Something Went Wrong');
      }
    } catch (e) {
      throw e;
    }
  }

  Future<void> signInWithGoogle() async {
    await Firebase.initializeApp();
    final user = await gs.signInWithGoogle();
    if (_token == null) {
      await signin('fbToken', user.uid);
    } else {
      if (_imageUrl == '') {
        await registerGuest(_token, user.uid);
      }
    }
  }

  Future<void> tryAutoLogin() async {
    final _prefs = await SharedPreferences.getInstance();
    if (_prefs.containsKey('userData')) {
      final _extractedUserData =
          json.decode(_prefs.getString('userData')) as Map<String, dynamic>;
      print(_extractedUserData);
      _token = _extractedUserData['token'];
      _name = _extractedUserData['name'];
      _username = _extractedUserData['username'];
      _imageUrl = _extractedUserData['imageUrl'];
    }
  }

  Future<void> registerGuest(String token, String uid) async {
    try {
      final url = k.baseUrl + '/auth/upgrade/';
      final response = await http.post(
        url,
        headers: {
          HttpHeaders.authorizationHeader: token,
          HttpHeaders.contentTypeHeader: 'application/json',
        },
        body: json.encode({
          'fbToken': uid,
        }),
      );
      print('POST UPGRADE USER >>>> ' + response.statusCode.toString());
      print(response.body);
      if (response.statusCode == 203) {
        final resBody = json.decode(response.body);
        _imageUrl = resBody['user']['photoUrl'];
        _name = resBody['user']['full_name'];
        _username = resBody['user']['username'];
        final _prefs = await SharedPreferences.getInstance();
        await _prefs.clear();
        await _prefs.setString(
          'userData',
          json.encode({
            'token': _token,
            'name': _name,
            'username': _username,
            'imageUrl': _imageUrl,
          }),
        );
        notifyListeners();
      } else if (response.statusCode == 403) {
        await logout();
        signInWithGoogle();
      }
    } catch (e) {
      throw e;
    }
  }

  Future<void> logout() async {
    try {
      final _prefs = await SharedPreferences.getInstance();
      _token = null;
      _name = null;
      _username = null;
      _imageUrl = '';
      await _prefs.clear();
    } catch (e) {
      print(e);
    }
  }
}
