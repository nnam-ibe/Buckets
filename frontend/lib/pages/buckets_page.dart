import 'package:flutter/material.dart';
import 'package:frontend/api/authentication/session.dart';
import 'package:frontend/models/bucket.dart';
import 'package:frontend/api/repositories.dart';
import 'package:frontend/pages/authentication/login_page.dart';
import 'package:provider/provider.dart';
import 'package:frontend/pages/widgets/bucket_widget.dart';

class BucketsPage extends StatefulWidget {
  static const routeName = '/buckets';
  const BucketsPage({Key? key}) : super(key: key);

  @override
  _BucketsPageState createState() => _BucketsPageState();
}

class _BucketsPageState extends State<BucketsPage> {
  late Future<List<Bucket>> futureBuckets;

  @override
  void initState() {
    super.initState();
    String? token = Provider.of<UserSession>(
      context,
      listen: false,
    ).token;
    if (token == null) {
      // TODO: state-management this should be somewhere else
      Navigator.of(context).pushNamed(LoginPage.routeName);
      return;
    }
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
