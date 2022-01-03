import 'package:flutter/material.dart';
import 'package:frontend/api/api_response.dart';
import 'package:frontend/api/authentication/auth_client.dart';
import 'package:frontend/api/authentication/session.dart';
import 'package:frontend/models/user.dart';
import 'package:frontend/pages/buckets_page.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/common/helpers.dart' as helpers;

class LoginPage extends StatefulWidget {
  static const routeName = '/';

  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late Future<bool> isLoggedIn;

  @override
  void initState() {
    super.initState();
    isLoggedIn = checkUserLoggedIn();
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Widget getTextFieldWidget(
      {required TextEditingController controller,
      required String labelText,
      bool obscureText = false}) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: labelText,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a $labelText';
        }
        return null;
      },
    );
  }

  void updateUserProvider(User user, String token) {
    Provider.of<UserSession>(
      context,
      listen: false,
    ).setUser(user: user, token: token);
  }

  Future<bool> checkUserLoggedIn() async {
    User? user = await helpers.getUserFromPrefrences();
    String? token = await helpers.getTokenFromPreferences();
    if (user == null || token == null) return false;
    updateUserProvider(user, token);
    return true;
  }

  void onLoginClick() async {
    if (_formKey.currentState!.validate()) {
      var authClient = AuthClient();
      ApiResponse apiResponse = await authClient.login(
          username: usernameController.text, password: passwordController.text);
      if (apiResponse.wasSuccessful()) {
        var responseData = apiResponse.getDataAsMap();
        var user = User.fromMap(responseData['user']);
        String token = responseData['token'];
        updateUserProvider(user, token);
        await helpers.setUserPrefernces(user, token);
        Navigator.of(context).pushNamed(BucketsPage.routeName);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(apiResponse.getError())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
        future: isLoggedIn,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data!) {
              Navigator.of(context).pushNamed(BucketsPage.routeName);
            }
            return Scaffold(
              body: Center(
                child: Container(
                  padding: const EdgeInsets.all(80.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Welcome',
                          style: Theme.of(context).textTheme.headline1,
                        ),
                        getTextFieldWidget(
                            controller: usernameController,
                            labelText: 'Username'),
                        getTextFieldWidget(
                            controller: passwordController,
                            labelText: 'Password',
                            obscureText: true),
                        const SizedBox(
                          height: 24,
                        ),
                        ElevatedButton(
                          child: const Text('Login'),
                          onPressed: onLoginClick,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          } else if (snapshot.hasError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('${snapshot.error}'),
            ));
          }
          return const CircularProgressIndicator();
        });
  }
}
