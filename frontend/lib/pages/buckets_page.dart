import 'package:flutter/material.dart';
import 'package:frontend/api/repositories.dart';
import 'package:frontend/common/helpers.dart' as helpers;
import 'package:frontend/models/bucket.dart';
import 'package:frontend/pages/widgets/bucket_widget.dart';

class BucketsPage extends StatefulWidget {
  static const routeName = '/buckets';
  const BucketsPage({Key? key}) : super(key: key);

  @override
  _BucketsPageState createState() => _BucketsPageState();
}

class _BucketsPageState extends State<BucketsPage> {
  late Future<List<Bucket>> futureBuckets;
  String? token = "";

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buckets')),
      body: bucketsWidget(),
    );
  }
}
