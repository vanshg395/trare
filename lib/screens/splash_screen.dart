import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';

import './landing_screen.dart';
import '../providers/auth.dart';
// import './onboarding_screen.dart';
// import './main_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();

  static const routeName = '/splash';
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 1), navigator);
  }

  Future<void> navigator() async {
    Provider.of<Auth>(context, listen: false).tryAutoLogin();
    Navigator.of(context).pushReplacementNamed(LandingScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // WebsafeSvg.asset(
              //   'assets/svg/logo.svg',
              //   height: 200,
              // ),
              // SizedBox(
              //   height: 30,
              // ),
              // Text(
              //   'Deskcount',
              //   style: Theme.of(context).textTheme.headline3.copyWith(
              //         color: Theme.of(context).primaryColor,
              //         fontWeight: FontWeight.w500,
              //         letterSpacing: 1,
              //       ),
              // ),
              // Text(
              //   'Give Discounts, Build Relations',
              //   style: Theme.of(context)
              //       .textTheme
              //       .subtitle2
              //       .copyWith(color: Theme.of(context).primaryColor),
              // )
            ],
          ),
        ),
      ),
    );
  }
}
