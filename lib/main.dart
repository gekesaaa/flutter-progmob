// import 'dart:js';

import 'dart:async';

import 'package:get_storage/get_storage.dart';
import 'package:coba_login/login_page.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  await GetStorage.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/': (context) => LoginPage(),
      },
      initialRoute: '/',
    );
  }
}
