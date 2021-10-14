import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/models/goal.dart';
import 'package:frontend/models/contribution_frequency.dart';

void main() {
  final Map<String, dynamic> mapData = {
    'id': '430',
    'bucket': '930',
    'name': 'Goal Name',
    'goal_amount': '500.54',
    'amount_saved': '25.45',
    'contrib_amount': '25.65',
    'contrib_frequency': 'MONTHLY',
    'auto_update': 'false',
    'created_date': '2021-10-14T20:16:12.000Z',
    'last_modified': '2021-10-14T20:16:12.000Z',
  };

  test('Should be able to create a goal from a map', () {
    Goal goal = Goal.fromMap(mapData);
    expect(goal.id, int.parse(mapData['id']));
    expect(goal.bucketId, int.parse(mapData['bucket']));
    expect(goal.name, mapData['name']);
    expect(goal.goalAmount, double.parse(mapData['goal_amount']));
    expect(goal.amountSaved, double.parse(mapData['amount_saved']));
    expect(goal.contribAmount, double.parse(mapData['contrib_amount']));
    expect(goal.contribFrequency, ContributionFrequency.monthly);
    expect(goal.autoUpdate, false);
    DateTime createdDate = DateTime.parse(mapData['created_date']);
    expect(goal.createdDate.millisecondsSinceEpoch,
        createdDate.millisecondsSinceEpoch);
    DateTime lastModified = DateTime.parse(mapData['last_modified']);
    expect(goal.lastModified.millisecondsSinceEpoch,
        lastModified.millisecondsSinceEpoch);
  });

  test('Should be able to convert a goal to a map', () {
    Map<String, dynamic> mappedGoal = Goal.fromMap(mapData).toMap();
    expect(mappedGoal['id'], mapData['id']);
    expect(mappedGoal['bucket'], mapData['bucket']);
    expect(mappedGoal['name'], mapData['name']);
    expect(mappedGoal['goal_amount'], mapData['goal_amount']);
    expect(mappedGoal['amount_saved'], mapData['amount_saved']);
    expect(mappedGoal['contrib_amount'], mapData['contrib_amount']);
    expect(mappedGoal['contrib_frequency'], mapData['contrib_frequency']);
    expect(mappedGoal['auto_update'], mapData['auto_update']);
    expect(mappedGoal['created_date'], mapData['created_date']);
    expect(mappedGoal['last_modified'], mapData['last_modified']);
  });
}
