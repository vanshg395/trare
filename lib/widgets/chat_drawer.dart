import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:websafe_svg/websafe_svg.dart';
import 'package:bubble/bubble.dart';
import 'package:provider/provider.dart';

import '../providers/auth.dart';
import '../providers/room.dart';
import '../providers/socket.dart';

class ChatDrawer extends StatefulWidget {
  @override
  _ChatDrawerState createState() => _ChatDrawerState();
}

class _ChatDrawerState extends State<ChatDrawer> {
  TextEditingController _chatController = TextEditingController();
  bool _isOpened = false;

  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_chatController.text == '') {
      return;
    }
    Provider.of<Room>(context, listen: false).sendChat(
        _chatController.text,
        Provider.of<Room>(context, listen: false).myDetails['userId'],
        Provider.of<Room>(context, listen: false).myDetails['name']);
    Provider.of<Socket>(context, listen: false).sendMessage({
      "action": "broadcast",
      "auth": Provider.of<Auth>(context, listen: false).token.substring(6),
      "message": _chatController.text,
      "room": Provider.of<Room>(context, listen: false).roomCode,
      "subaction": "CHAT"
    });
    setState(() {
      _chatController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.95,
      child: Drawer(
        child: Container(
          height: double.infinity,
          width: double.infinity,
          color: Colors.grey.withOpacity(0.6),
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: SafeArea(
            child: Column(
              children: <Widget>[
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.symmetric(horizontal: 6),
                    reverse: true,
                    physics: BouncingScrollPhysics(),
                    children: <Widget>[
                      SizedBox(
                        height: 10,
                      ),
                      ...Provider.of<Room>(context)
                          .chat
                          .reversed
                          .toList()
                          .map((message) {
                        // if (!_isOpened) {
                        //   Provider.of<Room>(context, listen: false).seeMsg();
                        //   _isOpened = true;
                        // }

                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: message['senderID'] ==
                                  Provider.of<Room>(context, listen: false)
                                      .myDetails['userId']
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: <Widget>[
                            Bubble(
                              margin: BubbleEdges.only(
                                top: 10,
                                left: message['senderID'] ==
                                        Provider.of<Room>(context,
                                                listen: false)
                                            .myDetails['userId']
                                    ? 30
                                    : 0,
                                right: message['senderID'] ==
                                        Provider.of<Room>(context,
                                                listen: false)
                                            .myDetails['userId']
                                    ? 0
                                    : 30,
                              ),
                              alignment: message['senderID'] ==
                                      Provider.of<Room>(context, listen: false)
                                          .myDetails['userId']
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              nip: message['senderID'] ==
                                      Provider.of<Room>(context, listen: false)
                                          .myDetails['userId']
                                  ? BubbleNip.rightBottom
                                  : BubbleNip.leftBottom,
                              nipOffset: 5,
                              color: Color.fromRGBO(225, 255, 199, 1.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: message['senderID'] ==
                                        Provider.of<Room>(context,
                                                listen: false)
                                            .myDetails['userId']
                                    ? CrossAxisAlignment.end
                                    : CrossAxisAlignment.start,
                                children: <Widget>[
                                  if (message['senderID'] !=
                                      Provider.of<Room>(context, listen: false)
                                          .myDetails['userId'])
                                    Text(
                                      message['name'] ?? '',
                                      style: TextStyle(
                                        color: Theme.of(context).canvasColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  Text(
                                    message['message'],
                                    textAlign: message['senderID'] ==
                                            Provider.of<Room>(context,
                                                    listen: false)
                                                .myDetails['userId']
                                        ? TextAlign.right
                                        : TextAlign.left,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ],
                  ),
                ),
                Container(
                  color: Colors.white,
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.only(left: 16, right: 6),
                          width: double.infinity,
                          color: Theme.of(context).accentColor,
                          child: TextField(
                            controller: _chatController,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              focusedErrorBorder: InputBorder.none,
                            ),
                            textInputAction: TextInputAction.send,
                            onSubmitted: (_) {
                              _sendMessage();
                            },
                          ),
                        ),
                      ),
                      Container(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 6, horizontal: 6),
                          child: GestureDetector(
                            child: WebsafeSvg.asset(
                              'assets/svg/send.svg',
                              height: 30,
                            ),
                            onTap: _sendMessage,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
