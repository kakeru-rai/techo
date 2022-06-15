import 'package:flutter/material.dart';
import 'package:flutter_hello_world/screen/detail_screen.dart';
import 'package:flutter_hello_world/screen/webview_screen.dart';
import 'package:flutter_hello_world/screen/welcome_screen.dart';
import 'domain/ticket.dart';
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
        onGenerateRoute: (RouteSettings settings) {
          // routesだと画面遷移の戻り値の型を指定できないのでonGenerateRouteを使う
          // pushNamed: type ‘MaterialPageRoute<dynamic>’ is not a subtype of type ‘Route<Hoge>’
          // @see https://www.flutterclutter.dev/flutter/troubleshooting/pushnamed-type-materialpageroute-is-not-a-subtype-of-type-route/2021/35456/
          final String routeName = settings.name ?? '';

          switch (routeName) {
            case WelcomeScreen.routeName:
              return MaterialPageRoute(builder: (_) => const WelcomeScreen());
            case ListScreen.routeName:
              return MaterialPageRoute(builder: (_) => const ListScreen());
            case WebViewScreen.routeName:
              return MaterialPageRoute(builder: (_) => const WebViewScreen());
            case DetailScreen.routeName:
              return MaterialPageRoute<Ticket>(builder: (context) {
                return DetailScreen(ticket: settings.arguments as Ticket);
              });
          }
          throw Exception("route not found");
        });
  }
}
