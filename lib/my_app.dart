import 'package:flutter/material.dart';
import 'package:flutter_hello_world/screen/welcome_screen.dart';
import 'screen/list_screen.dart';

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp(this.isLoggedIn, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: isLoggedIn ? const ListScreen() : const WelcomeScreen(),
        routes: {
          WelcomeScreen.routeName: (_) => const WelcomeScreen(),
          ListScreen.routeName: (_) => const ListScreen(),
        });
  }
}
