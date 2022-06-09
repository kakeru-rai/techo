import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hello_world/screen/list_screen.dart';

class WelcomeScreen extends StatefulWidget {
  static const routeName = "WelcomeScreen";

  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Checkbox(
        onChanged: (bool? value) {},
        value: false,
      ),
      const Text("hoge"),
    ]);
  }

  @override
  State<StatefulWidget> createState() => _WelcomeScreen();
}

class _WelcomeScreen extends State<WelcomeScreen> {
  onStartPressed() async {
    await _signInWithAnonymous();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(children: [
      Checkbox(
        onChanged: (bool? value) {},
        value: false,
      ),
      OutlinedButton(
          onPressed: () async {
            await _signInWithAnonymous();
            Navigator.pushReplacementNamed(context, ListScreen.routeName);
          },
          child: const Text("はじめる")),
    ]));
  }
}

Future<UserCredential> _signInWithAnonymous() async {
  return FirebaseAuth.instance.signInAnonymously();
}
