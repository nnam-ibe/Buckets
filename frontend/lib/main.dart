import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/models/environment.dart';
import 'package:frontend/pages/bucket_form_page.dart';
import 'package:frontend/pages/buckets_page.dart';
import 'package:frontend/pages/goal_form_page.dart';
import 'package:provider/provider.dart';
import 'package:frontend/common/theme.dart';
import 'package:frontend/pages/authentication/login_page.dart';
import 'package:frontend/api/authentication/session.dart';

Future<void> main() async {
  await dotenv.load(fileName: Environment.fileName);

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
        LoginPage.routeName: (context) => const LoginPage(),
        BucketsPage.routeName: (context) => const BucketsPage(),
        BucketFormPage.routeName: (context) => const BucketFormPage(),
        GoalFormPage.routeName: (context) => const GoalFormPage(),
      },
    );
  }
}
