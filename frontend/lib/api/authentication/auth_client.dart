import 'package:flutter/material.dart';
import 'package:frontend/api/api_client.dart';
import 'package:frontend/api/api_response.dart';
import 'package:frontend/common/helpers.dart' as helpers;

class AuthClient {
  AuthClient._constructor();

  static String? token;

  static AuthClient authClient = AuthClient._constructor();

  factory AuthClient() {
    return authClient;
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

  Future<ApiResponse> createAccount({
    required String username,
    required String password,
    required String email,
  }) async {
    ApiClient apiClient = ApiClient();
    ApiResponse apiResponse =
        await apiClient.post(endpoint: 'auth/register', payload: {
      'username': username,
      'password': password,
      'email': email,
    });
    return apiResponse;
  }
}
