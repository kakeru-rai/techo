import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewScreen extends StatefulWidget {
  static const routeName = "WebViewScreen";

  const WebViewScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _WebViewScreen();
}

class _WebViewScreen extends State<WebViewScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('利用規約'),
      ),
      body: const WebView(
        initialUrl: 'https://techo-dev-c2560.firebaseapp.com/term.html',
      ),
    );
  }
}
