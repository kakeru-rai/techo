import 'package:flutter/material.dart';
import 'package:flutter_hello_world/domain/ticket_repository.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../domain/md_tagger.dart';
import '../../domain/ticket.dart';

class DetailScreen extends StatefulHookConsumerWidget {
  static const String routeName = "DetailScreen";

  const DetailScreen({Key? key, required this.ticket}) : super(key: key);
  final Ticket ticket;

  @override
  ConsumerState createState() => _DetailScreenState();
}

extension DetailScreenNavigation on DetailScreen {
  static Future<Ticket?> push(BuildContext context, Ticket ticket) async {
    return Navigator.pushNamed<Ticket?>(context, DetailScreen.routeName,
        arguments: ticket);
  }
}

class _DetailScreenState extends ConsumerState<DetailScreen> {
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
    _titleController.addListener(() {
      widget.ticket.title = _titleController.text;
    });

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

  void _setStatePreview(bool isPreview) {
    setState(() {
      _isPreview = isPreview;
      _uiBuilder =
          _isPreview ? _PreviewModeScreen(this) : _EditModeScreen(this);
    });
  }

  void _setStateMdTag(MdTag tag) {
    setState(() {
      var mdTagger = MdTagger(_bodyController.text, tag,
          _bodyController.selection.start, _bodyController.selection.start);
      var text = mdTagger.text;
      _bodyController.text = text;
      markdown = text;

      _bodyController.selection = TextSelection.fromPosition(
          TextPosition(offset: mdTagger.currentLineHeadPosition));
    });
  }

  void _pop() {
    _save();
    Navigator.pop(context, widget.ticket);
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
          _setStatePreview(true);
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
        body: _uiBuilder.scaffoldBody(),
      ),
    );
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
        parent._setStatePreview(true);
      },
    );
  }

  @override
  Widget scaffoldBody() {
    return Container(
        color: Colors.grey[100],
        child: Column(children: [
          Expanded(
              child: SingleChildScrollView(
                  child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                  child: Container(
                    color: Colors.white,
                    child: TextField(
                      controller: parent._titleController,
                      decoration: const InputDecoration(
                        hintText: 'タイトル',
                      ),
                    ),
                  )),
              Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                  child: Container(
                      color: Colors.white,
                      child: TextFormField(
                        controller: parent._bodyController,
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        onChanged: parent._onBodyChanged,
                        decoration: const InputDecoration(
                          border: UnderlineInputBorder(),
                          hintText: "本文",
                        ),
                      ))),
            ],
          ))),
          Container(
              decoration: const BoxDecoration(
                color: Colors.white70,
              ),
              child: Row(children: [
                OutlinedButton(
                    child: const Text("見出し"),
                    onPressed: (() {
                      parent._setStateMdTag(MdTag.header);
                    })),
                OutlinedButton(
                    child: const Text("箇条書き"),
                    onPressed: (() {
                      parent._setStateMdTag(MdTag.unorderedList);
                    })),
              ]))
        ]));
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
        parent._pop();
      },
    );
  }

  @override
  Widget scaffoldBody() {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        child: GestureDetector(
            onTap: () {
              parent._setStatePreview(false);
            },
            child: parent.markdown.isEmpty
                ? const Text("まだ何も入力されていません。タップして入力を開始。",
                    style: TextStyle(color: Colors.black26))
                : Markdown(
                    data: parent.markdown,
                    selectable: true,
                    shrinkWrap: true,
                    softLineBreak: true,
                    onTapText: () {
                      parent._setStatePreview(false);
                    },
                  )));
  }
}