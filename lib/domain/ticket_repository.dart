import 'package:firebase_auth/firebase_auth.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../shared/logger.dart';
import 'ticket.dart';

class TicketRepository {
  Future<List<Ticket>> getList() async {
    List<Ticket> tickets = [];
    await _ticketCollection().orderBy("sort", descending: true).get().then(
        (QuerySnapshot<Ticket> value) =>
            {tickets = List.from(value.docs.map((element) => element.data()))});

    return Future<List<Ticket>>.value(tickets);
  }

  Future<Ticket> upsert(Ticket ticket) async {
    if (ticket.id.isEmpty) {
      return await _insert(ticket);
    } else {
      return await _update(ticket);
    }
  }

  Future<Ticket> _update(Ticket ticket) async {
    await _ticketCollection().doc(ticket.id).set(ticket);
    return ticket.copyWith();
  }

  Future<Ticket> _insert(Ticket ticket) async {
    Ticket? newTicket;
    await _ticketCollection()
        .add(ticket)
        .then((value) => {value.get().then((v) => newTicket = v.data())});
    return newTicket!;
  }

  Future<void> delete(Ticket ticket) async {
    await _ticketCollection()
        .doc(ticket.id)
        .delete()
        .then((value) => {logger.d("deleted")})
        .catchError((error) => {logger.e("Failed to delete user: $error")});
    return Future<void>.value();
  }

  CollectionReference<Ticket> _ticketCollection() {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      throw Exception("uidが取得できませんでした");
    }

    return FirebaseFirestore.instance
        .collection("owner")
        .doc(uid)
        .collection("tickets")
        .withConverter<Ticket>(
          fromFirestore: (snapshot, _) =>
              Ticket.fromFirestoreSnapshot(snapshot),
          toFirestore: (ticket, _) => ticket.toJson(),
        );
  }
}
