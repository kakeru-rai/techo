import 'package:flutter_hello_world/domain/ticket.dart';
import 'package:hive/hive.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class TicketRepository {
  Future<List<Ticket>> getList() async {
    print("getList");
    List<Ticket> tickets = [];
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    await firestore
        .collection("documents")
        .get()
        .then((QuerySnapshot value) => {
              // ignore: avoid_print
              tickets = List.from(value.docs.map((element) => Ticket(
                  element.id, element.get("title"), element.get("body"))))
            });

    return Future<List<Ticket>>.value(tickets);
  }

  void upsert(Ticket ticket) async {
    if (ticket.id.isEmpty) {
      await _insert(ticket);
    } else {
      await _update(ticket);
    }
  }

  Future<void> _update(Ticket ticket) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    await firestore.collection("documents").doc(ticket.id).update({
      "title": ticket.title,
      "body": ticket.body,
    });
  }

  Future<void> _insert(Ticket ticket) async {
    final ref = FirebaseFirestore.instance
        .collection('documents')
        .withConverter<Ticket>(
          fromFirestore: (snapshot, _) => Ticket(
              snapshot.get("id"), snapshot.get("title"), snapshot.get("body")),
          toFirestore: (ticket, _) =>
              {"title": ticket.title, "body": ticket.body},
        );
    await ref.add(ticket).then((value) => ticket.id = value.id);
  }

  Future<void> delete(Ticket ticket) async {
    print("repo delete");
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    await firestore
        .collection("documents")
        .doc(ticket.id)
        .delete()
        // ignore: avoid_print
        .then((value) => {print("deleted")})
        .catchError((error) => print("Failed to delete user: $error"));
    return Future<void>.value();
  }

  Future<Box<Ticket>> _openbox() async {
    return await Hive.openBox<Ticket>('ticket');
  }
}
