import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hello_world/domain/ticket_repository.dart';
import 'package:flutter_hello_world/screen/webview_screen.dart';
import 'package:flutter_hello_world/screen/welcome_screen.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'detail_screen.dart';
import '../domain/ticket.dart';

import '../shared/logger.dart';

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
  late TextEditingController _titleController;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController();
    Future(() async {
      await _setStateInitView();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _onTicketAddTapped() {
    if (_titleController.text.isEmpty) {
      return;
    }

    setState(() {
      _items.insert(0, Ticket("", _titleController.text, "", 0));
      _updateSort(_items);

      _titleController.text = "";
    });
  }

  void _onListItemTapped(BuildContext context, int index) async {
    // 返り値を変数に入れないと待ってくれないので
    // ignore: unused_local_variable
    var result = await Navigator.push<Ticket>(
      context,
      MaterialPageRoute(
          builder: (context) => DetailScreen(
                ticket: _items[index],
              )),
    );

    _setStateInitView();
  }

  void _onListItemDeleteTapped(int itemIndex) async {
    await TicketRepository().delete(_items[itemIndex]);

    _items.removeAt(itemIndex);
    _updateSort(_items);

    _setStateInitView();
  }

  void _onLogoutTapped() async {
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
    } else if (_currentUser.email != null && _currentUser.email!.isNotEmpty) {
      return _currentUser.email!;
    } else {
      return "新規ユーザーさん";
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          appBar: AppBar(
            title: const Text("メモ"),
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
                    child: Column(
                      children: [
                        Icon(
                            _currentUser.isAnonymous
                                ? Icons.account_circle
                                : Icons.face,
                            size: 80.0),
                        Text(_userName),
                      ],
                    ),
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
                            _onLogoutTapped();
                          }),
                  ListTile(
                      title: const Text('利用規約'),
                      onTap: () async {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => WebViewScreen(
                                  Uri.parse(
                                      'https://techo-dev-c2560.firebaseapp.com/term.html'),
                                  title: "利用規約")),
                        );
                      }),
                  ListTile(
                      title: const Text('プライバシーポリシー'),
                      onTap: () async {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => WebViewScreen(
                                  Uri.parse(
                                      'https://techo-dev-c2560.firebaseapp.com/privacy.html'),
                                  title: "プライバシーポリシー")),
                        );
                      }),
                  ListTile(
                      title: const Text('初期化'),
                      onTap: () async {
                        await FirebaseAuth.instance
                            .signOut()
                            .catchError((error) => logger.e(error));
                        Navigator.pushReplacementNamed(
                            context, WelcomeScreen.routeName);
                      }),
                ]),
          ),
          body: Column(children: [
            Expanded(
              child: ReorderableListView(
                children: <Widget>[
                  for (int index = 0; index < _items.length; ++index)
                    ListTile(
                      key: Key(_items[index].id),
                      onTap: () {
                        _onListItemTapped(context, index);
                      },
                      title: Text(_items[index].title),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          _onListItemDeleteTapped(index);
                        },
                      ),
                    )
                ],
                onReorder: (int oldIndex, int newIndex) {
                  setState(() {
                    if (oldIndex < newIndex) {
                      newIndex -= 1;
                    }
                    final Ticket item = _items.removeAt(oldIndex);
                    _items.insert(newIndex, item);
                    _updateSort(_items);
                  });
                },
              ),
            ),
            Container(
                // ボトム入力フォーム
                color: Colors.grey[200],
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: Colors.white70,
                    ),
                    child: SizedBox(
                        height: 40,
                        child: Row(children: [
                          Expanded(
                              child: TextField(
                            onEditingComplete: _onTicketAddTapped,
                            autofocus: false,
                            controller: _titleController,
                            style: const TextStyle(fontSize: 14),
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 12),
                              hintText: 'タイトル',
                              hintStyle: TextStyle(
                                  fontSize: 14, color: Colors.black26),
                              border: InputBorder.none,
                            ),
                          )),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: _onTicketAddTapped,
                          )
                        ]))))
          ]),
        ));
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

void _updateSort(List<Ticket> _items) {
  int lastIndex = _items.length - 1;
  _items.asMap().forEach((index, ticket) {
    int newSort = lastIndex - index;
    if (ticket.sort == newSort) {
      return;
    }
    ticket.sort = newSort;
    TicketRepository().upsert(ticket);
  });
}
