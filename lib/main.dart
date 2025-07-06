import 'package:flutter/material.dart';
import 'config_loader.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

late AppConfig config;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final     configData = await loadConfig();
  config = AppConfig.fromJson(configData);

  runApp(MyApp());
}

class AppConfig {
  final String postsUrl;
  final String usersUrl;

  AppConfig({required this.postsUrl, required this.usersUrl});

  factory AppConfig.fromJson(Map<String, dynamic> json) {
    return AppConfig(
      postsUrl: json['postsUrl'] ?? '',
      usersUrl: json['usersUrl'] ?? '',
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Config Demo',
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  Future<List<dynamic>> fetchData(String url) async {
    final res = await http.get(Uri.parse(url));
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Failed to fetch data');
  }

  Widget buildList(String title, List<dynamic> data) {
    return Expanded(
      child: Card(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: data.length,
                itemBuilder: (_, index) => ListTile(
                  title: Text(data[index]['title'] ?? data[index]['name'] ?? ''),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final postsFuture = fetchData(config.postsUrl);
    final usersFuture = fetchData(config.usersUrl);

    return Scaffold(
      appBar: AppBar(title: Text('Config Loader Example')),
      body: FutureBuilder(
        future: Future.wait([postsFuture, usersFuture]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final posts = snapshot.data![0] as List;
          final users = snapshot.data![1] as List;

          return Row(
            children: [
              buildList('Posts', posts.take(10).toList()),
              buildList('Users', users.take(10).toList()),
            ],
          );
        },
      ),
    );
  }
}
