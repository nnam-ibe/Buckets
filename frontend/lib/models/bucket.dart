import 'dart:convert';

import 'package:frontend/models/goal.dart';

class Bucket {
  int id;
  int userId;
  String name;
  DateTime createdDate;
  DateTime lastModified;
  List<Goal> goals = [];

//<editor-fold desc="Data Methods">

  Bucket({
    required this.id,
    required this.userId,
    required this.name,
    required this.createdDate,
    required this.lastModified,
    List<Goal>? goals,
  }) {
    if (goals != null) {
      this.goals = goals;
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Bucket &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          userId == other.userId &&
          name == other.name &&
          createdDate == other.createdDate &&
          lastModified == other.lastModified &&
          goals == other.goals);

  @override
  int get hashCode =>
      id.hashCode ^
      userId.hashCode ^
      name.hashCode ^
      createdDate.hashCode ^
      lastModified.hashCode ^
      goals.hashCode;

  @override
  String toString() {
    // ignore: prefer_adjacent_string_concatenation
    return 'Bucket{' +
        ' id: $id,' +
        ' userId: $userId,' +
        ' name: $name,' +
        ' createdDate: $createdDate,' +
        ' lastModified: $lastModified,' +
        ' goals: $goals,' +
        '}';
  }

  Bucket copyWith({
    int? id,
    int? userId,
    String? name,
    DateTime? createdDate,
    DateTime? lastModified,
    List<Goal>? goals,
  }) {
    return Bucket(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      createdDate: createdDate ?? this.createdDate,
      lastModified: lastModified ?? this.lastModified,
      goals: goals ?? this.goals,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user': userId,
      'name': name,
      'created_date': createdDate.toString(),
      'last_modified': lastModified.toString(),
      'goals': Goal.toMapList(goals),
    };
  }

  factory Bucket.fromMap(Map<String, dynamic> map) {
    return Bucket(
      id: map['id'],
      userId: map['user'],
      name: map['name'] as String,
      createdDate: DateTime.parse(map['created_date']),
      lastModified: DateTime.parse(map['last_modified']),
      goals: Goal.fromMapList(map['goals']),
    );
  }

  static List<Bucket> fromMapList(List<dynamic> mapBuckets) {
    var buckets = <Bucket>[];
    for (var element in mapBuckets) {
      buckets.add(Bucket.fromMap(element));
    }
    return buckets;
  }

  double getTotalSaved() {
    double sum = 0;
    for (var goal in goals) {
      sum += goal.amountSaved;
    }
    return sum;
  }

  double getTotalGoalAmoun() {
    double sum = 0;
    for (var goal in goals) {
      sum += goal.goalAmount;
    }
    return sum;
  }

  String getProgressString() {
    return "\$${getTotalSaved()} / \$${getTotalGoalAmoun()}";
  }
}

class DraftBucket {
  int userId;
  String? name;

  DraftBucket(
    this.userId,
    this.name,
  );

  DraftBucket copyWith({
    int? userId,
    String? name,
  }) {
    return DraftBucket(
      userId ?? this.userId,
      name ?? this.name,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user': userId,
      'name': name,
    };
  }

  factory DraftBucket.fromMap(Map<String, dynamic> map) {
    return DraftBucket(
      map['user']?.toInt() ?? 0,
      map['name'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory DraftBucket.fromJson(String source) =>
      DraftBucket.fromMap(json.decode(source));

  @override
  String toString() => 'DraftBucket(userId: $userId, name: $name)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DraftBucket && other.userId == userId && other.name == name;
  }

  @override
  int get hashCode => userId.hashCode ^ name.hashCode;
}
