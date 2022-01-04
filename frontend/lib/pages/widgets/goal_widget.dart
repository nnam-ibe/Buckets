import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:frontend/models/goal.dart';
import 'package:frontend/models/screen_arguments.dart';
import 'package:frontend/pages/forms/goal_form_page.dart';

class GoalWidget extends StatefulWidget {
  final Goal goal;
  const GoalWidget({Key? key, required this.goal}) : super(key: key);

  @override
  _GoalWidgetState createState() => _GoalWidgetState();
}

class _GoalWidgetState extends State<GoalWidget> {
  late Goal _goal;

  @override
  initState() {
    super.initState();
    _goal = widget.goal;
  }

  void editGoal() async {
    Goal? _updatedGoal = await Navigator.of(context).pushNamed(
      GoalFormPage.routeName,
      arguments: GoalFormArguments(
        isNew: false,
        bucketId: _goal.bucketId,
        goal: _goal,
      ),
    ) as Goal?;
    if (_updatedGoal != null) {
      setState(() {
        _goal = _updatedGoal;
      });
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        child: InkWell(
      onTap: editGoal,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _goal.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Text(
            _goal.getProgressString(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          LinearProgressIndicator(
            minHeight: 15,
            value: _goal.getProgress(),
          ),
        ],
      ),
    ));
  }
}
