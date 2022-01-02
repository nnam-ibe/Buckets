import 'package:flutter/material.dart';
import 'package:frontend/api/api_response.dart';
import 'package:frontend/api/repositories.dart';
import 'package:frontend/common/helpers.dart' as helpers;
import 'package:frontend/models/bucket.dart';
import 'package:frontend/models/goal.dart';
import 'package:frontend/pages/widgets/widget_factory.dart' as widget_factory;

class GoalFormPage extends StatefulWidget {
  static const routeName = '/goal/:id';
  const GoalFormPage({Key? key}) : super(key: key);

  @override
  _GoalFormPageState createState() => _GoalFormPageState();
}

class _GoalFormPageState extends State<GoalFormPage> {
  String? token = '';
  Goal? goal;
  final _formKey = GlobalKey<FormState>();
  late Future<List<Bucket>> futureBuckets;

  TextEditingController nameController = TextEditingController();
  TextEditingController goalAmountController = TextEditingController();
  TextEditingController savedAmountController = TextEditingController();
  Bucket? selectedBucket;

  @override
  void initState() {
    super.initState();
    String _token = helpers.getTokenFromProvider(context);
    if (_token.isEmpty) return;
    futureBuckets = getBuckets(_token);
    token = _token;
  }

  @override
  void dispose() {
    nameController.dispose();
    goalAmountController.dispose();
    savedAmountController.dispose();
    super.dispose();
  }

  Future<List<Bucket>> getBuckets(String token) async {
    Repositories repositories = Repositories(token: token);
    return await repositories.getBuckets();
  }

  bool hasGoal() {
    return goal != null;
  }

  /// Throws and error if goal is null.
  void validateGoal() {
    if (!hasGoal()) {
      throw Exception('Missing goal');
    }
    if (selectedBucket == null) {
      showError("No bucket is selected");
      return;
    }
  }

  String getCreateEditString() {
    if (!hasGoal()) {
      return 'Create';
    }
    return 'Edit';
  }

  String getTitleText() {
    return "${getCreateEditString()} Goal";
  }

  /// Updates the goal model with values from the controller.
  void updateGoal() {
    validateGoal();
    goal!.name = nameController.text;
    goal!.goalAmount = double.parse(goalAmountController.text);
    goal!.amountSaved = double.parse(savedAmountController.text);
    goal!.bucketId = selectedBucket!.id;
  }

  void saveGoal() async {
    if (_formKey.currentState!.validate()) {
      updateGoal();
      Repositories repositories = Repositories(token: token!);
      ApiResponse apiResponse = await repositories.saveGoal(goal!);
      if (apiResponse.wasSuccessful()) {
        Goal updatedGoal = Goal.fromMap(apiResponse.getDataAsMap());
        Navigator.of(context).pop(updatedGoal);
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(apiResponse.getError())),
      );
    }
  }

  Widget showError(String errorMsg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(errorMsg)));
    return const Scaffold();
  }

  @override
  Widget build(BuildContext context) {
    goal = ModalRoute.of(context)?.settings.arguments as Goal?;
    // TODO: what to do when creating a new goal?
    if (hasGoal()) {
      nameController.text = goal!.name;
      goalAmountController.text = goal!.goalAmount.toString();
      savedAmountController.text = goal!.amountSaved.toString();
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(getTitleText()),
      ),
      body: Form(
        key: _formKey,
        child: FutureBuilder(
          future: futureBuckets,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return showError('${snapshot.error}');
            }
            if (snapshot.hasData) {
              List<Bucket> bucketsList = snapshot.data as List<Bucket>;
              if (bucketsList.isEmpty) {
                return showError("There should be a bucket");
              }
              if (selectedBucket == null) {
                Bucket goalBucket =
                    bucketsList.firstWhere((buc) => buc.id == goal!.bucketId);
                selectedBucket ??= goalBucket;
              }

              return Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    widget_factory.dropDownWidget(
                        items: bucketsList,
                        dropdownValue: selectedBucket,
                        onChanged: (dynamic newBucket) {
                          setState(() {
                            selectedBucket = newBucket;
                          });
                        }),
                    widget_factory.textFieldWidget(
                        controller: nameController, labelText: 'Name'),
                    widget_factory.decimalFieldWidget(
                        controller: goalAmountController,
                        labelText: 'Goal Amount'),
                    widget_factory.decimalFieldWidget(
                        controller: savedAmountController,
                        labelText: 'Amount Saved'),
                    ElevatedButton(
                      onPressed: saveGoal,
                      child: const Text('Save Goal'),
                    ),
                  ],
                ),
              );
            }
            return const CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}
