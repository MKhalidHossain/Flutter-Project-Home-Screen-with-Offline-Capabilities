import 'package:deta_fetch_using_locat_storage/Home_fatch_data_show.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/material.dart';

void main() async {
  await Hive.initFlutter();
  await Hive.openBox('offlineDataBox');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Assignment 3: Offline Storage',
      home: const DataListScreen(),
    );
  }
}