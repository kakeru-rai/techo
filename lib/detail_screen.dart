import 'package:flutter/material.dart';
import 'package:flutter_hello_world/domain/ticket_repository.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import 'domain/ticket.dart';

class DetailScreen extends StatefulWidget {
  DetailScreen({Key? key, required this.ticket}) : super(key: key);
  final Ticket ticket;
  String markdown = "hoge";

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  _DetailScreenState();

  late TextEditingController _titleController;
  late TextEditingController _bodyController;
  String markdown = "hoge";

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.ticket.title);
    _bodyController = TextEditingController(text: widget.ticket.body);
  }

  void _save() {
    widget.ticket.title = _titleController.text;
    widget.ticket.body = _bodyController.text;

    TicketRepository().put(widget.ticket);
  }

  void _onBodyChanged(String text) {
    setState(() {
      markdown = text;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.ticket.title)),
      body: SingleChildScrollView(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            child: TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: 'タイトル',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            child: TextFormField(
              controller: _bodyController,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              onChanged: _onBodyChanged,
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                hintText: "本文",
              ),
            ),
          ),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: SizedBox(
                  height: 200.0,
                  child: Markdown(
                    selectable: true,
                    data: markdown,
                  ))),
        ],
      )),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _save();
          print("pop" + widget.ticket.toString());
          Navigator.pop<Ticket>(context, widget.ticket);
        },
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
