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

  void _setStateMdTag(String tag) {
    setState(() {
      var newCusorPosition = currentLineHeadPosition(
          _bodyController.text, _bodyController.selection.start);
      var text =
          addMdTag(_bodyController.text, tag, _bodyController.selection.start);
      _bodyController.text = text;

      _bodyController.selection =
          TextSelection.fromPosition(TextPosition(offset: newCusorPosition));
    });
  }

  void _pop() {
    _save();
    Navigator.pop(context);
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

int currentLineHeadPosition(String text, int cursorPosition) {
  if (text.length < cursorPosition || cursorPosition < 0) {
    throw Exception(
        "Invalid cursorPosition: cursorPosition=$cursorPosition, textLength=${text.length}");
  }
  // カーソル位置までに現れる最後の改行
  var textToCursorPosition = text.substring(0, cursorPosition);
  var match = RegExp(r"[\s\S]*\n").firstMatch(textToCursorPosition);
  if (match == null) {
    // 改行がなければ文字列の先頭
    return 0;
  }

  String matchText = match.group(0)!;
  int lineHeadPosition = matchText.length;
  var lines = textToCursorPosition.split("\n");
  String lineText = lines[lines.length - 1];
  int lineCount = lines.length;

  return lineHeadPosition;
}

String addMdTag(String text, String tag, int cursorPosition) {
  int addPosition = currentLineHeadPosition(text, cursorPosition);

  var textToCursorPosition = text.substring(0, cursorPosition);
  var cursorLineCount = textToCursorPosition.split("\n").length - 1;
  String lineText = text.split("\n")[cursorLineCount];
  var match = RegExp(r"\" + tag + "+? ").firstMatch(lineText);
  var addTagText = match == null ? tag + " " : tag;

  return text.substring(0, addPosition) +
      addTagText +
      text.substring(addPosition);
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
                    child: Text("見出し"),
                    onPressed: (() {
                      parent._setStateMdTag("#");
                    })),
                OutlinedButton(
                    child: Text("・"),
                    onPressed: (() {
                      parent._setStateMdTag("-");
                    })),
                OutlinedButton(
                    child: Text("1."),
                    onPressed: (() {
                      parent._setStateMdTag("1.");
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
