import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sgx_client/sgx_client.dart';

void main() {
  const MethodChannel channel = MethodChannel('sgx_client');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await SgxClient.platformVersion, '42');
  });
}
