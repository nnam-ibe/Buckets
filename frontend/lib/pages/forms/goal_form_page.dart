import 'package:flutter/material.dart';
import 'package:frontend/api/api_response.dart';
import 'package:frontend/api/repositories.dart';
import 'package:frontend/common/helpers.dart' as helpers;
import 'package:frontend/models/bucket.dart';
import 'package:frontend/models/goal.dart';
import 'package:frontend/models/screen_arguments.dart';
import 'package:frontend/pages/widgets/widget_factory.dart' as widget_factory;

class GoalFormPage extends StatefulWidget {
  static const routeName = '/goal/:id';
  const GoalFormPage({Key? key}) : super(key: key);

  @override
  _GoalFormPageState createState() => _GoalFormPageState();
}

class _GoalFormPageState extends State<GoalFormPage> {
  late GoalFormArguments screenArgs;
  String token = '';
  Goal? goal;
  DraftGoal? draftGoal;
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    screenArgs =
        ModalRoute.of(context)?.settings.arguments as GoalFormArguments;
    setUpGoal(screenArgs);
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
  void validateForm() {
    if (screenArgs.isNew) {
      if (draftGoal == null) throw Exception('Missing draft goal');
    } else if (!hasGoal()) {
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
  void updateGoalModel() {
    validateForm();
    setState(() {
      if (screenArgs.isNew) {
        draftGoal!.name = nameController.text;
        draftGoal!.goalAmount = double.parse(goalAmountController.text);
        draftGoal!.amountSaved = double.parse(savedAmountController.text);
        draftGoal!.bucketId = selectedBucket!.id;
        draftGoal!.validateForSave();
      } else {
        goal!.name = nameController.text;
        goal!.goalAmount = double.parse(goalAmountController.text);
        goal!.amountSaved = double.parse(savedAmountController.text);
        goal!.bucketId = selectedBucket!.id;
      }
    });
  }

  void saveGoal() async {
    if (_formKey.currentState!.validate()) {
      updateGoalModel();
      Repositories repositories = Repositories(token: token);
      ApiResponse apiResponse = screenArgs.isNew
          ? await repositories.createGoal(draftGoal!)
          : await repositories.saveGoal(goal!);
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

  void setUpGoal(GoalFormArguments args) {
    // Sets up draft goal if [args.isNew] == true.
    setState(() {
      if (args.isNew) {
        draftGoal = DraftGoal();
        goalAmountController.text = draftGoal?.goalAmount.toString() ?? '';
        savedAmountController.text = draftGoal?.amountSaved.toString() ?? '';
        return;
      } else {
        goal = args.goal;
        if (!hasGoal()) {
          throw Exception('Expected goal argument');
        }
        nameController.text = goal!.name;
        goalAmountController.text = goal!.goalAmount.toString();
        savedAmountController.text = goal!.amountSaved.toString();
      }
    });
  }

  Bucket getSelectedBucket(List<Bucket> bucketsList) {
    if (bucketsList.isEmpty) {
      throw Exception('There should be a bucket');
    }
    int bucketId = screenArgs.bucketId;
    return bucketsList.firstWhere((buc) => buc.id == bucketId,
        orElse: () => bucketsList.first);
  }

  @override
  Widget build(BuildContext context) {
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
              selectedBucket ??= getSelectedBucket(bucketsList);

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
