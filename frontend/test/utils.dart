import 'package:flutter/material.dart';
import 'package:frontend/api/authentication/session.dart';
import 'package:frontend/common/theme.dart';
import 'dart:convert';

import 'package:provider/provider.dart';
import './widgets/login_page_test.mocks.dart';

class WidgetObserver {
  Widget widget;
  MockNavigatorObserver observer;

  WidgetObserver({required this.widget, required this.observer});
}

WidgetObserver createWidgetObserver(Widget widget) {
  var observer = MockNavigatorObserver();
  return WidgetObserver(
      observer: observer,
      widget: ChangeNotifierProvider(
        create: (context) => UserSession(),
        child: MaterialApp(
          home: widget,
          theme: appTheme,
          navigatorObservers: [observer],
          onUnknownRoute: (RouteSettings settings) {
            return MaterialPageRoute<void>(
                settings: settings,
                builder: (BuildContext context) {
                  return const Scaffold(
                    body: Center(
                      child: Text('Oops!'),
                    ),
                  );
                });
          },
        ),
      ));
}

Map<String, dynamic> getUserResponse(Map<String, dynamic>? user) {
  return {
    'id': user?['id'] ?? 4,
    'username': user?['username'] ?? 'sampleusername',
    'email': user?['email'] ?? 'test@mail.com'
  };
}

String getLoginResponse({Map<String, dynamic>? user, String? token}) {
  var result = {
    'user': getUserResponse(user),
    'token': token ?? 'sampletoken',
  };
  return json.encode(result);
}
