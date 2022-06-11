import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewScreen extends StatefulWidget {
  static const routeName = "WebViewScreen";
  final Uri url;
  final String? title;

  const WebViewScreen(this.url, {Key? key, this.title}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _WebViewScreen();
}

class _WebViewScreen extends State<WebViewScreen> {
  @override
  Widget build(BuildContext context) {
    Uri.parse("");
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? ""),
      ),
      body: WebView(
        initialUrl: widget.url.toString(),
      ),
    );
  }
}
