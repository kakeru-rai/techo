import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../list_screen.dart';
import '../shared/logger.dart';

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
    logger.d("login");
    await _signInWithGoogle();
    Navigator.of(context).pushReplacementNamed(ListScreen.routeName);
  }

  // ignore: unused_element
  Future<UserCredential> _signInWithAnonymous() async {
    return FirebaseAuth.instance.signInAnonymously();
  }

  Future<UserCredential> _signInWithGoogle() async {
    logger.d("_signInWithGoogle");
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn(
      scopes: [
        'email',
      ],
    ).signIn();

    logger.d("_signInWithGoogle 2");
    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    logger.d("_signInWithGoogle 3");
    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    logger.d("_signInWithGoogle 4");
    // Once signed in, return the UserCredential
    var userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);
    logger.d("_signInWithGoogle 5");
    return userCredential;
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
