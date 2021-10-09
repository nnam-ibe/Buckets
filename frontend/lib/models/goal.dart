enum ContributionFrequency {
  monthly,
  biWeekly,
  weekly,
  na,
}

ContributionFrequency parseContribFreq(String contrib) {
  switch (contrib) {
    case 'MONTHLY':
      return ContributionFrequency.monthly;
    case 'BI_WEEKLY':
      return ContributionFrequency.biWeekly;
    case 'WEEKLY':
      return ContributionFrequency.weekly;
    case 'NA':
      return ContributionFrequency.na;
    default:
      throw Exception('Contribution Frequency not found');
  }
}

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
      'id': id,
      'bucket': bucketId,
      'name': name,
      'goal_amount': goalAmount,
      'amount_saved': amountSaved,
      'contrib_amount': contribAmount,
      'contrib_frequency': contribFrequency,
      'auto_update': autoUpdate,
      'created_date': createdDate,
      'last_modified': lastModified,
    };
  }

  factory Goal.fromMap(Map<String, dynamic> map) {
    return Goal(
      id: map['id'],
      bucketId: map['bucket'],
      name: map['name'] as String,
      goalAmount: double.parse(map['goal_amount']),
      amountSaved: double.parse(map['amount_saved']),
      contribAmount: double.parse(map['contrib_amount']),
      contribFrequency: parseContribFreq(map['contrib_frequency']),
      autoUpdate: map['auto_update'] as bool,
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
}
