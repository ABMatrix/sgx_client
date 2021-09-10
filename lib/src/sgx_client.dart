import 'dart:developer';
import 'dart:io';

import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';

import 'verify_bridge.dart';

class SgxClient {
  static final Dio dio = Dio(BaseOptions(
    receiveTimeout: 30000,
    connectTimeout: 30000,
  ));

  static init() async {
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (client) {
      SecurityContext sc = SecurityContext(withTrustedRoots: false);
      HttpClient httpClient = HttpClient(context: sc)
        ..badCertificateCallback =
            (X509Certificate cert, String name, int port) {
          try {
            final result = VerifyBridge.verify(cert);
            log(result.toString());
            return result;
          } catch (e) {
            log(e.toString());
            return false;
          }
        };
      return httpClient;
    };
  }

  static Future get(String url, [Map<String, dynamic>? params]) async {
    Response response;
    if (params != null) {
      response = await dio.get(url, queryParameters: params);
    } else {
      response = await dio.get(url);
    }
    if (response.data != null) return response.data;
  }
}
