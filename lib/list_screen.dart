import 'package:flutter/material.dart';
import 'package:flutter_hello_world/domain/ticket_repository.dart';

import 'detail_screen.dart';
import 'domain/ticket.dart';

class ListScreen extends StatefulWidget {
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
      await TicketRepository().getList().then((list) => {items = list});
      setState(() {});
    });
  }

  void _add() {
    setState(() {
      _counter += 1;
      items.add(Ticket("item $_counter", ""));

      for (var element in items) {
        print(element.title + element.body);
      }
    });
  }

  void _navigateDetail(BuildContext context, int index) async {
    final result = await Navigator.push<Ticket>(
      context,
      MaterialPageRoute(
          builder: (context) => DetailScreen(
                ticket: items[index],
              )),
    );

    setState(() {});
  }

  void _delete(Ticket ticket) async {
    await TicketRepository().delete(ticket);
    await _initList();
    setState(() {});
  }

  Future<void> _initList() async {
    TicketRepository().getList().then((list) => {items = list});
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
