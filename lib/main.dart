import 'package:flutter/material.dart';
import 'MyAppp.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'domain/ticket.dart';

Future<void> main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(TicketAdapter());
  runApp(const MyApp());
}
