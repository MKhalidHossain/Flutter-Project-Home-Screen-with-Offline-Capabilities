import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:convert';

class DataListScreen extends StatefulWidget {
  const DataListScreen({Key? key}) : super(key: key);

  @override
  _DataListScreenState createState() => _DataListScreenState();
}

class _DataListScreenState extends State<DataListScreen> {
  late Future<List<dynamic>> _dataFuture;
  final Box _offlineBox = Hive.box('offlineDataBox');

  @override
  void initState() {
    super.initState();
    _dataFuture = fetchData();
  }

  Future<List<dynamic>> fetchData() async {
    const String apiUrl = 'https://jsonplaceholder.typicode.com/posts';
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _offlineBox.put('cachedData', data);
        return data;
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      final cachedData = _offlineBox.get('cachedData');
      if (cachedData != null) {
        return List<dynamic>.from(cachedData);
      } else {
        throw Exception('Network error: $e. No cached data available.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data List'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 50, color: Colors.red),
                  const SizedBox(height: 10),
                  Text('Error: ${snapshot.error}', textAlign: TextAlign.center),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No data available'));
          } else {
            final data = snapshot.data!;
            return ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                final item = data[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    title: Text(item['title']),
                    subtitle: Text(item['body']),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
