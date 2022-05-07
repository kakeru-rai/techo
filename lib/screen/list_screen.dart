import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hello_world/domain/ticket_repository.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'detail_screen.dart';
import 'domain/ticket.dart';

import 'shared/logger.dart';

class ListScreen extends StatefulWidget {
  static const routeName = "list";

  const ListScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  List<Ticket> _items = [];
  String _userName = "";
  User _currentUser = FirebaseAuth.instance.currentUser!;

  int _counter = 0;

  @override
  void initState() {
    super.initState();

    Future(() async {
      await _setStateInitView();
    });
  }

  void _onTicketAddTapped() {
    setState(() {
      _counter += 1;
      _items.add(Ticket("", "item $_counter", ""));
    });
  }

  void _onListItemTapped(BuildContext context, int index) async {
    await Navigator.push<Ticket>(
      context,
      MaterialPageRoute(
          builder: (context) => DetailScreen(
                ticket: _items[index],
              )),
    );

    _setStateInitView();
  }

  void _onListItemDeleteTapped(Ticket ticket) async {
    await TicketRepository().delete(ticket);
    _setStateInitView();
  }

  void _onLogoutTapped(BuildContext context) async {
    await FirebaseAuth.instance
        .signOut()
        .catchError((error) => logger.e(error));
    await _signInWithAnonymous();
    _setStateInitView();
  }

  void _onLoginTapped(BuildContext context) async {
    logger.d("login");
    UserCredential userCredential =
        await _signInWithGoogle(FirebaseAuth.instance.currentUser);
    if (userCredential.user != null) {
      Navigator.pop(context);
      _setStateInitView();
    }
  }

  Future<void> _setStateInitView() async {
    _currentUser = FirebaseAuth.instance.currentUser!;
    _items = await _getList();
    _userName = _getUserName();
    setState(() {});
  }

  Future<List<Ticket>> _getList() async {
    return TicketRepository().getList();
  }

  String _getUserName() {
    if (_currentUser.isAnonymous) {
      return "匿名ユーザーさん";
    } else if (_currentUser.displayName != null &&
        _currentUser.displayName!.isNotEmpty) {
      return _currentUser.displayName!;
    } else {
      return "新規ユーザーさん";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("リスト1k"),
      ),
      drawer: Drawer(
        child: ListView(
            // Important: Remove any padding from the ListView.
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(
                  color: Colors.white10,
                ),
                child: Text(_userName),
              ),
              _currentUser.isAnonymous
                  ? SignInButton(
                      Buttons.Google,
                      onPressed: () {
                        _onLoginTapped(context);
                      },
                    )
                  : ListTile(
                      leading: const Icon(Icons.logout),
                      title: const Text('ログアウト'),
                      onTap: () {
                        _onLogoutTapped(context);
                      }),
            ]),
      ),
      body: ListView.separated(
        itemCount: _items.length,
        itemBuilder: (context, index) {
          return ListTile(
            onTap: () {
              _onListItemTapped(context, index);
            },
            title: Text(_items[index].title),
            subtitle: Text(_items[index].body),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                _onListItemDeleteTapped(_items[index]);
              },
            ),
          );
        },
        separatorBuilder: (context, index) {
          return const Divider();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onTicketAddTapped,
        tooltip: 'add',
        child: const Icon(Icons.add),
      ),
    );
  }
}

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
      userCredential = await currentUserForBind.linkWithCredential(credential);
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
