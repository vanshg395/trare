import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './waiting_screen.dart';
import '../providers/auth.dart';
import '../providers/socket.dart';
import '../providers/room.dart';

class CreateRoomScreen extends StatefulWidget {
  static const routeName = '/create-room';

  @override
  _CreateRoomScreenState createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends State<CreateRoomScreen> {
  TextEditingController _nameController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (Provider.of<Auth>(context, listen: false).name != null) {
      setState(() {
        _nameController.text = Provider.of<Auth>(context, listen: false).name;
      });
    }
  }

  void _listenToSocket() {
    Provider.of<Socket>(context, listen: false).subscription.onData((message) {
      print(message);
      final resBody = json.decode(message);
      final connId = resBody['connectionId'];
      _createRoom(connId);
    });
  }

  Future<void> _createRoom(String connectionId) async {
    print('CREATE ROOM >>>');
    try {
      await Provider.of<Room>(context, listen: false).initiateRoom(
          Provider.of<Auth>(context, listen: false).token, connectionId);
      setState(() {
        _isLoading = false;
      });
      Navigator.of(context).pushReplacementNamed(WaitingScreen.routeName);
    } catch (e) {
      print(e);
    }
  }

  Future<void> _checkAuth() async {
    setState(() {
      _isLoading = true;
    });
    if (_nameController.text.length == 0) {
      return;
    }
    if (Provider.of<Auth>(context, listen: false).token == null) {
      try {
        await Provider.of<Auth>(context, listen: false).signin(
          'full_name',
          _nameController.text,
        );
      } catch (e) {
        print(e);
        setState(() {
          _isLoading = false;
        });
      }
    }
    Provider.of<Socket>(context, listen: false).sendMessage({
      "action": "echo",
    });
    _listenToSocket();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(),
      body: Container(
        child: Column(
          children: <Widget>[
            Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.15,
              padding: EdgeInsets.only(right: 12),
              alignment: Alignment.bottomRight,
              color: Theme.of(context).primaryColor,
              child: Text(
                'CREATE ROOM',
                style: TextStyle(
                  fontFamily: 'Anton',
                  color: Theme.of(context).accentColor,
                  fontSize: 50,
                ),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.07,
            ),
            Text(
              'What shall we call you?',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).accentColor),
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.8,
              child: TextFormField(
                enableSuggestions: false,
                readOnly:
                    Provider.of<Auth>(context, listen: false).token != null,
                keyboardType: TextInputType.visiblePassword,
                controller: _nameController,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  hintText: 'John Doe',
                ),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Anton',
                  fontSize: 60,
                  letterSpacing: 4,
                  color: Theme.of(context).accentColor,
                ),
                onChanged: (_) {
                  setState(() {});
                },
              ),
            ),
            Spacer(),
            if (_nameController.text.length > 2)
              _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(
                          Theme.of(context).primaryColor,
                        ),
                      ),
                    )
                  : GestureDetector(
                      child: Container(
                        height: 60,
                        width: 300,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'NEXT',
                          style: TextStyle(
                            color: Theme.of(context).accentColor,
                            fontFamily: 'Anton',
                            fontSize: 24,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                      onTap: _checkAuth,
                    ),
            SizedBox(
              height: 30,
            ),
          ],
        ),
      ),
    );
  }
}
