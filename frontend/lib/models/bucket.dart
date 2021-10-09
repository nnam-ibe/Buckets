import 'package:frontend/models/goal.dart';

class Bucket {
  int id;
  int userId;
  String name;
  DateTime createdDate;
  DateTime lastModified;
  List<Goal> goals;

//<editor-fold desc="Data Methods">

  Bucket({
    required this.id,
    required this.userId,
    required this.name,
    required this.createdDate,
    required this.lastModified,
    required this.goals,
  });

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
      'created_date': createdDate,
      'last_modified': lastModified,
      'goals': goals,
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
}
