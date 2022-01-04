import 'package:flutter/material.dart';
import 'package:frontend/api/api_response.dart';
import 'package:frontend/api/repositories.dart';
import 'package:frontend/common/helpers.dart' as helpers;
import 'package:frontend/models/bucket.dart';
import 'package:frontend/models/screen_arguments.dart';

class BucketFormPage extends StatefulWidget {
  static const routeName = '/bucket/:id';
  const BucketFormPage({Key? key}) : super(key: key);

  @override
  _BucketFormPageState createState() => _BucketFormPageState();
}

class _BucketFormPageState extends State<BucketFormPage> {
  late BucketFormArguments screenArgs;
  String name = '';
  String token = '';
  Bucket? bucket;
  DraftBucket? draftBucket;

  @override
  void initState() {
    super.initState();
    String _token = helpers.getTokenFromProvider(context);
    if (_token.isEmpty) return;
    token = _token;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {
      screenArgs =
          ModalRoute.of(context)?.settings.arguments as BucketFormArguments;
      if (screenArgs.isNew) {
        draftBucket =
            DraftBucket(helpers.getUserFromProvider(context).id, name);
      } else {
        bucket = screenArgs.bucket;
        name = bucket!.name;
      }
    });
  }

  bool isNew() {
    return screenArgs.isNew;
  }

  String getCreateEditString() {
    if (isNew()) {
      return 'Create';
    }
    return 'Edit';
  }

  String getTitleText() {
    return "${getCreateEditString()} Bucket";
  }

  void saveBucket() async {
    if (isNew()) {
      draftBucket!.name = name;
    } else {
      bucket?.name = name;
    }

    Repositories repositories = Repositories(token: token);
    ApiResponse apiResponse = isNew()
        ? await repositories.createBucket(draftBucket!)
        : await repositories.saveBucket(bucket!);
    if (apiResponse.wasSuccessful()) {
      Bucket updatedBucket = Bucket.fromMap(apiResponse.getDataAsMap());
      Navigator.of(context).pop(updatedBucket);
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(apiResponse.getError())),
    );
  }

  void deleteBucket() async {
    if (isNew()) return;
    Repositories repositories = Repositories(token: token);
    bool isDeleted = await repositories.deleteBucket(bucket!.id);
    if (!isDeleted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to delete bucket, ☹️️')));
      return;
    }
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Deleted Bucket')));
    Navigator.of(context).pop();
  }

  void deleteClicked() {
    AlertDialog dialog = AlertDialog(
      title: Text('Delete ${bucket!.name}'),
      content: const Text('And the goals in this bucket'),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel')),
        TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              deleteBucket();
            },
            child: const Text('Delete')),
      ],
    );
    showDialog(context: context, builder: (context) => dialog);
  }

  List<ElevatedButton> getButtonBarBtns() {
    var btns = [
      ElevatedButton(
        onPressed: saveBucket,
        child: const Text('Save Bucket'),
      ),
    ];
    if (!isNew()) {
      btns.add(
        ElevatedButton(
          onPressed: deleteClicked,
          child: const Text('Delete Bucket'),
          style: ElevatedButton.styleFrom(primary: Colors.red),
        ),
      );
    }
    return btns;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(getTitleText()),
      ),
      body: Form(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextFormField(
              initialValue: name,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                filled: true,
              ),
              onChanged: (value) {
                name = value;
              },
            ),
            ButtonBar(
              alignment: MainAxisAlignment.center,
              children: getButtonBarBtns(),
            )
          ],
        ),
      ),
    );
  }
}
