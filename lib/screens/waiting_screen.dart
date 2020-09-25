import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:websafe_svg/websafe_svg.dart';

import './landing_screen.dart';
import '../providers/room.dart';
import '../providers/socket.dart';

class WaitingScreen extends StatefulWidget {
  static const routeName = '/waiting';

  @override
  _WaitingScreenState createState() => _WaitingScreenState();
}

class _WaitingScreenState extends State<WaitingScreen> {
  List<dynamic> _themes = ['School', 'Colleges', 'Adult'];
  String _selectedTheme = 'School';

  @override
  void initState() {
    _listenToSocket();
    super.initState();
  }

  void _listenToSocket() {
    Provider.of<Socket>(context, listen: false).subscription.onData((message) {
      print(message);
    });
  }

  Future<bool> _leaveRoom() async {
    bool _isConfirmed = false;
    Platform.isIOS
        ? await showCupertinoDialog(
            context: context,
            builder: (ctx) => CupertinoAlertDialog(
              title: Text('Exit?'),
              content: Text('Are you sure, you want to leave the room?'),
              actions: <Widget>[
                CupertinoDialogAction(
                  child: Text('No'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                CupertinoDialogAction(
                  child: Text('Yes'),
                  onPressed: () {
                    _isConfirmed = true;
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          )
        : await showDialog(
            context: context,
            child: AlertDialog(
              title: Text('Exit?'),
              content: Text('Are you sure, you want to leave the room?'),
              actions: <Widget>[
                FlatButton(
                  child: Text('Yes'),
                  onPressed: () {
                    _isConfirmed = true;
                    Navigator.of(context).pop();
                  },
                ),
                FlatButton(
                  child: Text('No'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          );
    if (!_isConfirmed) {
      return false;
    }
    Navigator.of(context).pushReplacementNamed(LandingScreen.routeName);
    return true;
    // await Provider.of<Auth>(context, listen: false).logout();
    // Navigator.of(context).pushReplacementNamed(MainScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _leaveRoom,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            Provider.of<Room>(context).roomCode.toUpperCase() ?? '',
            style: TextStyle(
              fontFamily: 'Anton',
              fontSize: 30,
              letterSpacing: 10,
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: _leaveRoom,
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Platform.isIOS ? CupertinoIcons.share : Icons.share,
                size: 30,
              ),
              onPressed: () {},
            )
          ],
        ),
        body: Container(
          width: double.infinity,
          child: Column(
            children: <Widget>[
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.04,
              ),
              Text(
                'Waiting for Players...',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).accentColor,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                height: 300,
                child: ListView.separated(
                  physics: BouncingScrollPhysics(),
                  itemBuilder: (ctx, i) => ListTile(
                    leading: Text(
                      '${i + 1}',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Anton',
                      ),
                    ),
                    title: Text(
                      'John Doe',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Anton',
                        fontSize: 22,
                      ),
                    ),
                    trailing: InkWell(
                      child: Container(
                        padding: EdgeInsets.all(5),
                        child: WebsafeSvg.asset(i == 0
                            ? 'assets/svg/host.svg'
                            : 'assets/svg/kick.svg'),
                      ),
                      onTap: () {},
                    ),
                  ),
                  separatorBuilder: (ctx, i) => Divider(
                    thickness: 2,
                    color: Theme.of(context).accentColor,
                  ),
                  itemCount: 8,
                ),
              ),
              SizedBox(
                height: 40,
              ),
              Text(
                'Choose Theme',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).accentColor,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                height: 60,
                child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: <Widget>[
                      SizedBox(
                        width: 5,
                      ),
                      ..._themes
                          .map(
                            (th) => GestureDetector(
                              child: Container(
                                height: 60,
                                width: 200,
                                alignment: Alignment.center,
                                margin: EdgeInsets.symmetric(horizontal: 5),
                                color: _selectedTheme == th
                                    ? Theme.of(context).primaryColor
                                    : Theme.of(context).accentColor,
                                child: Text(
                                  th.toString().toUpperCase(),
                                  style: TextStyle(
                                    color: _selectedTheme == th
                                        ? Theme.of(context).accentColor
                                        : Theme.of(context).primaryColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 3,
                                  ),
                                ),
                              ),
                              onTap: () {
                                setState(() {
                                  _selectedTheme = th;
                                });
                              },
                            ),
                          )
                          .toList(),
                      SizedBox(
                        width: 5,
                      ),
                    ]),
              ),
              Spacer(),
              Container(
                height: 60,
                width: 300,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.play_arrow,
                      color: Theme.of(context).accentColor,
                      size: 50,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      'LET\'S BEGIN',
                      style: TextStyle(
                        color: Theme.of(context).accentColor,
                        fontFamily: 'Anton',
                        fontSize: 24,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 30,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
