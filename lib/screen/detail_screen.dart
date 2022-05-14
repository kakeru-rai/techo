import 'package:flutter/material.dart';
import 'package:flutter_hello_world/domain/ticket_repository.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../domain/ticket.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({Key? key, required this.ticket}) : super(key: key);
  final Ticket ticket;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  _DetailScreenState();

  late DetailScreenUiBuilder _uiBuilder;
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
    _uiBuilder = _isPreview ? _PreviewModeScreen(this) : _EditModeScreen(this);
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

  void setPreview(bool isPreview) {
    setState(() {
      _isPreview = isPreview;
      _uiBuilder =
          _isPreview ? _PreviewModeScreen(this) : _EditModeScreen(this);
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        // ユーザー操作による「戻る」操作
        onWillPop: () {
          if (Navigator.of(context).userGestureInProgress) {
            // iosの戻るジェスチャー
            _save();
            return Future.value(true);
          }
          // iosの戻るジェスチャー意外 == Androidのバックキー
          if (_isPreview) {
            _save();
            return Future.value(true);
          } else {
            setPreview(true);
            return Future.value(false);
          }
        },
        child: Scaffold(
            appBar: AppBar(
              title: Text(widget.ticket.title),
              leading: Builder(
                builder: (BuildContext context) {
                  return _uiBuilder.appBarLeadingIconButton();
                },
              ),
            ),
            body: _uiBuilder.scaffoldBody()));
  }
}

abstract class DetailScreenUiBuilder {
  Widget appBarLeadingIconButton();
  Widget scaffoldBody();
}

class _EditModeScreen extends DetailScreenUiBuilder {
  _DetailScreenState parent;
  _EditModeScreen(this.parent);

  @override
  Widget appBarLeadingIconButton() {
    return IconButton(
      icon: const Icon(Icons.check),
      onPressed: () {
        parent.setPreview(true);
      },
    );
  }

  @override
  Widget scaffoldBody() {
    return SingleChildScrollView(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: TextField(
            controller: parent._titleController,
            decoration: const InputDecoration(
              hintText: 'タイトル',
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: TextFormField(
            controller: parent._bodyController,
            keyboardType: TextInputType.multiline,
            maxLines: null,
            onChanged: parent._onBodyChanged,
            decoration: const InputDecoration(
              border: UnderlineInputBorder(),
              hintText: "本文",
            ),
          ),
        ),
      ],
    ));
  }
}

class _PreviewModeScreen extends DetailScreenUiBuilder {
  _DetailScreenState parent;
  _PreviewModeScreen(this.parent);

  @override
  Widget appBarLeadingIconButton() {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        Navigator.pop(parent.context);
      },
    );
  }

  @override
  Widget scaffoldBody() {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        child: GestureDetector(
            onTap: () {
              parent.setPreview(false);
            },
            child: Markdown(
              data: parent.markdown,
              selectable: true,
              shrinkWrap: true,
              softLineBreak: true,
              onTapText: () {
                parent.setPreview(false);
              },
            )));
  }
}
