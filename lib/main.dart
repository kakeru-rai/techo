import 'package:flutter/material.dart';
import 'my_app.dart';

import 'package:firebase_core/firebase_core.dart';
import 'gen/firebase_options_dev.dart';

import 'shared/logger.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  logger.d("main");

  runApp(const MyApp());
}
