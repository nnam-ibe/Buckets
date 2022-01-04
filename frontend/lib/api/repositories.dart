import 'package:frontend/api/api_client.dart';
import 'package:frontend/api/api_response.dart';
import 'package:frontend/api/authentication/session.dart';
import 'package:frontend/models/bucket.dart';
import 'package:frontend/models/goal.dart';

class Repositories {
  String token;
  ApiClient apiClient = ApiClient();
  UserSession session = UserSession();

  Repositories({required this.token});

  Future<List<Bucket>> getBuckets({bool overview = false}) async {
    Map<String, String> queryParams = {};
    if (overview) {
      queryParams['overview'] = "true";
    }
    ApiResponse apiResponse = await apiClient.get(
      endpoint: 'bucket/',
      queryParams: queryParams,
      token: token,
    );
    if (!apiResponse.wasSuccessful()) {
      throw Exception(apiResponse.getError());
    }

    return Bucket.fromMapList(apiResponse.getDataAsList());
  }

  Future<Bucket> getBucket(String id) async {
    ApiResponse apiResponse =
        await apiClient.get(endpoint: "bucket/$id/", token: token);
    if (!apiResponse.wasSuccessful()) {
      throw Exception(apiResponse.getError());
    }

    return Bucket.fromMap(apiResponse.getDataAsMap());
  }

  Future<ApiResponse> createBucket(DraftBucket bucket) async {
    return await apiClient.post(
      endpoint: "bucket/",
      token: token,
      payload: bucket.toMap(),
    );
  }

  Future<ApiResponse> saveBucket(Bucket bucket) async {
    return await apiClient.put(
      endpoint: "bucket/${bucket.id}/",
      token: token,
      payload: bucket.toMap(),
    );
  }

  Future<ApiResponse> createGoal(DraftGoal goal) async {
    return await apiClient.post(
        endpoint: "goal/", token: token, payload: goal.toMap());
  }

  Future<ApiResponse> saveGoal(Goal goal) async {
    return await apiClient.put(
        endpoint: "goal/${goal.id}/", token: token, payload: goal.toMap());
  }
}
