import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'ticket.freezed.dart';
part 'ticket.g.dart';

@freezed
class Ticket with _$Ticket {
  const factory Ticket({
    required String id,
    required String title,
    required String body,
    required int sort,
  }) = _Ticket;

  factory Ticket.fromJson(Map<String, Object?> json) => _$TicketFromJson(json);

  static Ticket fromFirestoreSnapshot(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    return Ticket(
        id: snapshot.id,
        title: snapshot.get("title"),
        body: snapshot.get("body"),
        sort: snapshot.data()!.containsKey("sort") ? snapshot.get("sort") : 0);
  }
}
