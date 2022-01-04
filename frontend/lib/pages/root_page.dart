import 'package:flutter/material.dart';
import 'package:frontend/api/authentication/auth_client.dart';
import 'package:frontend/api/authentication/session.dart';
import 'package:frontend/common/helpers.dart' as helpers;
import 'package:frontend/models/user.dart';
import 'package:frontend/pages/authentication/login_page.dart';
import 'package:frontend/pages/buckets_page.dart';
import 'package:provider/provider.dart';

class RootPage extends StatefulWidget {
  static const routeName = '/';
  const RootPage({Key? key}) : super(key: key);

  @override
  _RootPageState createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  UserStatus userStatus = UserStatus.notDetermined;

  @override
  void initState() {
    super.initState();
    updateUserStatus().then((bool isLoggedIn) => {
          setState(() {
            if (isLoggedIn) {
              userStatus = UserStatus.loggedIn;
            } else {
              userStatus = UserStatus.notLoggedIn;
            }
          })
        });
  }

  bool updateUserProvider(User? user, String? token) {
    if (user == null || token == null) {
      return false;
    }
    AuthClient.token = token;
    Provider.of<UserSession>(
      context,
      listen: false,
    ).setUser(user: user, token: token);
    return true;
  }

  Future<bool> updateUserStatus() async {
    late User? user;
    late String? token;
    await Future.wait([
      helpers.getUserFromPrefrences().then((value) => user = value),
      helpers.getTokenFromPreferences().then((value) => token = value),
    ]);
    return updateUserProvider(user, token);
  }

  @override
  Widget build(BuildContext context) {
    switch (userStatus) {
      case UserStatus.loggedIn:
        return const BucketsPage();
      case UserStatus.notLoggedIn:
        return const LoginPage();
      default:
        return Scaffold(
          body: Center(
            child: Container(
              alignment: Alignment.center,
              child: const CircularProgressIndicator(),
            ),
          ),
        );
    }
  }
}

enum UserStatus {
  loggedIn,
  notLoggedIn,
  notDetermined,
}
