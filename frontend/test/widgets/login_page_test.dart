import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/api/api_response.dart';
import 'package:frontend/api/authentication/auth_client.dart';
import 'package:frontend/pages/authentication/login_page.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../utils.dart';
import 'login_page_test.mocks.dart';

@GenerateMocks([AuthClient],
    customMocks: [MockSpec<NavigatorObserver>(returnNullOnMissingStub: true)])
void main() {
  group('Login Page:', () {
    testWidgets('should have form elements', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetObserver(const LoginPage()).widget);

      final welcomeFinder = find.text('Welcome');
      final usernameFinder = find.text('Username');
      final passwordFinder = find.text('Password');
      final loginButtonFinder = find.widgetWithText(ElevatedButton, 'Login');
      final signupButtonFinder =
          find.widgetWithText(TextButton, 'Create Account');

      expect(welcomeFinder, findsOneWidget);
      expect(usernameFinder, findsOneWidget);
      expect(passwordFinder, findsOneWidget);
      expect(loginButtonFinder, findsOneWidget);
      expect(signupButtonFinder, findsOneWidget);
    });

    testWidgets('should be required to fill the login form',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetObserver(const LoginPage()).widget);

      final loginButtonFinder = find.widgetWithText(ElevatedButton, 'Login');
      await tester.tap(loginButtonFinder);
      await tester.pump();

      final usernameValidationFinder = find.text('Username is required');
      final passwordValidationFinder = find.text('Password is required');

      expect(usernameValidationFinder, findsOneWidget);
      expect(passwordValidationFinder, findsOneWidget);
    });

    testWidgets('should be able to login', (WidgetTester tester) async {
      const username = 'sampleUsername';
      const password = 'sample password';
      final authClient = MockAuthClient();
      AuthClient.authClient = authClient;

      when(authClient.login(username: username, password: password)).thenAnswer(
          (_) async => ApiResponse(http.Response(
              getLoginResponse(
                  user: {'username': username, 'password': password}),
              200)));

      var widgetObserver = createWidgetObserver(const LoginPage());
      await tester.pumpWidget(widgetObserver.widget);

      final usernameFinder = find.widgetWithText(TextFormField, 'Username');
      final passwordFinder = find.widgetWithText(TextFormField, 'Password');

      await tester.enterText(usernameFinder, username);
      await tester.enterText(passwordFinder, password);

      final loginButtonFinder = find.widgetWithText(ElevatedButton, 'Login');
      await tester.tap(loginButtonFinder);
      verify(authClient.login(username: username, password: password));
      verify(widgetObserver.observer.didPush(any, any));
    });

    testWidgets('should be able to sign up', (WidgetTester tester) async {
      var widgetObserver = createWidgetObserver(const LoginPage());
      await tester.pumpWidget(widgetObserver.widget);

      final signupButtonFinder =
          find.widgetWithText(TextButton, 'Create Account');
      await tester.tap(signupButtonFinder);
      await tester.pumpAndSettle();

      verify(widgetObserver.observer.didPush(any, any));
    });
  });
}
