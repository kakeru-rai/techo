import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../shared/logger.dart';

class FirebaseAuthAdapter {
  static User? getUser() => FirebaseAuth.instance.currentUser;

  static Future<void> signOut() async {
    return FirebaseAuth.instance
        .signOut()
        .catchError((error) => logger.e(error));
  }

  static Future<UserCredential> signInWithAnonymous() async {
    return FirebaseAuth.instance.signInAnonymously();
  }

  static Future<bool> signInWithGoogle() async {
    User? currentUserForBind = FirebaseAuthAdapter.getUser();
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

    return userCredential.user != null;
  }
}
