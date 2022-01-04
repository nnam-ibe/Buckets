import 'package:frontend/models/goal.dart';
import 'package:frontend/models/bucket.dart';

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

class BucketFormArguments {
  final Bucket? bucket;
  final bool isNew;
  BucketFormArguments({required this.isNew, this.bucket}) {
    if (!isNew && bucket == null) {
      throw Exception('Bucket cannot be null');
    }
  }
}
