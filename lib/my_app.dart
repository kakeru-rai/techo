import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'domain/ticket.dart';
import 'presentation/screen/detail_screen.dart';
import 'presentation/screen/list_screen.dart';
import 'presentation/screen/webview_screen.dart';
import 'presentation/screen/welcome_screen.dart';

class MyApp extends HookConsumerWidget {
  final bool isLoggedIn;
  const MyApp(this.isLoggedIn, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              return MaterialPageRoute(
                  builder: (_) =>
                      WebViewScreen(settings.arguments as WebViewScreenArgs));
            case DetailScreen.routeName:
              return MaterialPageRoute<Ticket>(builder: (context) {
                return DetailScreen(ticket: settings.arguments as Ticket);
              });
          }
          throw Exception("route not found");
        });
  }
}
