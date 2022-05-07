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

  void _loginWith(BuildContext context) async {
    logger.d("login");
    await _signInWithGoogle(FirebaseAuth.instance.currentUser);
    Navigator.of(context).pop(ListScreen.routeName);
  }

  // ignore: unused_element
  Future<UserCredential> _signInWithAnonymous() async {
    return FirebaseAuth.instance.signInAnonymously();
  }

  Future<UserCredential> _signInWithGoogle(User? currentUserForBind) async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn(
      scopes: [
        'email',
      ],
    ).signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    UserCredential userCredential;
    if (currentUserForBind != null) {
      try {
        // Google認証アカウントを作成して匿名アカウントのデータを引き継ぐ
        userCredential =
            await currentUserForBind.linkWithCredential(credential);
      } catch (e) {
        logger.i(e.toString());
        // すでに該当ユーザーのGoogle認証アカウントがある場合は既存アカウントでログインする
        // 匿名アカウントで作業中のデータは破棄される
        // [firebase_auth/credential-already-in-use] This credential is already associated with a different user account.
        userCredential =
            await FirebaseAuth.instance.signInWithCredential(credential);
      }
    } else {
      userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
    }

    return userCredential;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ログイン"),
      ),
      body: Column(children: [
        OutlinedButton(
            onPressed: () => _loginWith(context),
            child: const Text("Googleアカウントでログイン")),
        const Text("・Googleアカウント連携して他のデバイスでデータを共有できるようになります"),
      ]),
    );
  }
}
