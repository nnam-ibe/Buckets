import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:frontend/models/goal.dart';

class GoalWidget extends StatelessWidget {
  final Goal goal;

  const GoalWidget({Key? key, required this.goal}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
        child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    goal.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ),
        Text(
          goal.getProgressString(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        LinearProgressIndicator(
          minHeight: 15,
          value: goal.getProgress(),
        ),
      ],
    ));
  }
}
