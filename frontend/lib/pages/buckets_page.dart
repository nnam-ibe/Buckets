import 'package:flutter/material.dart';
import 'package:frontend/api/repositories.dart';
import 'package:frontend/common/helpers.dart' as helpers;
import 'package:frontend/models/bucket.dart';
import 'package:frontend/models/screen_arguments.dart';
import 'package:frontend/pages/widgets/bucket_widget.dart';
import 'package:frontend/pages/forms/bucket_form_page.dart';

class BucketsPage extends StatefulWidget {
  static const routeName = '/buckets';
  static const menuItems = <String>['Create Bucket'];
  const BucketsPage({Key? key}) : super(key: key);

  @override
  _BucketsPageState createState() => _BucketsPageState();
}

class _BucketsPageState extends State<BucketsPage> {
  late Future<List<Bucket>> futureBuckets;

  @override
  void initState() {
    super.initState();
    String token = helpers.getTokenFromProvider(context);
    if (token.isEmpty) return;
    futureBuckets = getBuckets(token);
  }

  Future<List<Bucket>> getBuckets(String token) async {
    Repositories repositories = Repositories(token: token);
    return await repositories.getBuckets();
  }

  Widget bucketsWidget() {
    return FutureBuilder<List<Bucket>>(
      future: futureBuckets,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ListView.separated(
            separatorBuilder: (context, index) => const Divider(),
            itemCount: snapshot.data?.length ?? 0,
            itemBuilder: (context, index) {
              return BucketWidget(bucket: snapshot.data![index]);
            },
          );
        } else if (snapshot.hasError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('${snapshot.error}'),
          ));
        }
        return const CircularProgressIndicator();
      },
    );
  }

  List<PopupMenuItem<String>> menuItemBuilder(BuildContext context) {
    return BucketsPage.menuItems.map((String choice) {
      return PopupMenuItem(
        child: Text(choice),
        value: choice,
      );
    }).toList();
  }

  menuItemSelected(item) {
    switch (item) {
      case 'Create Bucket':
        Navigator.of(context).pushNamed(
          BucketFormPage.routeName,
          arguments: BucketFormArguments(isNew: true),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buckets'),
        actions: <Widget>[
          PopupMenuButton<String>(
            itemBuilder: menuItemBuilder,
            onSelected: menuItemSelected,
          )
        ],
      ),
      body: bucketsWidget(),
    );
  }
}
