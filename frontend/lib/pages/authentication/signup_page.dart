import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:frontend/api/api_response.dart';
import 'package:frontend/api/authentication/auth_client.dart';
import 'package:frontend/api/authentication/session.dart';
import 'package:frontend/common/constants.dart';
import 'package:frontend/common/helpers.dart';
import 'package:frontend/models/user.dart';
import 'package:frontend/pages/buckets_page.dart';
import 'package:frontend/pages/widgets/widget_factory.dart';
import 'package:provider/provider.dart';

class SignUpPage extends StatefulWidget {
  static const routeName = '/sign_up';
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    emailController.dispose();
    super.dispose();
  }

  void updateUserProvider(User user, String token) {
    Provider.of<UserSession>(
      context,
      listen: false,
    ).setUser(user: user, token: token);
  }

  void onSignUpClick() async {
    if (_formKey.currentState!.validate()) {
      var authClient = AuthClient();
      ApiResponse apiResponse = await authClient.createAccount(
          username: usernameController.text,
          password: passwordController.text,
          email: emailController.text);
      if (apiResponse.wasSuccessful()) {
        var responseData = apiResponse.getDataAsMap();
        var user = User.fromMap(responseData['user']);
        String token = responseData['token'];
        AuthClient.token = token;
        updateUserProvider(user, token);
        Navigator.of(context).pushReplacementNamed(BucketsPage.routeName);
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(apiResponse.getError())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Create Account',
                  style: Theme.of(context).textTheme.headline1,
                ),
                textFieldWidget(
                    controller: emailController,
                    labelText: 'Email',
                    additionalValidation: (value) {
                      bool isValid = EmailValidator.validate(value);
                      if (!isValid) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    }),
                textFieldWidget(
                    controller: usernameController, labelText: 'Username'),
                textFieldWidget(
                    controller: passwordController,
                    labelText: 'Password',
                    obscureText: true,
                    additionalValidation: (value) {
                      if (!minimumLengthValidator(passwordMinLength, value)) {
                        return 'Password must have at least $passwordMinLength characters';
                      }
                      return null;
                    }),
                textFieldWidget(
                    controller: confirmPasswordController,
                    labelText: 'Confirm Password',
                    obscureText: true,
                    additionalValidation: (value) {
                      if (passwordController.text != value) {
                        return 'Passwords must match';
                      }
                      return null;
                    }),
                const SizedBox(
                  height: 24,
                ),
                ElevatedButton(
                  child: const Text('Sign Up'),
                  onPressed: onSignUpClick,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
