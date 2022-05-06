import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hello_world/domain/ticket_repository.dart';
import 'package:flutter_hello_world/screen/auth_screen.dart';

import 'detail_screen.dart';
import 'domain/ticket.dart';

class ListScreen extends StatefulWidget {
  static const routeName = "list";

  const ListScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  List<Ticket> items = [];

  int _counter = 0;

  @override
  void initState() {
    super.initState();

    Future(() async {
      items = await _getList();
      await _getList();
      setState(() {});
    });
  }

  Future<List<Ticket>> _getList() async {
    return TicketRepository().getListFromUid();
  }

  void _add() {
    setState(() {
      _counter += 1;
      items.add(Ticket("", "item $_counter", ""));

      for (var element in items) {
        print(element.title + element.body);
      }
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

    setState(() {});
  }

  void _delete(Ticket ticket) async {
    print("list delete");
    await TicketRepository().delete(ticket);
    await _initList();
    setState(() {});
  }

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut().catchError((error) => print(error));
    Navigator.of(context).pushReplacementNamed(AuthScreen.routeName);
  }

  Future<void> _initList() async {
    print("_initList");
    items = await _getList();
    return Future<void>.value();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("リスト"),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.update),
            tooltip: 'Update',
            onPressed: () {
              setState(() {});
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'logout',
            onPressed: () {
              _logout(context);
            },
          ),
        ],
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
            trailing: OutlinedButton(
              onPressed: () {
                _delete(items[index]);
              },
              child: const Text("X"),
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
