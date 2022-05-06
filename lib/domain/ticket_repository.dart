import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_hello_world/domain/ticket.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class TicketRepository {
  Future<List<Ticket>> getList() async {
    List<Ticket> tickets = [];
    await _ticketCollection().get().then((QuerySnapshot value) => {
          // ignore: avoid_print
          tickets = List.from(value.docs.map((element) =>
              Ticket(element.id, element.get("title"), element.get("body"))))
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
    await _ticketCollection().doc(ticket.id).update({
      "title": ticket.title,
      "body": ticket.body,
    });
  }

  Future<void> _insert(Ticket ticket) async {
    await _ticketCollection()
        .withConverter<Ticket>(
          fromFirestore: (snapshot, _) => Ticket(
              snapshot.get("id"), snapshot.get("title"), snapshot.get("body")),
          toFirestore: (ticket, _) =>
              {"title": ticket.title, "body": ticket.body},
        )
        .add(ticket)
        .then((value) => ticket.id = value.id);
    return;
  }

  Future<void> delete(Ticket ticket) async {
    await _ticketCollection()
        .doc(ticket.id)
        .delete()
        .then((value) => {print("deleted")})
        .catchError((error) => {print("Failed to delete user: $error")});
    return Future<void>.value();
  }

  CollectionReference<Map<String, dynamic>> _ticketCollection() {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      throw Exception("uidが取得できませんでした");
    }

    return FirebaseFirestore.instance
        .collection("owner")
        .doc(uid)
        .collection("tickets");
  }
}
