import 'package:flutter/material.dart';
import 'package:frontend/models/bucket.dart';
import 'package:frontend/pages/bucket_form_page.dart';
import 'package:frontend/pages/widgets/goal_widget.dart';

class BucketWidget extends StatefulWidget {
  final Bucket bucket;
  const BucketWidget({Key? key, required this.bucket}) : super(key: key);

  @override
  _BucketWidgetState createState() => _BucketWidgetState();
}

class _BucketWidgetState extends State<BucketWidget> {
  bool showButtonTray = false;

  List<GoalWidget> getGoals() {
    var goalWidgets = <GoalWidget>[];
    for (var goal in widget.bucket.goals) {
      goalWidgets.add(GoalWidget(goal: goal));
    }
    return goalWidgets;
  }

  void toggleButtonTray() {
    setState(() {
      showButtonTray = !showButtonTray;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ListTile(
          leading: const Icon(Icons.arrow_drop_down),
          onTap: toggleButtonTray,
          title: Text(widget.bucket.name),
          trailing: Text(widget.bucket.getProgressString()),
        ),
        Visibility(
            visible: showButtonTray,
            child: ButtonBar(
              children: [
                ElevatedButton(
                    child: const Text('Edit'),
                    onPressed: () {
                      Navigator.of(context).pushNamed(BucketFormPage.routeName,
                          arguments: widget.bucket);
                    }),
                ElevatedButton(child: const Text('Add Goal'), onPressed: () {})
              ],
            )),
        Column(
          children: getGoals(),
        )
      ],
    );
  }
}
