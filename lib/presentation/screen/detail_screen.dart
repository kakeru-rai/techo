import 'package:flutter/material.dart';
import 'package:flutter_hello_world/domain/ticket_repository.dart';
import 'package:flutter_hello_world/presentation/screen/ticket_provider.dart';
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

final isPreviewProvider = StateProvider.autoDispose<bool>((ref) {
  return true;
});

final markdownProvider = StateProvider.autoDispose<String>((ref) {
  return "";
});

final ticketProvider = StateProvider.autoDispose<Ticket>((ref) {
  return Ticket.nullTicket();
});

class _DetailScreenState extends ConsumerState<DetailScreen> {
  _DetailScreenState();

  late TextEditingController _titleController;
  late TextEditingController _bodyController;

  @override
  void initState() {
    super.initState();
    Ticket ticketState =
        ref.read(ticketProvider.notifier).state = widget.ticket;
    ref.read(markdownProvider.notifier).state = ticketState.body;

    _titleController = TextEditingController(text: ticketState.title);
    _titleController.addListener(() {
      ref.read(ticketProvider.notifier).state =
          ticketState.copyWith(title: _titleController.text);
    });

    _bodyController = TextEditingController(text: ticketState.body);

    ref.read(isPreviewProvider.notifier).state =
        ticketState.body.isEmpty ? false : true;
  }

  void _save() async {
    Ticket ticketState = ref.read(ticketProvider.notifier).state;
    await TicketRepository().upsert(ticketState);
    ref.read(ticketListProvider.notifier).update(ticketState.copyWith());
  }

  void _onBodyChanged(String text) {
    ref.read(markdownProvider.notifier).state = text;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void _setPreviewState(bool isPreview) {
    ref.read(isPreviewProvider.notifier).state = isPreview;
  }

  void _setMdTextStateByMdTag(MdTag tag) {
    var mdTagger = MdTagger(_bodyController.text, tag,
        _bodyController.selection.start, _bodyController.selection.start);
    var text = mdTagger.text;
    _bodyController.text = text;
    ref.read(markdownProvider.notifier).state = text;

    _bodyController.selection = TextSelection.fromPosition(
        TextPosition(offset: mdTagger.currentLineHeadPosition));
  }

  void _pop() {
    _save();
    Navigator.pop(context);
  }

  Future<bool> _onWillPop(bool isPreview) {
    if (Navigator.of(context).userGestureInProgress) {
      // iosの戻るジェスチャー
      _pop();
      return Future.value(false);
    }
    // iosの戻るジェスチャー意外 == Androidのバックキー
    if (isPreview) {
      _pop();
      return Future.value(false);
    } else {
      _setPreviewState(true);
      return Future.value(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isPreview = ref.watch(isPreviewProvider);
    DetailScreenUiBuilder _uiBuilder =
        isPreview ? _PreviewModeScreen(this) : _EditModeScreen(this);
    String markdown = ref.watch(markdownProvider);
    Ticket ticketState = ref.watch(ticketProvider.notifier).state;

    return WillPopScope(
      // ユーザー操作による「戻る」操作
      onWillPop: () {
        return _onWillPop(isPreview);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(ticketState.title),
          leading: Builder(
            builder: (BuildContext context) {
              return _uiBuilder.appBarLeadingIconButton();
            },
          ),
        ),
        body: _uiBuilder.scaffoldBody(markdown),
      ),
    );
  }
}

abstract class DetailScreenUiBuilder {
  Widget appBarLeadingIconButton();
  Widget scaffoldBody(String markdown);
}

class _EditModeScreen extends DetailScreenUiBuilder {
  _DetailScreenState parent;
  _EditModeScreen(this.parent);

  @override
  Widget appBarLeadingIconButton() {
    return IconButton(
      icon: const Icon(Icons.check),
      onPressed: () {
        parent._setPreviewState(true);
      },
    );
  }

  @override
  Widget scaffoldBody(String markdown) {
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
                      parent._setMdTextStateByMdTag(MdTag.header);
                    })),
                OutlinedButton(
                    child: const Text("箇条書き"),
                    onPressed: (() {
                      parent._setMdTextStateByMdTag(MdTag.unorderedList);
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
  Widget scaffoldBody(String markdown) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        child: GestureDetector(
            onTap: () {
              parent._setPreviewState(false);
            },
            child: markdown.isEmpty
                ? const Text("まだ何も入力されていません。タップして入力を開始。",
                    style: TextStyle(color: Colors.black26))
                : Markdown(
                    data: markdown,
                    selectable: true,
                    shrinkWrap: true,
                    softLineBreak: true,
                    onTapText: () {
                      parent._setPreviewState(false);
                    },
                  )));
  }
}
