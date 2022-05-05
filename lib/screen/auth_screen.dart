import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

import '../list_screen.dart';

class AuthScreen extends StatefulWidget {
  static const String routeName = "auth";

  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AuthScreen();
}

class _AuthScreen extends State<AuthScreen> {
  @override
  void initState() {
    super.initState();
  }

  void _login(BuildContext context) async {
    try {
      final userCredential = await FirebaseAuth.instance.signInAnonymously();
      print("Signed in with temporary account.");
      Navigator.of(context).pushReplacementNamed(ListScreen.routeName);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "operation-not-allowed":
          print("Anonymous auth hasn't been enabled for this project.");
          break;
        default:
          print("Unkown error.");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ログイン"),
      ),
      body: const Text("ログイン"),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _login(context),
        tooltip: 'add',
        child: const Icon(Icons.add),
      ),
    );
  }
}
