import 'package:flutter/material.dart';

import 'screen/list_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const ListScreen(),
        routes: {
          ListScreen.routeName: (_) => const ListScreen(),
        });
  }
}
