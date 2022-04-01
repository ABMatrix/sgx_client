import 'package:flutter/material.dart';

import 'package:sgx_client/sgx_client.dart';

const nonSgxUrl = "https://baidu.com";
const sgxUrl = "https://key3.safematrix.io:9010";
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
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () => _verifyCert(nonSgxUrl),
                icon: Icon(Icons.send),
              ),
              Text('Non sgx server url $nonSgxUrl'),
              IconButton(
                onPressed: () => _verifyCert(sgxUrl),
                icon: Icon(Icons.send),
              ),
              Text('Sgx url $sgxUrl'),
              SizedBox(
                height: 30,
              ),
              Text('Response: $_result\n'),
            ],
          ),
        ),
      ),
    );
  }

  _verifyCert(String url) async {
    try {
      SgxClient.init();
      final result = await SgxClient.get(url);
      setState(() {
        _result = result;
      });
    } catch (e) {
      setState(() {
        _result = e.toString();
      });
    }
  }
}
