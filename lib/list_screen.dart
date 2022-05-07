import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hello_world/domain/ticket_repository.dart';
import 'package:flutter_hello_world/screen/auth_screen.dart';

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

  Future<List<Ticket>> _getList() async {
    return TicketRepository().getList();
  }

  void _add() {
    setState(() {
      _counter += 1;
      _items.add(Ticket("", "item $_counter", ""));
    });
  }

  void _navigateDetail(BuildContext context, int index) async {
    await Navigator.push<Ticket>(
      context,
      MaterialPageRoute(
          builder: (context) => DetailScreen(
                ticket: _items[index],
              )),
    );

    _setStateInitView();
  }

  void _delete(Ticket ticket) async {
    await TicketRepository().delete(ticket);
    _setStateInitView();
  }

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance
        .signOut()
        .catchError((error) => logger.e(error));
    await _signInWithAnonymous();
    _setStateInitView();
  }

  Future<UserCredential> _signInWithAnonymous() async {
    return FirebaseAuth.instance.signInAnonymously();
  }

  void _login(BuildContext context) async {
    Navigator.pop(context);
    final result = await Navigator.pushNamed(context, AuthScreen.routeName);
    _setStateInitView();
  }

  Future<void> _setStateInitView() async {
    _items = await _getList();
    _userName = _getUserName();
    setState(() {});
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
                  ? ListTile(
                      leading: const Icon(Icons.logout),
                      title: const Text('ログイン'),
                      onTap: () {
                        _login(context);
                      })
                  : ListTile(
                      leading: const Icon(Icons.logout),
                      title: const Text('ログアウト'),
                      onTap: () {
                        _logout(context);
                      }),
            ]),
      ),
      body: ListView.separated(
        itemCount: _items.length,
        itemBuilder: (context, index) {
          return ListTile(
            onTap: () {
              _navigateDetail(context, index);
            },
            title: Text(_items[index].title),
            subtitle: Text(_items[index].body),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                _delete(_items[index]);
              },
            ),
          );
        },
        separatorBuilder: (context, index) {
          return const Divider();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _add,
        tooltip: 'add',
        child: const Icon(Icons.add),
      ),
    );
  }
}
