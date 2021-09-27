import 'package:flutter/material.dart';
import 'package:frontend/pages/buckets_page.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/common/theme.dart';
import 'package:frontend/pages/authentication/login_page.dart';
import 'package:frontend/api/authentication/session.dart';

void main() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  // TODO: Move hardcoded string to config file.
  await prefs.setString('baseUrl', "http://127.0.0.1:8000/api/");

  runApp(
    ChangeNotifierProvider(
      create: (context) => UserSession(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'Login',
      theme: appTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/buckets': (context) => const BucketsPage(),
      },
    );
  }
}
