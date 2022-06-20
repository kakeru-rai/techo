import 'package:cloud_firestore/cloud_firestore.dart';

class Ticket {
  final String id;

  final String title;

  final String body;

  final int sort;

  Ticket(
      {required this.id,
      required this.title,
      required this.body,
      required this.sort});

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

  Ticket copyWith({String? id, String? title, String? body, int? sort}) {
    return Ticket(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      sort: sort ?? this.sort,
    );
  }

  static Ticket fromFirestoreSnapshot(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    return Ticket(
        id: snapshot.id,
        title: snapshot.get("title"),
        body: snapshot.get("body"),
        sort: snapshot.data()!.containsKey("sort") ? snapshot.get("sort") : 0);
  }
}
