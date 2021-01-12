import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:websafe_svg/websafe_svg.dart';
import 'package:page_transition/page_transition.dart';

import './landing_screen.dart';
import '../widgets/chat_drawer.dart';
import '../providers/auth.dart';
import '../providers/room.dart';
import '../providers/socket.dart';

class GameScreen extends StatefulWidget {
  static const routeName = '/game-room';

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  // List<dynamic> _themes = ['School', 'Colleges', 'Adult'];
  // String _selectedTheme = 'School';
  String _chosenName = 'Vansh Goel';
  List<String> _names = [
    'Audry Whyte',
    'Carley Iannuzzi  ',
    'Cindie Lunsford  ',
    'Hosea Weise  ',
    'Linwood Nowacki',
    'Violeta Bast  ',
    'Tyrone Miler  ',
    'Fe Schuelke  ',
    'Harvey Carlon  ',
    'Shon Cornejo  ',
    'Alix Rhode  ',
    'Venetta Conn  ',
    'Lydia Scribner  ',
    'Teresa Vandenburg  ',
    'Judie Hamblin  ',
    'Garry Drewes  ',
    'Dorethea Morita  ',
    'Lilly Schuett  ',
    'Elenor Callaway  ',
    'Lucia Waldrep  ',
  ];

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
          Navigator.of(context).pushReplacementNamed(LandingScreen.routeName);
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
    // Navigator.of(context).pushReplacementNamed(MainScreen.routeName);
  }

  void _spinNames() {
    int count = 0;
    print(count);
    print('shuffle started');
    Timer.periodic(Duration(milliseconds: 300), (timer) {
      if (count < 20) {
        _names.shuffle();
        setState(() {
          _chosenName = _names[0];
        });
        count++;
      } else {
        setState(() {
          _chosenName = 'Final Name';
        });
      }
    });
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
                height: 120,
                width: double.infinity,
                alignment: Alignment.center,
                margin: EdgeInsets.symmetric(horizontal: 30),
                decoration: BoxDecoration(
                  color: Theme.of(context).accentColor.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _chosenName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 30,
                    letterSpacing: 3,
                    color: Color(0xFF6266A2),
                    fontFamily: 'Anton',
                  ),
                ),
              ),
              // Container(
              //   padding: EdgeInsets.symmetric(horizontal: 20),
              //   height: 300,
              //   child: ListView.separated(
              //     physics: BouncingScrollPhysics(),
              //     itemBuilder: (ctx, i) => ListTile(
              //       leading: Text(
              //         '${i + 1}',
              //         style: TextStyle(
              //           color: Colors.white,
              //           fontFamily: 'Anton',
              //         ),
              //       ),
              //       title: Text(
              //         Provider.of<Room>(context).connectedMembers[i]['name'],
              //         style: TextStyle(
              //           color: Colors.white,
              //           fontFamily: 'Anton',
              //           fontSize: 22,
              //         ),
              //       ),
              //       trailing: (Provider.of<Room>(context).myDetails['isHost'] ||
              //               i == 0)
              //           ? InkWell(
              //               child: Container(
              //                 padding: EdgeInsets.all(5),
              //                 child: WebsafeSvg.asset(Provider.of<Room>(context)
              //                         .connectedMembers[i]['isHost']
              //                     ? 'assets/svg/host.svg'
              //                     : 'assets/svg/kick.svg'),
              //               ),
              //               onTap: i > 0
              //                   ? () {
              //                       if (Provider.of<Room>(context,
              //                               listen: false)
              //                           .myDetails['isHost']) {
              //                         Provider.of<Room>(context, listen: false)
              //                             .kickMember(
              //                           Provider.of<Auth>(context,
              //                                   listen: false)
              //                               .token,
              //                           {
              //                             'room': Provider.of<Room>(context,
              //                                     listen: false)
              //                                 .roomCode
              //                                 .toUpperCase(),
              //                             'id': Provider.of<Room>(context,
              //                                     listen: false)
              //                                 .connectedMembers[i]['userId'],
              //                           },
              //                         );
              //                       }
              //                     }
              //                   : null,
              //             )
              //           : null,
              //     ),
              //     separatorBuilder: (ctx, i) => Divider(
              //       thickness: 2,
              //       color: Theme.of(context).accentColor,
              //     ),
              //     itemCount: Provider.of<Room>(context).connectedMembers.length,
              //   ),
              // ),

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
                          'SPIN',
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
                  onTap: _spinNames,
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
