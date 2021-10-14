import 'package:frontend/models/contribution_frequency.dart';

class Goal {
  int id;
  int bucketId;
  String name;
  double goalAmount;
  double amountSaved;
  double contribAmount;
  ContributionFrequency contribFrequency;
  bool autoUpdate;
  DateTime createdDate;
  DateTime lastModified;

//<editor-fold desc="Data Methods">

  Goal({
    required this.id,
    required this.bucketId,
    required this.name,
    required this.goalAmount,
    required this.amountSaved,
    required this.contribAmount,
    required this.contribFrequency,
    required this.autoUpdate,
    required this.createdDate,
    required this.lastModified,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Goal &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          bucketId == other.bucketId &&
          name == other.name &&
          goalAmount == other.goalAmount &&
          amountSaved == other.amountSaved &&
          contribAmount == other.contribAmount &&
          contribFrequency == other.contribFrequency &&
          autoUpdate == other.autoUpdate &&
          createdDate == other.createdDate &&
          lastModified == other.lastModified);

  @override
  int get hashCode =>
      id.hashCode ^
      bucketId.hashCode ^
      name.hashCode ^
      goalAmount.hashCode ^
      amountSaved.hashCode ^
      contribAmount.hashCode ^
      contribFrequency.hashCode ^
      autoUpdate.hashCode ^
      createdDate.hashCode ^
      lastModified.hashCode;

  @override
  String toString() {
    return 'Goal{' +
        ' id: $id,' +
        ' bucketId: $bucketId,' +
        ' name: $name,' +
        ' goalAmount: $goalAmount,' +
        ' amountSaved: $amountSaved,' +
        ' contribAmount: $contribAmount,' +
        ' contribFrequency: $contribFrequency,' +
        ' autoUpdate: $autoUpdate,' +
        ' createdDate: $createdDate,' +
        ' lastModified: $lastModified,' +
        '}';
  }

  Goal copyWith({
    int? id,
    int? bucketId,
    String? name,
    double? goalAmount,
    double? amountSaved,
    double? contribAmount,
    ContributionFrequency? contribFrequency,
    bool? autoUpdate,
    DateTime? createdDate,
    DateTime? lastModified,
  }) {
    return Goal(
      id: id ?? this.id,
      bucketId: bucketId ?? this.bucketId,
      name: name ?? this.name,
      goalAmount: goalAmount ?? this.goalAmount,
      amountSaved: amountSaved ?? this.amountSaved,
      contribAmount: contribAmount ?? this.contribAmount,
      contribFrequency: contribFrequency ?? this.contribFrequency,
      autoUpdate: autoUpdate ?? this.autoUpdate,
      createdDate: createdDate ?? this.createdDate,
      lastModified: lastModified ?? this.lastModified,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id.toString(),
      'bucket': bucketId.toString(),
      'name': name.toString(),
      'goal_amount': goalAmount.toString(),
      'amount_saved': amountSaved.toString(),
      'contrib_amount': contribAmount.toString(),
      'contrib_frequency': contribFreqToString(contribFrequency),
      'auto_update': autoUpdate.toString(),
      'created_date': createdDate.toIso8601String(),
      'last_modified': lastModified.toIso8601String(),
    };
  }

  static List<Map<String, dynamic>> toMapList(List<Goal> goals) {
    List<Map<String, dynamic>> mappedGoals = [];
    for (var goal in goals) {
      mappedGoals.add(goal.toMap());
    }
    return mappedGoals;
  }

  factory Goal.fromMap(Map<String, dynamic> map) {
    return Goal(
      id: map['id'].runtimeType == int ? map['id'] : int.parse(map['id']),
      bucketId: map['bucket'].runtimeType == int
          ? map['bucket']
          : int.parse(map['bucket']),
      name: map['name'] as String,
      goalAmount: double.parse(map['goal_amount']),
      amountSaved: double.parse(map['amount_saved']),
      contribAmount: double.parse(map['contrib_amount']),
      contribFrequency: stringToContribFreq(map['contrib_frequency']),
      autoUpdate: map['auto_update'].runtimeType == bool
          ? map['auto_update']
          : map['auto_update'].toLowerCase() == 'true',
      createdDate: DateTime.parse(map['created_date']),
      lastModified: DateTime.parse(map['last_modified']),
    );
  }

  static List<Goal> fromMapList(List<dynamic> mapGoals) {
    var goals = <Goal>[];
    for (var element in mapGoals) {
      goals.add(Goal.fromMap(element));
    }
    return goals;
  }

  double getProgress() {
    return amountSaved / goalAmount;
  }

  String getProgressString() {
    return "\$$amountSaved / \$$goalAmount";
  }
}
