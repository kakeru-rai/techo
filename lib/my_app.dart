import 'package:flutter/material.dart';

import 'list_screen.dart';
import 'screen/auth_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const ListScreen(),
        routes: {
          AuthScreen.routeName: (_) => const AuthScreen(),
          ListScreen.routeName: (_) => const ListScreen(),
        });
  }
}
