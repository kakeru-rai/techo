import 'package:flutter/material.dart';
import 'package:flutter_hello_world/domain/ticket_repository.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../domain/ticket.dart';
import '../shared/logger.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({Key? key, required this.ticket}) : super(key: key);
  final Ticket ticket;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  _DetailScreenState();

  late TextEditingController _titleController;
  late TextEditingController _bodyController;
  String markdown = "";
  bool _isPreview = true;

  @override
  void initState() {
    super.initState();
    markdown = widget.ticket.body;
    _titleController = TextEditingController(text: widget.ticket.title);
    _bodyController = TextEditingController(text: widget.ticket.body);
    _isPreview = widget.ticket.body.isEmpty ? false : true;
  }

  void _save() async {
    widget.ticket.title = _titleController.text;
    widget.ticket.body = _bodyController.text;
    await TicketRepository().upsert(widget.ticket);
  }

  void _onBodyChanged(String text) {
    setState(() {
      markdown = text;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () {
          if (Navigator.of(context).userGestureInProgress || _isPreview) {
            _save();
            return Future.value(true);
          }

          setState(() {
            _isPreview = true;
          });
          return Future.value(false);
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(widget.ticket.title),
            leading: Builder(
              builder: (BuildContext context) {
                return _isPreview
                    ? IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      )
                    : IconButton(
                        icon: const Icon(Icons.check),
                        onPressed: () {
                          setState(() {
                            _isPreview = true;
                          });
                        },
                      );
              },
            ),
          ),
          body: _isPreview
              ? Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                  child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isPreview = false;
                        });
                      },
                      child: Markdown(
                        data: markdown,
                        selectable: true,
                        shrinkWrap: true,
                        softLineBreak: true,
                        onTapText: () {
                          setState(() {
                            _isPreview = false;
                          });
                        },
                      )))
              : SingleChildScrollView(
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 16),
                      child: TextField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          hintText: 'タイトル',
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 16),
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
                  ],
                )),
        ));
  }
}
