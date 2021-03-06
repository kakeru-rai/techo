import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../domain/ticket.dart';
import '../../domain/ticket_repository.dart';
import '../../infrastructure/firebase_auth_adapter.dart';
import '../login_user.dart';
import 'detail_screen.dart';
import 'tickets_provider.dart';
import 'webview_screen.dart';
import 'welcome_screen.dart';

final loginUserProvider =
    StateProvider<LoginUser>((ref) => LoginUser("", true));

class ListScreen extends StatefulHookConsumerWidget {
  static const routeName = "ListScreen";

  const ListScreen({Key? key}) : super(key: key);

  @override
  _ListScreenState createState() => _ListScreenState();
}

class _ListScreenState extends ConsumerState<ListScreen> {
  @override
  void initState() {
    super.initState();
    _setLoginUserState(FirebaseAuthAdapter.getUser()!);
    Future(() async {
      await _fetchTickets();
    });
  }

  void _onTicketAddTapped(TextEditingController _titleController) async {
    if (_titleController.text.isEmpty) {
      return;
    }

    var title = _titleController.text;
    _titleController.text = "";
    var newTicket = await TicketRepository()
        .upsert(Ticket(id: "", title: title, body: "", sort: 0));
    ref.read(ticketsProvider.notifier).insert(newTicket);
    _updateSort(ref.read(ticketsProvider));
  }

  void _onListItemTapped(BuildContext context, int index) async {
    await DetailScreenNavigation.push(
        context, ref.read(ticketsProvider)[index]);
  }

  void _onListItemDeleteTapped(Ticket ticket) async {
    await TicketRepository().delete(ticket);

    ref.read(ticketsProvider.notifier).delete(ticket);
    _updateSort(ref.read(ticketsProvider));

    _setLoginUserState(FirebaseAuthAdapter.getUser()!);
  }

  void _onReorder(int oldIndex, int newIndex) {
    ref.read(ticketsProvider.notifier).reorder(oldIndex, newIndex);
    _updateSort(ref.read(ticketsProvider));
  }

  void _onLogoutTapped() async {
    await FirebaseAuthAdapter.signOut();
    await FirebaseAuthAdapter.signInWithAnonymous();
    _fetchTickets();
    _setLoginUserState(FirebaseAuthAdapter.getUser()!);
  }

  void _onLoginTapped(BuildContext context) async {
    bool isLoginSucceeded = await FirebaseAuthAdapter.signInWithGoogle();
    if (isLoginSucceeded) {
      Navigator.pop(context); // ????????????????????????
      _fetchTickets();
      _setLoginUserState(FirebaseAuthAdapter.getUser()!);
    }
  }

  Future<void> _setLoginUserState(User user) async {
    ref.read(loginUserProvider.notifier).state =
        LoginUser.fromFirebaseUser(user);
  }

  Future<void> _fetchTickets() async {
    ref
        .read(ticketsProvider.notifier)
        .setList(await TicketRepository().getList());
  }

  @override
  Widget build(BuildContext context) {
    final tickets = ref.watch<List<Ticket>>(ticketsProvider);
    final loginUser = ref.watch(loginUserProvider);

    final _titleController = useTextEditingController();

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("??????"),
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
                          loginUser.isAnonymous
                              ? Icons.account_circle
                              : Icons.face,
                          size: 80.0),
                      Text(loginUser.userName),
                    ],
                  ),
                ),
                loginUser.isAnonymous
                    ? SignInButton(
                        Buttons.Google,
                        onPressed: () {
                          _onLoginTapped(context);
                        },
                      )
                    : ListTile(
                        leading: const Icon(Icons.logout),
                        title: const Text('???????????????'),
                        onTap: () {
                          _onLogoutTapped();
                        }),
                ListTile(
                    title: const Text('????????????'),
                    onTap: () async {
                      WebViewScreenNavigation.pushTerm(context);
                    }),
                ListTile(
                    title: const Text('??????????????????????????????'),
                    onTap: () async {
                      WebViewScreenNavigation.pushPrivacy(context);
                    }),
                ListTile(
                    title: const Text('?????????'),
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
                for (int index = 0; index < tickets.length; ++index)
                  ListTile(
                    key: Key(tickets[index].id),
                    onTap: () {
                      _onListItemTapped(context, index);
                    },
                    title: Text(tickets[index].title),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        _onListItemDeleteTapped(tickets[index]);
                      },
                    ),
                  )
              ],
              onReorder: _onReorder,
            ),
          ),
          Container(
            // ???????????????????????????
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
                    onEditingComplete: () =>
                        {_onTicketAddTapped(_titleController)},
                    autofocus: false,
                    controller: _titleController,
                    style: const TextStyle(fontSize: 14),
                    decoration: const InputDecoration(
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      hintText: '????????????',
                      hintStyle: TextStyle(fontSize: 14, color: Colors.black26),
                      border: InputBorder.none,
                    ),
                  )),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => {_onTicketAddTapped(_titleController)},
                  )
                ]),
              ),
            ),
          )
        ]),
      ),
    );
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
