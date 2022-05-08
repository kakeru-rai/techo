import 'package:cloud_firestore/cloud_firestore.dart';

class Ticket {
  String id;

  String title;

  String body;

  int sort = 0;

  Ticket(this.id, this.title, this.body, this.sort);

  @override
  String toString() {
    return "$id:$title:$body";
  }

  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "body": body,
      "sort": sort,
    };
  }

  static Ticket fromFirestoreSnapshot(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    return Ticket(snapshot.id, snapshot.get("title"), snapshot.get("body"),
        snapshot.data()!.containsKey("sort") ? snapshot.get("sort") : 0);
  }
}
