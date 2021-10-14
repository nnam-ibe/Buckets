import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/models/bucket.dart';
import 'package:frontend/models/contribution_frequency.dart';
import 'package:frontend/models/goal.dart';

void main() {
  final Map<String, dynamic> mapData = {
    'id': 430,
    'user': 930,
    'name': 'Bucket Name',
    'created_date': '2021-10-14T20:16:12.000Z',
    'last_modified': '2021-10-14T20:16:12.000Z',
    'goals': [
      Goal(
              id: 42,
              bucketId: 12,
              name: 'Sample name I',
              goalAmount: 780,
              amountSaved: 54.34,
              contribAmount: 10.50,
              contribFrequency: ContributionFrequency.biWeekly,
              autoUpdate: true,
              createdDate: DateTime.now(),
              lastModified: DateTime.now())
          .toMap(),
      Goal(
              id: 59,
              bucketId: 120,
              name: 'Sample name II',
              goalAmount: 780,
              amountSaved: 54.34,
              contribAmount: 10.50,
              contribFrequency: ContributionFrequency.monthly,
              autoUpdate: false,
              createdDate: DateTime.now(),
              lastModified: DateTime.now())
          .toMap(),
    ],
  };

  test('Should be able to create a bucket from a map', () {
    Bucket bucket = Bucket.fromMap(mapData);
    expect(bucket.id, mapData['id']);
    expect(bucket.userId, mapData['user']);
    expect(bucket.name, mapData['name']);
    expect(bucket.goals.length, 2);
    expect(bucket.goals[0].autoUpdate, true);
    expect(bucket.goals[1].autoUpdate, false);
  });
}
