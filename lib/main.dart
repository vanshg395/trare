import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import './screens/splash_screen.dart';
import './screens/landing_screen.dart';
import './screens/create_room_screen.dart';
import './screens/join_room_screen.dart';
import './screens/waiting_screen.dart';
import './screens/game_screen.dart';
import './providers/auth.dart';
import './providers/socket.dart';
import './providers/room.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: Auth(),
        ),
        ChangeNotifierProvider.value(
          value: Socket(),
        ),
        ChangeNotifierProvider.value(
          value: Room(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Trare',
        themeMode: ThemeMode.dark,
        darkTheme: ThemeData(
          primaryColor: Color(0xFF212125),
          accentColor: Color(0xFFFFFFFF),
          canvasColor: Color(0xFFFF5858),
          appBarTheme: AppBarTheme(
            color: Color(0xFF212125),
            elevation: 0,
          ),
          fontFamily: 'Montserrat',
        ),
        home: SplashScreen(),
        routes: {
          LandingScreen.routeName: (ctx) => LandingScreen(),
          CreateRoomScreen.routeName: (ctx) => CreateRoomScreen(),
          JoinRoomScreen.routeName: (ctx) => JoinRoomScreen(),
          WaitingScreen.routeName: (ctx) => WaitingScreen(),
          GameScreen.routeName: (ctx) => GameScreen(),
        },
      ),
    );
  }
}
