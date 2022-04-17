import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/api/api_response.dart';
import 'package:frontend/api/authentication/auth_client.dart';
import 'package:frontend/pages/authentication/signup_page.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../utils.dart';
import 'signup_page_test.mocks.dart';

@GenerateMocks([AuthClient],
    customMocks: [MockSpec<NavigatorObserver>(returnNullOnMissingStub: true)])
void main() {
  group('SignUp Page', () {
    testWidgets('should have form elements', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetObserver(const SignUpPage()).widget);

      final welcomeFinder = find.text('Create Account');
      expect(welcomeFinder, findsOneWidget);

      final emailFinder = find.text('Email');
      expect(emailFinder, findsOneWidget);

      final usernameFinder = find.text('Username');
      expect(usernameFinder, findsOneWidget);

      final passwordFinder = find.text('Password');
      expect(passwordFinder, findsOneWidget);

      final confirmPasswordFinder = find.text('Confirm Password');
      expect(confirmPasswordFinder, findsOneWidget);

      final signUpButtonFinder = find.widgetWithText(ElevatedButton, 'Sign Up');
      expect(signUpButtonFinder, findsOneWidget);
    });
  });

  testWidgets('should be required to fill form', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetObserver(const SignUpPage()).widget);

    final signUpButtonFinder = find.widgetWithText(ElevatedButton, 'Sign Up');
    await tester.tap(signUpButtonFinder);
    await tester.pump();

    final emailFinder = find.text('Email is required');
    expect(emailFinder, findsOneWidget);

    final usernameFinder = find.text('Username is required');
    expect(usernameFinder, findsOneWidget);

    final passwordFinder = find.text('Password is required');
    expect(passwordFinder, findsOneWidget);

    final confirmPasswordFinder = find.text('Confirm Password is required');
    expect(confirmPasswordFinder, findsOneWidget);
  });

  testWidgets('should be required to have min passwords length',
      (WidgetTester tester) async {
    var widget = createWidgetObserver(const SignUpPage()).widget;
    await tester.pumpWidget(widget);

    final passwordFinder = find.widgetWithText(TextFormField, 'Password');
    await tester.enterText(passwordFinder, '123');
    final confirmPasswordFinder =
        find.widgetWithText(TextFormField, 'Confirm Password');
    await tester.enterText(confirmPasswordFinder, '456');

    final signUpButtonFinder = find.widgetWithText(ElevatedButton, 'Sign Up');
    await tester.tap(signUpButtonFinder);
    await tester.pump();

    expect(find.textContaining('Password must have at least'), findsOneWidget);
    expect(find.text('Passwords must match'), findsOneWidget);
  });

  testWidgets('should be able to login', (WidgetTester tester) async {
    const email = 'mail@sample.com';
    const username = 'sampleUsername';
    const password = 'sample password';
    final authClient = MockAuthClient();
    AuthClient.authClient = authClient;

    when(authClient.createAccount(
            username: username, email: email, password: password))
        .thenAnswer((_) async => ApiResponse(http.Response(
            getLoginResponse(
                user: {'username': username, 'password': password}),
            200)));

    var widgetObserver = createWidgetObserver(const SignUpPage());
    await tester.pumpWidget(widgetObserver.widget);

    final emailFinder = find.widgetWithText(TextFormField, 'Email');
    final usernameFinder = find.widgetWithText(TextFormField, 'Username');
    final passwordFinder = find.widgetWithText(TextFormField, 'Password');
    final confirmPasswordFinder =
        find.widgetWithText(TextFormField, 'Confirm Password');

    await tester.enterText(emailFinder, email);
    await tester.enterText(usernameFinder, username);
    await tester.enterText(passwordFinder, password);
    await tester.enterText(confirmPasswordFinder, password);

    final signUpButtonFinder = find.widgetWithText(ElevatedButton, 'Sign Up');
    await tester.tap(signUpButtonFinder);

    verify(authClient.createAccount(
        username: username, email: email, password: password));
    verify(widgetObserver.observer.didPush(any, any));
  });
}
