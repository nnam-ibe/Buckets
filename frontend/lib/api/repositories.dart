import 'package:frontend/api/api_client.dart';
import 'package:frontend/api/api_response.dart';
import 'package:frontend/api/authentication/session.dart';
import 'package:frontend/models/bucket.dart';

class Repositories {
  String token;
  ApiClient apiClient = ApiClient();
  UserSession session = UserSession();

  Repositories({required this.token});

  Future<List<Bucket>> getBuckets() async {
    ApiResponse apiResponse = await apiClient.get(endpoint: 'bucket/', token: token);
    if (!apiResponse.wasSuccessful()) {
      // TODO: Handle response errors
      return <Bucket>[];
    }

    var mapBuckets = apiResponse.getDataAsList();
    var buckets = <Bucket>[];
    for (var element in mapBuckets) {
      buckets.add(Bucket.fromMap(element));
    }
    return buckets;
  }

}