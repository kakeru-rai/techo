import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../domain/ticket.dart';
import '../../domain/ticket_repository.dart';
import '../../infrastructure/firebase_auth_adapter.dart';
import '../login_user.dart';
import 'detail_screen.dart';
import 'webview_screen.dart';
import 'welcome_screen.dart';

class TicketNotifier extends StateNotifier<List<Ticket>> {
  TicketNotifier() : super([]);

  void getList(List<Ticket> tickets) {
    state = tickets;
  }

  void delete(Ticket ticket) {
    var newItems = [
      for (final aTicket in state)
        if (ticket.id != aTicket.id) aTicket,
    ];
    state = _updateSort(newItems);
  }

  void insert(String title) {
    var newItems = [Ticket(id: "", title: title, body: "", sort: 0), ...state];
    state = _updateSort(newItems);
  }

  void reorder(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    var newItems = [...state];
    final Ticket item = newItems.removeAt(oldIndex);
    newItems.insert(newIndex, item);

    state = _updateSort(newItems);
  }

  List<Ticket> _updateSort(List<Ticket> _items) {
    List<Ticket> newItems = [];
    int lastIndex = _items.length - 1;
    _items.asMap().forEach((index, ticket) {
      int newSort = lastIndex - index;
      if (ticket.sort == newSort) {
        return;
      }
      newItems.add(ticket.copyWith(sort: newSort));
    });
    newItems.sort((a, b) {
      return a.sort - b.sort;
    });
    return [..._items];
  }
}

final _itemsProvider =
    StateNotifierProvider.autoDispose<TicketNotifier, List<Ticket>>(
        (ref) => TicketNotifier());

class ListScreen extends StatefulHookConsumerWidget {
  static const routeName = "ListScreen";

  const ListScreen({Key? key}) : super(key: key);

  @override
  _ListScreenState createState() => _ListScreenState();
}

class _ListScreenState extends ConsumerState<ListScreen> {
  LoginUser _loginUser =
      LoginUser.fromFirebaseUser(FirebaseAuthAdapter.getUser()!);
  late TextEditingController _titleController;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController();
    Future(() async {
      ref
          .read(_itemsProvider.notifier)
          .getList(await TicketRepository().getList());
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _onTicketAddTapped() {
    if (_titleController.text.isEmpty) {
      return;
    }

    ref.read(_itemsProvider.notifier).insert(_titleController.text);
    _updateSort(ref.read(_itemsProvider));

    _titleController.text = "";
  }

  void _onListItemTapped(BuildContext context, int index) async {
    // 返り値を変数に入れないと待ってくれないので
    // ignore: unused_local_variable

    // Ticket? result = await DetailScreenNavigation.push(context, _items[index]);

    // if (result != null) {
    //   _items[index] = result;
    // }

    _setStateInitView();
  }

  void _onListItemDeleteTapped(Ticket ticket) async {
    await TicketRepository().delete(ticket);

    ref.read(_itemsProvider.notifier).delete(ticket);
    _updateSort(ref.read(_itemsProvider));

    _setStateInitView();
  }

  void _onReorder(int oldIndex, int newIndex) {
    ref.read(_itemsProvider.notifier).reorder(oldIndex, newIndex);
    _updateSort(ref.read(_itemsProvider));
  }

  void _onLogoutTapped() async {
    await FirebaseAuthAdapter.signOut();
    await FirebaseAuthAdapter.signInWithAnonymous();
    _setStateInitView();
  }

  void _onLoginTapped(BuildContext context) async {
    bool isLoginSucceeded = await FirebaseAuthAdapter.signInWithGoogle();
    if (isLoginSucceeded) {
      Navigator.pop(context);
      _setStateInitView();
    }
  }

  Future<void> _setStateInitView() async {
    _loginUser = LoginUser.fromFirebaseUser(FirebaseAuthAdapter.getUser()!);
  }

  @override
  Widget build(BuildContext context) {
    final _items = ref.watch<List<Ticket>>(_itemsProvider);

    return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          appBar: AppBar(
            title: const Text("メモ"),
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
                    child: Column(
                      children: [
                        Icon(
                            _loginUser.isAnonymous
                                ? Icons.account_circle
                                : Icons.face,
                            size: 80.0),
                        Text(_loginUser.userName),
                      ],
                    ),
                  ),
                  _loginUser.isAnonymous
                      ? SignInButton(
                          Buttons.Google,
                          onPressed: () {
                            _onLoginTapped(context);
                          },
                        )
                      : ListTile(
                          leading: const Icon(Icons.logout),
                          title: const Text('ログアウト'),
                          onTap: () {
                            _onLogoutTapped();
                          }),
                  ListTile(
                      title: const Text('利用規約'),
                      onTap: () async {
                        WebViewScreenNavigation.pushTerm(context);
                      }),
                  ListTile(
                      title: const Text('プライバシーポリシー'),
                      onTap: () async {
                        WebViewScreenNavigation.pushPrivacy(context);
                      }),
                  ListTile(
                      title: const Text('初期化'),
                      onTap: () async {
                        await FirebaseAuthAdapter.signOut();
                        Navigator.pushReplacementNamed(
                            context, WelcomeScreen.routeName);
                      }),
                ]),
          ),
          body: Column(children: [
            Expanded(
              child: ReorderableListView(
                children: <Widget>[
                  for (int index = 0; index < _items.length; ++index)
                    ListTile(
                      key: Key(_items[index].id),
                      onTap: () {
                        _onListItemTapped(context, index);
                      },
                      title: Text(_items[index].title),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          _onListItemDeleteTapped(_items[index]);
                        },
                      ),
                    )
                ],
                onReorder: _onReorder,
              ),
            ),
            Container(
                // ボトム入力フォーム
                color: Colors.grey[200],
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: Colors.white70,
                    ),
                    child: SizedBox(
                        height: 40,
                        child: Row(children: [
                          Expanded(
                              child: TextField(
                            onEditingComplete: _onTicketAddTapped,
                            autofocus: false,
                            controller: _titleController,
                            style: const TextStyle(fontSize: 14),
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 12),
                              hintText: 'タイトル',
                              hintStyle: TextStyle(
                                  fontSize: 14, color: Colors.black26),
                              border: InputBorder.none,
                            ),
                          )),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: _onTicketAddTapped,
                          )
                        ]))))
          ]),
        ));
  }
}

void _updateSort(List<Ticket> _items) {
  int lastIndex = _items.length - 1;
  _items.asMap().forEach((index, ticket) {
    int newSort = lastIndex - index;
    if (ticket.sort == newSort) {
      return;
    }
    TicketRepository().upsert(ticket.copyWith(sort: newSort));
  });
}
