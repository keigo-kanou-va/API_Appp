import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
//import 'package:webview_flutter/webview_flutter.dart'

void main() {
  runApp(const My2App());
}

class My2App extends StatelessWidget {
  const My2App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyApp(),
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  TextEditingController controller = TextEditingController();
  List<String> items = [];
  String errorMessage = '';

  Future<void> loadZipCode(String zipCode) async {
    setState(() {
      errorMessage = 'APIレスポンス待ち';
    });

    final response = await http.get(
        Uri.parse('https://zipcloud.ibsnet.co.jp/api/search?zipcode=$zipCode'));

    if (response.statusCode != 200) {
      setState(() {
        errorMessage = 'APIレスポンスエラー';
      });
      return;
    }

    final body = json.decode(response.body) as Map<String, dynamic>;
    final results = body['results'] as List<dynamic>;

    if (results.isEmpty) {
      setState(() {
        errorMessage = '住所が見つかりませんでした';
      });
      return;
    } else {
      setState(() {
        errorMessage = '';
        items = results
            .map((result) =>
                '${result['address1']}${result['address2']}${result['address3']}')
            .toList(growable: false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('zipcode'),
        ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              TextField(
              controller: controller,
              //keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: '郵便番号を入力してください',
              ),
              onChanged: (value) {
                if (value.isNotEmpty) {
                  loadZipCode(value);
                }
              },
            ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView.builder(itemBuilder: (context, index) {
                  if (errorMessage.isNotEmpty) {
                    return ListTile(title: Text(errorMessage));
                  } else {
                    return ListTile(
                      title: Text(items[index]),
                    );
                  }
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
