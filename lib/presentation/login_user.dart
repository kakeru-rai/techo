import 'package:firebase_auth/firebase_auth.dart';

class LoginUser {
  final String userName;
  final bool isAnonymous;

  LoginUser(this.userName, this.isAnonymous);

  factory LoginUser.fromFirebaseUser(User firebaseUser) {
    return LoginUser(getUserName(firebaseUser), firebaseUser.isAnonymous);
  }

  static String getUserName(User _currentUser) {
    if (_currentUser.isAnonymous) {
      return "匿名ユーザーさん";
    } else if (_currentUser.email != null && _currentUser.email!.isNotEmpty) {
      return _currentUser.email!;
    } else {
      return "新規ユーザーさん";
    }
  }
}
