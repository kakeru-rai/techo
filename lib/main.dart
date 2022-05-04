import 'package:flutter/material.dart';
import 'my_app.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'domain/ticket.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(TicketAdapter());

  runApp(const MyApp());
}
