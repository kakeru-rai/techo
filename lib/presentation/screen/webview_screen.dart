import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewScreen extends StatefulWidget {
  static const routeName = "WebViewScreen";
  final WebViewScreenArgs args;

  const WebViewScreen(this.args, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _WebViewScreen();
}

class _WebViewScreen extends State<WebViewScreen> {
  @override
  Widget build(BuildContext context) {
    Uri.parse("");
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.args.title ?? ""),
      ),
      body: WebView(
        initialUrl: widget.args.url.toString(),
      ),
    );
  }
}

class WebViewScreenArgs {
  final Uri url;
  final String? title;
  const WebViewScreenArgs(this.url, this.title);
}

extension WebViewScreenNavigation on WebViewScreen {
  static push(BuildContext context, Uri url, String? title) {
    Navigator.pushNamed(context, WebViewScreen.routeName,
        arguments: WebViewScreenArgs(url, title));
  }

  static pushPrivacy(BuildContext context) {
    Navigator.pushNamed(context, WebViewScreen.routeName,
        arguments: WebViewScreenArgs(
            Uri.parse('https://techo-dev-c2560.firebaseapp.com/privacy.html'),
            "プライバシーポリシー"));
  }

  static pushTerm(BuildContext context) {
    Navigator.pushNamed(context, WebViewScreen.routeName,
        arguments: WebViewScreenArgs(
            Uri.parse("https://techo-dev-c2560.firebaseapp.com/term.html"),
            "利用規約"));
  }
}
