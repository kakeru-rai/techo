import 'package:flutter/material.dart';
import 'package:flutter_hello_world/domain/ticket_repository.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../domain/md_tagger.dart';
import '../../domain/ticket.dart';
import 'tickets_provider.dart';

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

final ticketProvider = StateProvider.autoDispose<Ticket>((ref) {
  return Ticket.nullTicket();
});

class _DetailScreenState extends ConsumerState<DetailScreen> {
  _DetailScreenState();

  @override
  void initState() {
    super.initState();
    Ticket ticketState =
        ref.read(ticketProvider.notifier).state = widget.ticket;

    ref.read(isPreviewProvider.notifier).state =
        ticketState.body.isEmpty ? false : true;
  }

  void _save(TextEditingController title, TextEditingController body) async {
    Ticket ticketState = ref
        .read(ticketProvider.notifier)
        .state
        .copyWith(title: title.text, body: body.text);
    await TicketRepository().upsert(ticketState);
    ref.read(ticketsProvider.notifier).update(ticketState);
  }

  void _setPreviewState(
      bool isPreview, TextEditingController title, TextEditingController body) {
    Ticket ticketState = ref.read(ticketProvider.notifier).state;
    ref.read(ticketProvider.notifier).state =
        ticketState.copyWith(title: title.text, body: body.text);
    ref.read(isPreviewProvider.notifier).state = isPreview;
  }

  void _setMdTextStateByMdTag(
      MdTag tag, TextEditingController _bodyController) {
    var mdTagger = MdTagger(_bodyController.text, tag,
        _bodyController.selection.start, _bodyController.selection.start);
    var text = mdTagger.text;
    _bodyController.text = text;
    // ref.read(markdownProvider.notifier).state = text;

    _bodyController.selection = TextSelection.fromPosition(
        TextPosition(offset: mdTagger.currentLineHeadPosition));
  }

  void _pop(TextEditingController title, TextEditingController body) {
    _save(title, body);
    Navigator.pop(context);
  }

  Future<bool> _onWillPop(
      bool isPreview, TextEditingController title, TextEditingController body) {
    if (Navigator.of(context).userGestureInProgress) {
      // iosの戻るジェスチャー
      _pop(title, body);
      return Future.value(false);
    }
    // iosの戻るジェスチャー意外 == Androidのバックキー
    if (isPreview) {
      _pop(title, body);
      return Future.value(false);
    } else {
      _setPreviewState(true, title, body);
      return Future.value(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isPreview = ref.watch(isPreviewProvider);
    DetailScreenUiBuilder _uiBuilder =
        isPreview ? _PreviewModeScreen(this) : _EditModeScreen(this);

    Ticket ticketState = ref.watch(ticketProvider.notifier).state;

    final _titleController_ = useTextEditingController(text: ticketState.title);
    final _bodyController = TextEditingController(text: ticketState.body);

    return WillPopScope(
      // ユーザー操作による「戻る」操作
      onWillPop: () {
        return _onWillPop(isPreview, _titleController_, _bodyController);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(ticketState.title),
          leading: Builder(
            builder: (BuildContext context) {
              return _uiBuilder.appBarLeadingIconButton(
                  _titleController_, _bodyController);
            },
          ),
        ),
        body: _uiBuilder.scaffoldBody(_titleController_, _bodyController),
      ),
    );
  }
}

abstract class DetailScreenUiBuilder {
  Widget appBarLeadingIconButton(TextEditingController _titleController_,
      TextEditingController bodyController);
  Widget scaffoldBody(TextEditingController _titleController_,
      TextEditingController bodyController);
}

class _EditModeScreen extends DetailScreenUiBuilder {
  _DetailScreenState parent;
  _EditModeScreen(this.parent);

  @override
  Widget appBarLeadingIconButton(
      TextEditingController title, TextEditingController body) {
    return IconButton(
      icon: const Icon(Icons.check),
      onPressed: () {
        parent._setPreviewState(true, title, body);
      },
    );
  }

  @override
  Widget scaffoldBody(TextEditingController _titleController_,
      TextEditingController bodyController) {
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
                      controller: _titleController_,
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
                        controller: bodyController,
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        // onChanged: parent._onBodyChanged,
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
                      parent._setMdTextStateByMdTag(
                          MdTag.header, bodyController);
                    })),
                OutlinedButton(
                    child: const Text("箇条書き"),
                    onPressed: (() {
                      parent._setMdTextStateByMdTag(
                          MdTag.unorderedList, bodyController);
                    })),
              ]))
        ]));
  }
}

class _PreviewModeScreen extends DetailScreenUiBuilder {
  _DetailScreenState parent;
  _PreviewModeScreen(this.parent);

  @override
  Widget appBarLeadingIconButton(TextEditingController _titleController_,
      TextEditingController bodyController) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        parent._pop(_titleController_, bodyController);
      },
    );
  }

  @override
  Widget scaffoldBody(TextEditingController title, TextEditingController body) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        child: GestureDetector(
            onTap: () {
              parent._setPreviewState(false, title, body);
            },
            child: body.text.isEmpty
                ? const Text("まだ何も入力されていません。タップして入力を開始。",
                    style: TextStyle(color: Colors.black26))
                : Markdown(
                    data: body.text,
                    selectable: true,
                    shrinkWrap: true,
                    softLineBreak: true,
                    onTapText: () {
                      parent._setPreviewState(false, title, body);
                    },
                  )));
  }
}
