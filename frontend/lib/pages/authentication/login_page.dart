import 'package:flutter/material.dart';
import 'package:frontend/api/api_response.dart';
import 'package:frontend/api/authentication/auth_client.dart';
import 'package:frontend/api/authentication/session.dart';
import 'package:frontend/common/helpers.dart' as helpers;
import 'package:frontend/models/user.dart';
import 'package:frontend/pages/buckets_page.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  static const routeName = '/login';

  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
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

  void onLoginClick() async {
    if (_formKey.currentState!.validate()) {
      var authClient = AuthClient();
      ApiResponse apiResponse = await authClient.login(
          username: usernameController.text, password: passwordController.text);
      if (apiResponse.wasSuccessful()) {
        var responseData = apiResponse.getDataAsMap();
        var user = User.fromMap(responseData['user']);
        String token = responseData['token'];
        AuthClient.token = token;
        updateUserProvider(user, token);
        await helpers.setUserPrefernces(user, token);
        Navigator.of(context).pushReplacementNamed(BucketsPage.routeName);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(apiResponse.getError())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    controller: usernameController, labelText: 'Username'),
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
  }
}
