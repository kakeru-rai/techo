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
  List<Ticket> items = [];
  String userName = "";

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
      items.add(Ticket("", "item $_counter", ""));
    });
  }

  void _navigateDetail(BuildContext context, int index) async {
    await Navigator.push<Ticket>(
      context,
      MaterialPageRoute(
          builder: (context) => DetailScreen(
                ticket: items[index],
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
    final result = await Navigator.pushNamed(context, AuthScreen.routeName);
    _setStateInitView();
  }

  Future<void> _setStateInitView() async {
    items = await _getList();
    userName = _userName();
    setState(() {});
  }

  List<Widget> _createAppBarButton() {
    var list = <Widget>[];

    User currentUser = FirebaseAuth.instance.currentUser!;
    if (currentUser.isAnonymous) {
      list.add(IconButton(
        icon: const Icon(Icons.login),
        tooltip: 'login',
        onPressed: () {
          _login(context);
        },
      ));
    } else {
      list.add(IconButton(
        icon: const Icon(Icons.logout),
        tooltip: 'logout',
        onPressed: () {
          _logout(context);
        },
      ));
    }
    return list;
  }

  String _userName() {
    User currentUser = FirebaseAuth.instance.currentUser!;

    if (currentUser.isAnonymous) {
      return "匿名ユーザーさん";
    } else if (currentUser.displayName != null &&
        currentUser.displayName!.isNotEmpty) {
      return currentUser.displayName!;
    } else {
      return "新規ユーザーさん";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("リスト1k"),
        actions: _createAppBarButton(),
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
                child: Text(userName),
              ),
            ]),
      ),
      body: ListView.separated(
        itemCount: items.length,
        itemBuilder: (context, index) {
          return ListTile(
            onTap: () {
              _navigateDetail(context, index);
            },
            title: Text(items[index].title),
            subtitle: Text(items[index].body),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                _delete(items[index]);
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
