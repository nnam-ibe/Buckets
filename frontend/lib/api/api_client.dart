import 'dart:convert' as convert;
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/api/api_response.dart';

class ApiClient {
  ApiClient();

  /// Builds the uri of a request.
  ///
  /// By prepending the baseUrl to endpoint; also adds query parameters
  /// if any are supplied
  Future<Uri> buildUri({
    required String endpoint,
    Map<String, String>? queryParams,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? baseUrl = prefs.getString('baseUrl');
    if (baseUrl == null) {
      // TODO: Exception, handle exception.
      throw Exception("There was no baseUrl");
    }
    return Uri.parse(baseUrl + endpoint);
  }

  /// builds the headers for a request
  Map<String, String> buildHeaders(String? token) {
    Map<String, String> headers = {};
    headers['Content-Type'] = "application/json";
    if (token != null) {
      headers['Authorization'] = "Token $token";
    }
    return headers;
  }

  ApiResponse handleResponse(http.Response response) {
    final apiRespoonse = ApiResponse(response);
    return apiRespoonse;
  }

  ApiResponse handleError(String errorMsg) {
    final apiRespoonse = ApiResponse.fromError(errorMsg);
    return apiRespoonse;
  }

  /// Sends a get request to endpoint.
  ///
  /// If addToken if true, it adds the token to the request.
  Future<ApiResponse> get({
    required String endpoint,
    Map<String, String>? headers,
    Map<String, String>? queryParams,
    String? token,
  }) async {
    final Uri uri =
        await buildUri(endpoint: endpoint, queryParams: queryParams);
    Map<String, String> requestHeaders = buildHeaders(token);
    if (headers != null) {
      requestHeaders.addAll(headers);
    }

    try {
      final response = await http.get(uri, headers: requestHeaders);
      var apiResponse = handleResponse(response);
      return apiResponse;
    } on HttpException catch (httpException) {
      return handleError(httpException.message);
    } on SocketException {
      return handleError('Error connecting to the server');
    }
  }

  /// Sends a post request to endpoint.
  Future<ApiResponse> post({
    required String endpoint,
    required Map<String, dynamic> payload,
    String? token,
    Map<String, String>? headers,
  }) async {
    final Uri uri = await buildUri(endpoint: endpoint);
    Map<String, String> requestHeaders = buildHeaders(token);
    if (headers != null) {
      requestHeaders.addAll(headers);
    }

    try {
      final response = await http.post(uri,
          headers: requestHeaders, body: convert.jsonEncode(payload));
      var apiResponse = handleResponse(response);
      return apiResponse;
    } on HttpException catch (httpException) {
      return handleError(httpException.message);
    } on SocketException {
      return handleError('Error connecting to the server');
    }
  }

  /// Sends a put request to endpoint.
  Future<ApiResponse> put({
    required String endpoint,
    required Map<String, dynamic> payload,
    required String token,
    Map<String, String>? headers,
  }) async {
    final Uri uri = await buildUri(endpoint: endpoint);
    Map<String, String> requestHeaders = buildHeaders(token);
    if (headers != null) {
      requestHeaders.addAll(headers);
    }

    try {
      final response = await http.put(uri,
          headers: requestHeaders, body: convert.jsonEncode(payload));
      var apiResponse = handleResponse(response);
      return apiResponse;
    } on HttpException catch (httpException) {
      return handleError(httpException.message);
    } on SocketException {
      return handleError('Error connecting to the server');
    }
  }
}
