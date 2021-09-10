import 'package:flutter/material.dart';

import 'package:sgx_client/sgx_client.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _result = '';

  @override
  void initState() {
    super.initState();
    SgxClient.init();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
              onPressed: () async {
                try{
                  SgxClient.init();
                  final result = await SgxClient.get("https://keyt.safematrix.io:8448/");
                  setState(() {
                    _result = result;
                  });
                } catch(e) {
                  print(e.toString());
                }
              },
              icon: Icon(Icons.signal_cellular_connected_no_internet_4_bar),
            ),
            Text('Response: $_result\n'),
          ],
        ),
      ),
    );
  }
}
