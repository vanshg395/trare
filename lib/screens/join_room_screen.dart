import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:websafe_svg/websafe_svg.dart';
import 'package:page_transition/page_transition.dart';

import './waiting_screen.dart';
import '../providers/auth.dart';
import '../providers/socket.dart';
import '../providers/room.dart';

class JoinRoomScreen extends StatefulWidget {
  static const routeName = '/join-room';

  @override
  _JoinRoomScreenState createState() => _JoinRoomScreenState();
}

class _JoinRoomScreenState extends State<JoinRoomScreen> {
  int _currentPart = 1;
  TextEditingController _keyController = TextEditingController();
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

  Future<void> _searchRoom() async {
    setState(() {
      _isLoading = true;
    });
    if (_nameController.text == '') {
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
      }
    }
    setState(() {
      _currentPart++;
      _isLoading = false;
    });
  }

  Future<void> _joinRoom() async {
    if (_keyController.text == '') {
      return;
    }
    Provider.of<Socket>(context, listen: false).connectToSocket();
    Provider.of<Socket>(context, listen: false).sendMessage({
      "action": "echo",
    });
    _listenToSocket();
  }

  void _listenToSocket() {
    Provider.of<Socket>(context, listen: false).subscription.onData((message) {
      print(message);
      final resBody = json.decode(message);
      final connId = resBody['connectionId'];
      _connectToRoom(connId);
    });
  }

  Future<void> _connectToRoom(String connectionId) async {
    print('JOIN ROOM >>>');
    setState(() {
      _isLoading = true;
    });
    try {
      await Provider.of<Room>(context, listen: false).joinRoom(
          Provider.of<Auth>(context, listen: false).token,
          connectionId,
          _keyController.text.toUpperCase());
      Navigator.of(context).pop();
      Navigator.of(context).pushReplacement(
        PageTransition(
          type: PageTransitionType.fade,
          alignment: Alignment.center,
          child: WaitingScreen(),
        ),
      );
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print(e);
      if (e.toString() == 'No Room Found') {
        showDialog(
          context: context,
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Container(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  WebsafeSvg.asset('assets/svg/warning.svg', height: 40),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    'The room code is invalid.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  Widget _buildKeyCollector() {
    return Column(
      children: [
        Text(
          'Do you have a key?',
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).accentColor),
        ),
        Container(
          width: MediaQuery.of(context).size.width * 0.9,
          child: TextField(
            enableSuggestions: false,
            keyboardType: TextInputType.visiblePassword,
            textCapitalization: TextCapitalization.characters,
            controller: _keyController,
            maxLength: 6,
            decoration: InputDecoration(
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              hintText: 'XXXXXX',
              counterText: '',
            ),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Anton',
              fontSize: 50,
              letterSpacing: 30,
              color: Theme.of(context).accentColor,
            ),
            onChanged: (val) {
              setState(() {});
              if (val.length == 6) {
                FocusScope.of(context).unfocus();
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNameCollector() {
    return Column(
      children: [
        Text(
          'What shall we call you?',
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).accentColor),
        ),
        Container(
          width: MediaQuery.of(context).size.width * 0.8,
          child: TextField(
            readOnly: Provider.of<Auth>(context, listen: false).token != null,
            enableSuggestions: false,
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
              fontSize: _nameController.text.length > 15
                  ? 30
                  : _nameController.text.length > 10 ? 40 : 60,
              letterSpacing: 4,
              color: Theme.of(context).accentColor,
            ),
            onChanged: (_) {
              setState(() {});
            },
          ),
        ),
      ],
    );
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
                'JOIN ROOM',
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
            AnimatedCrossFade(
              firstChild: _buildNameCollector(),
              secondChild: _buildKeyCollector(),
              crossFadeState: _currentPart == 1
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              duration: Duration(milliseconds: 300),
            ),
            Spacer(),
            if ((_currentPart == 2 && _keyController.text.length > 2) ||
                (_currentPart == 1 && _nameController.text.length > 2))
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
                      onTap: _currentPart == 1 ? _searchRoom : _joinRoom,
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
