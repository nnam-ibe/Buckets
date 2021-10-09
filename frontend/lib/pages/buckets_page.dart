import 'package:flutter/material.dart';
import 'package:frontend/api/authentication/session.dart';
import 'package:frontend/models/bucket.dart';
import 'package:frontend/api/repositories.dart';
import 'package:provider/provider.dart';

class BucketsPage extends StatefulWidget {
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
    if (token != null) {
      futureBuckets = getBuckets(token);
    } else {
      futureBuckets = Future.value(<Bucket>[]);
    }
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
          return ListView.builder(
            itemCount: snapshot.data?.length,
            itemBuilder: (context, index) {
              return Text(snapshot.data![index].name);
            },
          );
        } else if (snapshot.hasError) {
          return Text('${snapshot.error}');
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
