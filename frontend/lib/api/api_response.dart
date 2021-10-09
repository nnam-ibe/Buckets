import 'package:http/http.dart';
import 'dart:convert' as convert;

class ApiResponse {
  late int _statusCode;
  String? _data;
  String? _reasonPhrase;

  ApiResponse(Response response) {
    _statusCode = response.statusCode;

    if (wasSuccessful()) {
      _data = response.body;
    } else {
      _reasonPhrase = response.reasonPhrase;
    }
  }

  bool wasSuccessful() {
    return _statusCode >= 200 && _statusCode < 300;
  }

  String getError() {
    if (wasSuccessful()) {
      throw Exception("Response was successful");
    }
    return _reasonPhrase ?? "Internal Server Error";
  }

  void _validateData() {
    if (!wasSuccessful()) {
      throw Exception("Response was not successful");
    }
  }

  String getData() {
    _validateData();
    return _data!;
  }

  Map<String, dynamic> getDataAsMap() {
    _validateData();
    return convert.jsonDecode(_data!) as Map<String, dynamic>;
  }

  List<dynamic> getDataAsList() {
    _validateData();
    return convert.jsonDecode(_data!) as List<dynamic>;
  }
}
