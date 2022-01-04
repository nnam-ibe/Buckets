import 'package:flutter/material.dart';
import 'package:frontend/api/api_client.dart';
import 'package:frontend/api/api_response.dart';
import 'package:frontend/common/helpers.dart' as helpers;

class AuthClient {
  AuthClient._constructor();

  static String? token;

  static final AuthClient _authClient = AuthClient._constructor();

  factory AuthClient() {
    return _authClient;
  }

  Future<ApiResponse> login({
    required String username,
    required String password,
  }) async {
    ApiClient apiClient = ApiClient();
    ApiResponse apiResponse =
        await apiClient.post(endpoint: "auth/login", payload: {
      'username': username,
      'password': password,
    });
    return apiResponse;
  }

  Future<ApiResponse> logout(BuildContext context) async {
    ApiClient apiClient = ApiClient();
    ApiResponse apiResponse = await apiClient
        .post(endpoint: "auth/logout", token: token, payload: {});
    await helpers.removeAllLoginData(context);
    return apiResponse;
  }
}
