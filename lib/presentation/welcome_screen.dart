import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hello_world/presentation/list_screen.dart';
import 'package:flutter_hello_world/presentation/webview_screen.dart';

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
        body: Center(
            child: Column(mainAxisSize: MainAxisSize.max, children: [
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      ),
      const Spacer(flex: 1),
      const Icon(Icons.emoji_objects_outlined, size: 60.0, color: Colors.grey),
      const Icon(Icons.emoji_people_outlined, size: 100.0, color: Colors.grey),
      const Spacer(flex: 1),
      TextButton(
        style: const ButtonStyle(
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: const Text("利用規約"),
        onPressed: () async {
          WebViewScreenNavigation.pushTerm(context);
        },
      ),
      TextButton(
        style: const ButtonStyle(
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: const Text("プライバシーポリシー"),
        onPressed: () async {
          WebViewScreenNavigation.pushPrivacy(context);
        },
      ),
      Row(
        mainAxisSize: MainAxisSize.min,
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
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 80),
      ),
    ])));
  }
}

Future<UserCredential> _signInWithAnonymous() async {
  return FirebaseAuth.instance.signInAnonymously();
}
