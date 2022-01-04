import 'package:flutter/material.dart';
import 'package:frontend/api/authentication/session.dart';
import 'package:frontend/common/constants.dart' as constants;
import 'package:frontend/models/user.dart';
import 'package:frontend/pages/authentication/login_page.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Stores the provided user and token in shared prefrences
Future<void> setUserPrefernces(User user, String token) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString(constants.username, user.username);
  prefs.setString(constants.userEmail, user.email);
  prefs.setInt(constants.userID, user.id);
  prefs.setString(constants.userToken, token);
}

/// Removes the users & token details from shared preferences.
///
/// Should be called in conjunction with [removeUserFromProvider]
/// to avoid unwanted side effects.
Future<void> removeUserFromPrefences() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.remove(constants.username);
  prefs.remove(constants.userEmail);
  prefs.remove(constants.userID);
  prefs.remove(constants.userToken);
}

/// Gets the user from shared preferences if it exists
/// returns null otherwise.
Future<User?> getUserFromPrefrences() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (!prefs.containsKey(constants.username) ||
      !prefs.containsKey(constants.userEmail) ||
      !prefs.containsKey(constants.userID)) {
    return null;
  }
  String username = prefs.getString(constants.username)!;
  String useremail = prefs.getString(constants.userEmail)!;
  int userId = prefs.getInt(constants.userID)!;
  User user = User(id: userId, username: username, email: useremail);
  return user;
}

/// Gets the user auth token stored in shared preferences
/// returns null otherwise.
Future<String?> getTokenFromPreferences() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (!prefs.containsKey(constants.userToken)) {
    return null;
  }
  return prefs.getString(constants.userToken);
}

/// Removes the user from the UserSession provider, using
/// the [context] of the requesting widget.
///
/// This will cause the app to redirect to the logout page.
void removeUserFromProvider(BuildContext context) {
  Provider.of<UserSession>(context, listen: false).unsetUser();
}

/// Returns the current user token from the UserSession provider, using
/// the [context] of the requesting widget.
///
/// If there is no token, it navigates to the loginPage & returns an empty String.
String getTokenFromProvider(BuildContext context) {
  String? token = Provider.of<UserSession>(
    context,
    listen: false,
  ).token;
  if (token == null) {
    Navigator.of(context).pushNamed(LoginPage.routeName);
    return "";
  }
  return token;
}

/// Returns the current user from the UserSession provider, using the [context]
/// of the requesting Widget.
///
/// Throws an exception if not user is found.
User getUserFromProvider(BuildContext context) {
  User? user = Provider.of<UserSession>(context, listen: false).user;
  if (user == null) {
    throw Exception('User not found');
  }
  return user;
}
