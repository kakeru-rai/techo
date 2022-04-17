import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive/hive.dart';

part 'ticket.g.dart';

@HiveType(typeId: 0)
class Ticket {
  @HiveField(0)
  String title;

  @HiveField(1)
  String body;

  Ticket(this.title, this.body);

  @override
  String toString() {
    return "$title:$body";
  }
}
