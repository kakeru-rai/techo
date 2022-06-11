import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hello_world/screen/list_screen.dart';
import 'package:flutter_hello_world/screen/webview_screen.dart';

class WelcomeScreen extends StatefulWidget {
  static const routeName = "WelcomeScreen";

  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _WelcomeScreen();
}

class _WelcomeScreen extends State<WelcomeScreen> {
  bool _isAgree = false;

  onStartPressed() async {
    await _signInWithAnonymous();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(children: [
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      ),
      Text("sd\nsaf"),
      TextButton(
        child: const Text("利用規約"),
        onPressed: () async {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => WebViewScreen(
                    Uri.parse(
                        'https://techo-dev-c2560.firebaseapp.com/term.html'),
                    title: "利用規約")),
          );
        },
      ),
      TextButton(
        child: const Text("プライバシーポリシー"),
        onPressed: () async {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => WebViewScreen(
                    Uri.parse(
                        'https://techo-dev-c2560.firebaseapp.com/privacy.html'),
                    title: "プライバシーポリシー")),
          );
        },
      ),
      Row(
        children: [
          Checkbox(
            onChanged: (bool? value) {
              setState(() => {_isAgree = !_isAgree});
            },
            value: _isAgree,
          ),
          const Text("利用規約に同意する"),
        ],
      ),
      OutlinedButton(
          onPressed: _isAgree
              ? () async {
                  await _signInWithAnonymous();
                  Navigator.pushReplacementNamed(context, ListScreen.routeName);
                }
              : null,
          child: const Text("はじめる")),
    ]));
  }
}

Future<UserCredential> _signInWithAnonymous() async {
  return FirebaseAuth.instance.signInAnonymously();
}
