import 'package:flutter_hello_world/domain/ticket.dart';
import 'package:hive/hive.dart';

class TicketRepository {
  Future<List<Ticket>> getList() async {
    print("getList");
    var box = await Hive.openBox<Ticket>('ticket');
    print(box.values);

    return Future<List<Ticket>>.value(List.from(box.values));
  }

  void put(Ticket ticket) async {
    var box = await Hive.openBox<Ticket>('ticket');
    box.put(ticket.title, ticket);
  }

  Future<void> delete(Ticket ticket) async {
    var box = await _openbox();
    box.delete(ticket.title);
    return Future<void>.value();
  }

  Future<Box<Ticket>> _openbox() async {
    return await Hive.openBox<Ticket>('ticket');
  }
}
