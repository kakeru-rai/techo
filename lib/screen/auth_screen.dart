import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
    print("_login");
    UserCredential credential = await _signInWithGoogle();
    Navigator.of(context).pushReplacementNamed(ListScreen.routeName);
  }

  Future<UserCredential> _signInWithAnonymous() async {
    print("Signed in with temporary account.");
    return FirebaseAuth.instance.signInAnonymously();
  }

  Future<UserCredential> _signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
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
