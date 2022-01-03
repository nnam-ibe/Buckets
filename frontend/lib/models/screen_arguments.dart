import 'package:frontend/models/goal.dart';

class GoalFormArguments {
  final Goal? goal;
  final bool isNew;
  final int bucketId;

  GoalFormArguments({
    required this.isNew,
    required this.bucketId,
    this.goal,
  }) {
    if (!isNew && goal == null) {
      throw Exception('Goal cannot be null');
    }
  }
}
