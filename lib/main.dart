import 'package:firebase_auth/firebase_auth.dart';
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

  if (FirebaseAuth.instance.currentUser == null) {
    await _signInWithAnonymous();
  }

  runApp(const MyApp());
}

Future<UserCredential> _signInWithAnonymous() async {
  return FirebaseAuth.instance.signInAnonymously();
}
