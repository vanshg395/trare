import 'package:flutter/material.dart';
import 'package:websafe_svg/websafe_svg.dart';
import 'package:provider/provider.dart';

import './create_room_screen.dart';
import './join_room_screen.dart';
import '../widgets/landing_button.dart';
import '../providers/auth.dart';

class LandingScreen extends StatefulWidget {
  static const routeName = '/home';

  @override
  _LandingScreenState createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  Future<void> _googleSignIn() async {
    showDialog(
      context: context,
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        backgroundColor: Theme.of(context).accentColor,
        child: Container(
          height: 100,
          width: 100,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(
                    Theme.of(context).primaryColor,
                  ),
                ),
              ),
              Text('Logging In')
            ],
          ),
        ),
      ),
    );
    try {
      await Provider.of<Auth>(context, listen: false).signInWithGoogle();
    } catch (e) {}
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        child: Stack(
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height / 2,
              child: Center(
                child: Icon(
                  Icons.ac_unit,
                  color: Theme.of(context).accentColor,
                  size: 100,
                ),
              ),
            ),
            Positioned(
              bottom: MediaQuery.of(context).size.height * 0.1 + 125,
              child: Container(
                width: MediaQuery.of(context).size.width,
                child: LandingButton(
                  assetPath: 'assets/svg/create_room.svg',
                  onTap: () => Navigator.of(context)
                      .pushNamed(CreateRoomScreen.routeName),
                ),
              ),
            ),
            Positioned(
              bottom: MediaQuery.of(context).size.height * 0.1,
              child: Container(
                width: MediaQuery.of(context).size.width,
                child: LandingButton(
                  assetPath: 'assets/svg/join_room.svg',
                  onTap: () =>
                      Navigator.of(context).pushNamed(JoinRoomScreen.routeName),
                ),
              ),
            ),
            Positioned(
              bottom: MediaQuery.of(context).size.height * 0.1,
              right: 20,
              child: GestureDetector(
                child: Container(
                  height: 70,
                  width: 70,
                  padding: EdgeInsets.all(
                      Provider.of<Auth>(context).imageUrl == '' ? 10 : 5),
                  decoration: BoxDecoration(
                    color: Theme.of(context).accentColor,
                    shape: BoxShape.circle,
                  ),
                  child: Provider.of<Auth>(context).imageUrl == ''
                      ? WebsafeSvg.network(
                          'https://cdn.svgporn.com/logos/google-icon.svg',
                        )
                      : ClipOval(
                          child: Image.network(
                            Provider.of<Auth>(context).imageUrl,
                          ),
                        ),
                ),
                onTap: _googleSignIn,
              ),
            )
          ],
        ),
      ),
    );
  }
}
