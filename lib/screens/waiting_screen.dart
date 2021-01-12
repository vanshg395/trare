import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:websafe_svg/websafe_svg.dart';
import 'package:page_transition/page_transition.dart';

import './landing_screen.dart';
import './game_screen.dart';
import '../widgets/chat_drawer.dart';
import '../providers/auth.dart';
import '../providers/room.dart';
import '../providers/socket.dart';

class WaitingScreen extends StatefulWidget {
  static const routeName = '/waiting';

  @override
  _WaitingScreenState createState() => _WaitingScreenState();
}

class _WaitingScreenState extends State<WaitingScreen> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  void initState() {
    _listenToSocket();
    super.initState();
  }

  void _listenToSocket() {
    Provider.of<Socket>(context, listen: false).subscription.onData((message) {
      print(message);
      final resBody = json.decode(message);
      if (resBody['action'] == 'USER_JOIN') {
        Provider.of<Socket>(context, listen: false).sendMessage({
          "action": "broadcast",
          "auth": Provider.of<Auth>(context, listen: false).token.substring(6),
          "message":
              Provider.of<Room>(context, listen: false).selectedCollections,
          "room": Provider.of<Room>(context, listen: false).roomCode,
          "subaction": "CAT_CHANGE",
        });
        Provider.of<Room>(context, listen: false).discoverMember({
          'userId': resBody['userId'],
          'name': resBody['name'],
          'image': resBody['photo_url'],
          'isHost': resBody['isHost'],
        });
      } else if (resBody['action'] == 'KICK_USER') {
        Provider.of<Room>(context, listen: false)
            .unDiscoverMember(resBody['userId']);
        if (resBody['userId'] ==
            Provider.of<Room>(context, listen: false).myDetails['userId']) {
          Navigator.of(context).pushReplacement(
            PageTransition(
              type: PageTransitionType.fade,
              alignment: Alignment.center,
              child: LandingScreen(),
            ),
          );
          Provider.of<Room>(context, listen: false).leave();
          Provider.of<Socket>(context, listen: false).disconnect();
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
                      'Oops! You were kicked from the room.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      } else if (resBody['action'] == 'USER_LEFT') {
        Provider.of<Room>(context, listen: false)
            .unDiscoverMember(resBody['user']);
      } else if (resBody['action'] == 'HOST_REPLACED') {
        Provider.of<Room>(context, listen: false).updateHost(resBody['host']);
      } else if (resBody['action'] == 'CHAT') {
        Provider.of<Room>(context, listen: false)
            .sendChat(resBody['message'], resBody['userId'], resBody['name']);
      } else if (resBody['action'] == 'CAT_CHANGE') {
        Provider.of<Room>(context, listen: false)
            .updateCollections(resBody['message']);
      }
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
    await Provider.of<Room>(context, listen: false).leaveRoom(
      Provider.of<Auth>(context, listen: false).token,
      {
        'room': Provider.of<Room>(context, listen: false).roomCode.toUpperCase()
      },
    );
    Navigator.of(context).pushReplacement(
      PageTransition(
        type: PageTransitionType.fade,
        child: LandingScreen(),
      ),
    );
    Provider.of<Room>(context, listen: false).leave();
    Provider.of<Socket>(context, listen: false).disconnect();
    return true;
  }

  Future<void> _begin() async {
    // await Provider.of<Room>(context, listen: false)
    //     .startGame(Provider.of<Auth>(context, listen: false).token);
    Navigator.of(context).pushReplacement(
      PageTransition(
        type: PageTransitionType.fade,
        child: GameScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _leaveRoom,
      child: Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            Provider.of<Room>(context).roomCode?.toUpperCase() ?? '',
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
            // IconButton(
            //   icon: Icon(
            //     Platform.isIOS ? CupertinoIcons.share : Icons.share,
            //     size: 30,
            //   ),
            //   onPressed: () {},
            // ),
            IconButton(
                icon: Stack(
                  children: <Widget>[
                    Icon(Icons.chat_bubble),
                    if (Provider.of<Room>(context).isNewMsgReceived)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          height: 10,
                          width: 10,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).canvasColor,
                          ),
                        ),
                      ),
                  ],
                ),
                // icon: Badge(
                //   showBadge:
                //       Provider.of<Room>(context, listen: false).isNewMsgReceived,
                //   child: Icon(Icons.chat_bubble),
                // ),
                onPressed: () {
                  Provider.of<Room>(context, listen: false).seeMsg();
                  setState(() {});
                  _scaffoldKey.currentState.openEndDrawer();
                }),
          ],
        ),
        endDrawer: ChatDrawer(),
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
                      Provider.of<Room>(context).connectedMembers[i]['name'],
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Anton',
                        fontSize: 22,
                      ),
                    ),
                    trailing: (Provider.of<Room>(context).myDetails['isHost'] ||
                            i == 0)
                        ? InkWell(
                            child: Container(
                              padding: EdgeInsets.all(5),
                              child: WebsafeSvg.asset(Provider.of<Room>(context)
                                      .connectedMembers[i]['isHost']
                                  ? 'assets/svg/host.svg'
                                  : 'assets/svg/kick.svg'),
                            ),
                            onTap: i > 0
                                ? () {
                                    if (Provider.of<Room>(context,
                                            listen: false)
                                        .myDetails['isHost']) {
                                      Provider.of<Room>(context, listen: false)
                                          .kickMember(
                                        Provider.of<Auth>(context,
                                                listen: false)
                                            .token,
                                        {
                                          'room': Provider.of<Room>(context,
                                                  listen: false)
                                              .roomCode
                                              .toUpperCase(),
                                          'id': Provider.of<Room>(context,
                                                  listen: false)
                                              .connectedMembers[i]['userId'],
                                        },
                                      );
                                    }
                                  }
                                : null,
                          )
                        : null,
                  ),
                  separatorBuilder: (ctx, i) => Divider(
                    thickness: 2,
                    color: Theme.of(context).accentColor,
                  ),
                  itemCount: Provider.of<Room>(context).connectedMembers.length,
                ),
              ),
              SizedBox(
                height: 40,
              ),
              Text(
                Provider.of<Room>(context).myDetails['isHost']
                    ? 'Choose Themes'
                    : 'Chosen Themes',
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
                child: ListView(scrollDirection: Axis.horizontal, children: <
                    Widget>[
                  SizedBox(
                    width: 5,
                  ),
                  if (Provider.of<Room>(context).myDetails['isHost'])
                    ...Provider.of<Room>(context)
                        .privateCollections
                        .map(
                          (th) => GestureDetector(
                            child: Container(
                              height: 60,
                              width: 200,
                              alignment: Alignment.center,
                              margin: EdgeInsets.symmetric(horizontal: 5),
                              color: Provider.of<Room>(context)
                                      .selectedCollections
                                      .contains(th)
                                  ? Theme.of(context).primaryColor
                                  : Theme.of(context).accentColor,
                              child: Text(
                                th['collection_name'].toString().toUpperCase(),
                                style: TextStyle(
                                  color: Provider.of<Room>(context)
                                          .selectedCollections
                                          .contains(th)
                                      ? Theme.of(context).accentColor
                                      : Theme.of(context).primaryColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 3,
                                ),
                              ),
                            ),
                            onTap: () {
                              Provider.of<Room>(context, listen: false)
                                  .changeCollections(th);
                              // print(_selectedThemes);
                              Provider.of<Socket>(context, listen: false)
                                  .sendMessage({
                                "action": "broadcast",
                                "auth":
                                    Provider.of<Auth>(context, listen: false)
                                        .token
                                        .substring(6),
                                "message":
                                    Provider.of<Room>(context, listen: false)
                                        .selectedCollections,
                                "room":
                                    Provider.of<Room>(context, listen: false)
                                        .roomCode,
                                "subaction": "CAT_CHANGE",
                              });
                            },
                          ),
                        )
                        .toList()
                  else
                    ...Provider.of<Room>(context).selectedCollections.map(
                          (th) => GestureDetector(
                            child: Container(
                              height: 60,
                              width: 200,
                              alignment: Alignment.center,
                              margin: EdgeInsets.symmetric(horizontal: 5),
                              color: Provider.of<Room>(context)
                                      .selectedCollections
                                      .contains(th)
                                  ? Theme.of(context).primaryColor
                                  : Theme.of(context).accentColor,
                              child: Text(
                                th['collection_name'].toString().toUpperCase(),
                                style: TextStyle(
                                  color: Provider.of<Room>(context)
                                          .selectedCollections
                                          .contains(th)
                                      ? Theme.of(context).accentColor
                                      : Theme.of(context).primaryColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 3,
                                ),
                              ),
                            ),
                          ),
                        ),
                  SizedBox(
                    width: 5,
                  ),
                ]),
              ),
              Spacer(),
              if (Provider.of<Room>(context).myDetails['isHost'])
                GestureDetector(
                  child: Container(
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
                  onTap: _begin,
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
