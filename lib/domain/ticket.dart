import 'package:cloud_firestore/cloud_firestore.dart';

class Ticket {
  String id;

  String title;

  String body;

  Ticket(this.id, this.title, this.body);

  @override
  String toString() {
    return "$id:$title:$body";
  }

  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "body": body,
    };
  }

  static Ticket fromFirestoreSnapshot(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    return Ticket(snapshot.id, snapshot.get("title"), snapshot.get("body"));
  }
}
